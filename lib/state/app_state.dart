import 'dart:async';

import 'package:flutter/material.dart';
import '../data/exercise_models.dart';
import '../data/lesson_catalog.dart';
import '../data/supplemental_exercises.dart';
import '../services/quran_audio_service.dart';
import '../services/storage_service.dart';
import '../services/tts_service.dart';

const _navPrefix = 'rabbaniyyah_nav_tashkeel_on';
const _themeModeKey = 'rabbaniyyah_nav_theme_mode';

/// Cross-lesson learning progress (visited/completed/bookmarked lessons,
/// supplemental-exercise results, last lesson opened). One small blob.
const _progressKey = 'rabbaniyyah_progress_v1';

/// Where a lesson stands for the student, shown on unit/lesson cards.
enum LessonStatus { notStarted, inProgress, completed }

/// Best result of one supplemental exercise.
class ExerciseResult {
  const ExerciseResult({required this.score, required this.total, required this.attempts});
  final int score;
  final int total;
  final int attempts;
  int get stars => starsFor(score, total);
}

/// Storage key prefix per lesson, keyed by the same numeric id used in its
/// class/file names (111, 112, 113, 114 = س1و1د1..د3, س1و2د4).
const Map<String, String> _lessonKeys = {
  '111': 'rabbaniyyah_s1_u1_d1_state',
  '112': 'rabbaniyyah_s1_u1_d2_state',
  '113': 'rabbaniyyah_s1_u1_d3_state',
  '114': 'rabbaniyyah_s1_u2_d4_state',
  '115': 'rabbaniyyah_s1_u2_d5_state',
  '116': 'rabbaniyyah_s1_u2_d6_state',
  '117': 'rabbaniyyah_s1_u3_d7_state',
  '118': 'rabbaniyyah_s1_u3_d8_state',
  '119': 'rabbaniyyah_s1_u3_d9_state',
  '1110': 'rabbaniyyah_s1_u4_d10_state',
  '1111': 'rabbaniyyah_s1_u4_d11_state',
  '1112': 'rabbaniyyah_s1_u4_d12_state',
};

/// Central app state: the global "baris" (tashkeel) visibility toggle, the
/// shared TTS + Qur'an audio services, and one JSON blob per lesson holding
/// every answer, checklist tick and free-text draft the student has entered.
class AppState extends ChangeNotifier {
  AppState(this._storage, this.tts, this.quranAudio) {
    tts.addListener(notifyListeners);
  }

  final StorageService _storage;
  final TtsService tts;
  final QuranAudioService quranAudio;

  bool _tashkeelOn = true;
  bool get tashkeelOn => _tashkeelOn;

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  final Map<String, Map<String, dynamic>> _lessons = {};

  // Every text field, dropdown and checkbox across the twelve lessons
  // writes through _lessonSet, which used to jsonEncode + persist the
  // whole lesson blob on every single keystroke — visible typing lag on
  // longer free-text answers. Debounce the actual disk write per lesson
  // (the in-memory update + notifyListeners still happen immediately, so
  // the UI stays responsive) and flush on dispose so nothing is lost.
  static const _saveDebounce = Duration(milliseconds: 500);
  final Map<String, Timer> _saveTimers = {};

  Map<String, dynamic> _progress = {};

  /// False when the browser refused localStorage — progress then lasts only
  /// for this session (shown as a small notice on the dashboard).
  bool get storageIsPersistent => _storage.isPersistent;

  void load() {
    _progress = _storage.readBlob(_progressKey);
    _tashkeelOn = _storage.getBool(_navPrefix, true);
    _themeMode = _themeModeFromString(_storage.getString(_themeModeKey, 'system'));
    for (final id in _lessonKeys.keys) {
      _lessons[id] = _storage.readBlob(_lessonKeys[id]!);
    }
  }

  void toggleTashkeel() {
    _tashkeelOn = !_tashkeelOn;
    _storage.setBool(_navPrefix, _tashkeelOn);
    notifyListeners();
  }

  /// Cycles نظام → فاتح → داكن → نظام (system → light → dark → system).
  void cycleThemeMode() {
    _themeMode = switch (_themeMode) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
    _storage.setString(_themeModeKey, _themeMode.name);
    notifyListeners();
  }

  ThemeMode _themeModeFromString(String s) {
    return ThemeMode.values.firstWhere((m) => m.name == s, orElse: () => ThemeMode.system);
  }

  T _lessonGet<T>(String id, String key, T fallback) {
    final v = _lessons[id]![key];
    if (v == null) return fallback;
    return v as T;
  }

  void _lessonSet(String id, String key, dynamic value) {
    _lessons[id]![key] = value;
    notifyListeners();
    _saveTimers[id]?.cancel();
    _saveTimers[id] = Timer(_saveDebounce, () {
      _saveTimers.remove(id);
      _storage.writeBlob(_lessonKeys[id]!, _lessons[id]!);
    });
  }

  /// Persists any lesson whose debounced write hasn't fired yet — call this
  /// before the app might be torn down (e.g. on lifecycle pause) so a
  /// student who types then immediately closes the tab doesn't lose it.
  void flushPendingSaves() {
    for (final id in _saveTimers.keys.toList()) {
      _saveTimers.remove(id)?.cancel();
      _storage.writeBlob(_lessonKeys[id]!, _lessons[id]!);
    }
  }

  Map<String, bool> _lessonSelfChecks(String id) {
    final raw = _lessons[id]!['selfChecks'];
    if (raw is Map) {
      return raw.map((k, v) => MapEntry(k.toString(), v == true));
    }
    return {};
  }

  void _lessonSetSelfCheck(String id, int index, bool value) {
    final checks = _lessonSelfChecks(id);
    checks[index.toString()] = value;
    _lessonSet(id, 'selfChecks', checks);
  }

  double _lessonProgress(String id, int totalItems) {
    final checks = _lessonSelfChecks(id);
    final done = checks.values.where((v) => v).length;
    if (totalItems == 0) return 0;
    return done / totalItems;
  }

  Future<void> _resetLesson(String id) async {
    _saveTimers.remove(id)?.cancel();
    _lessons[id] = {};
    await _storage.clearBlob(_lessonKeys[id]!);
    notifyListeners();
  }

  // الدرس الأول — الإيمان بالله
  T dars111Get<T>(String key, T fallback) => _lessonGet('111', key, fallback);
  void dars111Set(String key, dynamic value) => _lessonSet('111', key, value);
  Map<String, bool> dars111SelfChecks() => _lessonSelfChecks('111');
  void dars111SetSelfCheck(int index, bool value) => _lessonSetSelfCheck('111', index, value);
  double dars111Progress(int totalItems) => _lessonProgress('111', totalItems);
  Future<void> resetDars111() => _resetLesson('111');

  // الدرس الثاني — الإيمان بالملائكة والكتب والرسل
  T dars112Get<T>(String key, T fallback) => _lessonGet('112', key, fallback);
  void dars112Set(String key, dynamic value) => _lessonSet('112', key, value);
  Map<String, bool> dars112SelfChecks() => _lessonSelfChecks('112');
  void dars112SetSelfCheck(int index, bool value) => _lessonSetSelfCheck('112', index, value);
  double dars112Progress(int totalItems) => _lessonProgress('112', totalItems);
  Future<void> resetDars112() => _resetLesson('112');

  // الدرس الثالث — الإيمان باليوم الآخر والقضاء والقدر
  T dars113Get<T>(String key, T fallback) => _lessonGet('113', key, fallback);
  void dars113Set(String key, dynamic value) => _lessonSet('113', key, value);
  Map<String, bool> dars113SelfChecks() => _lessonSelfChecks('113');
  void dars113SetSelfCheck(int index, bool value) => _lessonSetSelfCheck('113', index, value);
  double dars113Progress(int totalItems) => _lessonProgress('113', totalItems);
  Future<void> resetDars113() => _resetLesson('113');

  // الدرس الرابع — الطهارة: الوضوء والغسل
  T dars114Get<T>(String key, T fallback) => _lessonGet('114', key, fallback);
  void dars114Set(String key, dynamic value) => _lessonSet('114', key, value);
  Map<String, bool> dars114SelfChecks() => _lessonSelfChecks('114');
  void dars114SetSelfCheck(int index, bool value) => _lessonSetSelfCheck('114', index, value);
  double dars114Progress(int totalItems) => _lessonProgress('114', totalItems);
  Future<void> resetDars114() => _resetLesson('114');

  // الدرس الخامس — الصلاة المفروضة
  T dars115Get<T>(String key, T fallback) => _lessonGet('115', key, fallback);
  void dars115Set(String key, dynamic value) => _lessonSet('115', key, value);
  Map<String, bool> dars115SelfChecks() => _lessonSelfChecks('115');
  void dars115SetSelfCheck(int index, bool value) => _lessonSetSelfCheck('115', index, value);
  double dars115Progress(int totalItems) => _lessonProgress('115', totalItems);
  Future<void> resetDars115() => _resetLesson('115');

  // الدرس السادس — صيام رمضان
  T dars116Get<T>(String key, T fallback) => _lessonGet('116', key, fallback);
  void dars116Set(String key, dynamic value) => _lessonSet('116', key, value);
  Map<String, bool> dars116SelfChecks() => _lessonSelfChecks('116');
  void dars116SetSelfCheck(int index, bool value) => _lessonSetSelfCheck('116', index, value);
  double dars116Progress(int totalItems) => _lessonProgress('116', totalItems);
  Future<void> resetDars116() => _resetLesson('116');

  // الدرس السابع — صفات الرسول
  T dars117Get<T>(String key, T fallback) => _lessonGet('117', key, fallback);
  void dars117Set(String key, dynamic value) => _lessonSet('117', key, value);
  Map<String, bool> dars117SelfChecks() => _lessonSelfChecks('117');
  void dars117SetSelfCheck(int index, bool value) => _lessonSetSelfCheck('117', index, value);
  double dars117Progress(int totalItems) => _lessonProgress('117', totalItems);
  Future<void> resetDars117() => _resetLesson('117');

  // الدرس الثامن — الأخلاق مع الله ورسوله
  T dars118Get<T>(String key, T fallback) => _lessonGet('118', key, fallback);
  void dars118Set(String key, dynamic value) => _lessonSet('118', key, value);
  Map<String, bool> dars118SelfChecks() => _lessonSelfChecks('118');
  void dars118SetSelfCheck(int index, bool value) => _lessonSetSelfCheck('118', index, value);
  double dars118Progress(int totalItems) => _lessonProgress('118', totalItems);
  Future<void> resetDars118() => _resetLesson('118');

  // الدرس التاسع — الأخلاق في الأسرة والمجتمع
  T dars119Get<T>(String key, T fallback) => _lessonGet('119', key, fallback);
  void dars119Set(String key, dynamic value) => _lessonSet('119', key, value);
  Map<String, bool> dars119SelfChecks() => _lessonSelfChecks('119');
  void dars119SetSelfCheck(int index, bool value) => _lessonSetSelfCheck('119', index, value);
  double dars119Progress(int totalItems) => _lessonProgress('119', totalItems);
  Future<void> resetDars119() => _resetLesson('119');

  // الدرس العاشر — مولد النبي وحياته الأولى
  T dars1110Get<T>(String key, T fallback) => _lessonGet('1110', key, fallback);
  void dars1110Set(String key, dynamic value) => _lessonSet('1110', key, value);
  Map<String, bool> dars1110SelfChecks() => _lessonSelfChecks('1110');
  void dars1110SetSelfCheck(int index, bool value) => _lessonSetSelfCheck('1110', index, value);
  double dars1110Progress(int totalItems) => _lessonProgress('1110', totalItems);
  Future<void> resetDars1110() => _resetLesson('1110');

  // الدرس الحادي عشر — الإسراء والمعراج والهجرة
  T dars1111Get<T>(String key, T fallback) => _lessonGet('1111', key, fallback);
  void dars1111Set(String key, dynamic value) => _lessonSet('1111', key, value);
  Map<String, bool> dars1111SelfChecks() => _lessonSelfChecks('1111');
  void dars1111SetSelfCheck(int index, bool value) => _lessonSetSelfCheck('1111', index, value);
  double dars1111Progress(int totalItems) => _lessonProgress('1111', totalItems);
  Future<void> resetDars1111() => _resetLesson('1111');

  // الدرس الثاني عشر — الصحابة المختارون وإسهاماتهم
  T dars1112Get<T>(String key, T fallback) => _lessonGet('1112', key, fallback);
  void dars1112Set(String key, dynamic value) => _lessonSet('1112', key, value);
  Map<String, bool> dars1112SelfChecks() => _lessonSelfChecks('1112');
  void dars1112SetSelfCheck(int index, bool value) => _lessonSetSelfCheck('1112', index, value);
  double dars1112Progress(int totalItems) => _lessonProgress('1112', totalItems);
  Future<void> resetDars1112() => _resetLesson('1112');

  // ───────────────────────── Learning progress ─────────────────────────

  Set<int> _intSet(String key) {
    final raw = _progress[key];
    if (raw is List) return raw.whereType<num>().map((e) => e.toInt()).toSet();
    return {};
  }

  void _putIntSet(String key, Set<int> v) {
    _progress[key] = (v.toList()..sort());
    _saveProgress();
  }

  void _saveProgress() {
    notifyListeners();
    _storage.writeBlob(_progressKey, _progress);
  }

  Map<String, dynamic> get _exercises {
    final raw = _progress['ex'];
    if (raw is Map<String, dynamic>) return raw;
    final fresh = <String, dynamic>{};
    _progress['ex'] = fresh;
    return fresh;
  }

  /// Records that lesson [n] was opened, and remembers it as the lesson to
  /// resume from the dashboard.
  void markVisited(int n) {
    final visited = _intSet('visited');
    final changed = visited.add(n) || _progress['last'] != n;
    if (!changed) return;
    _progress['last'] = n;
    _putIntSet('visited', visited);
  }

  int? get lastLesson {
    final v = _progress['last'];
    return v is num ? v.toInt() : null;
  }

  bool isVisited(int n) => _intSet('visited').contains(n);

  bool isBookmarked(int n) => _intSet('bookmarks').contains(n);
  Set<int> get bookmarks => _intSet('bookmarks');

  void toggleBookmark(int n) {
    final b = _intSet('bookmarks');
    b.contains(n) ? b.remove(n) : b.add(n);
    _putIntSet('bookmarks', b);
  }

  bool isCompleted(int n) => _intSet('completed').contains(n);
  int get completedCount => _intSet('completed').length;

  void setCompleted(int n, bool done) {
    final set = _intSet('completed');
    done ? set.add(n) : set.remove(n);
    _putIntSet('completed', set);
  }

  /// Units whose completion was already celebrated — so the confetti plays
  /// once per unit, not on every visit.
  bool unitCelebrated(int unit) => _intSet('celebratedUnits').contains(unit);
  void markUnitCelebrated(int unit) {
    final s = _intSet('celebratedUnits')..add(unit);
    _putIntSet('celebratedUnits', s);
  }

  ExerciseResult? exerciseResult(int n, String exerciseId) {
    final raw = _exercises['$n:$exerciseId'];
    if (raw is! Map) return null;
    return ExerciseResult(
      score: (raw['score'] as num?)?.toInt() ?? 0,
      total: (raw['total'] as num?)?.toInt() ?? 0,
      attempts: (raw['attempts'] as num?)?.toInt() ?? 0,
    );
  }

  /// Stores an exercise attempt, keeping the best score.
  void recordExercise(int n, String exerciseId, {required int score, required int total}) {
    final prev = exerciseResult(n, exerciseId);
    final best = prev == null || score > prev.score ? score : prev.score;
    _exercises['$n:$exerciseId'] = {
      'score': best,
      'total': total,
      'attempts': (prev?.attempts ?? 0) + 1,
    };
    _saveProgress();
  }

  void resetExercise(int n, String exerciseId) {
    if (_exercises.remove('$n:$exerciseId') != null) _saveProgress();
  }

  int exercisesDone(int n) =>
      exercisesFor(n).where((e) => exerciseResult(n, e.id) != null).length;

  int exercisesTotal(int n) => exercisesFor(n).length;

  int starsForLesson(int n) =>
      exercisesFor(n).fold(0, (sum, e) => sum + (exerciseResult(n, e.id)?.stars ?? 0));

  /// Share of the lesson's self-assessment checklist the student ticked.
  double selfAssessFraction(int n) {
    final meta = lessonByN(n);
    if (meta == null) return 0;
    return _lessonProgress(meta.id, meta.selfAssessCount);
  }

  /// Lesson progress, 0–1: half from the lesson's own self-assessment,
  /// half from the supplemental exercises. A lesson the student marked as
  /// finished counts as complete.
  double lessonProgress(int n) {
    if (isCompleted(n)) return 1;
    final total = exercisesTotal(n);
    final ex = total == 0 ? 0.0 : exercisesDone(n) / total;
    return ((selfAssessFraction(n) + ex) / 2).clamp(0.0, 1.0);
  }

  LessonStatus lessonStatus(int n) {
    if (isCompleted(n)) return LessonStatus.completed;
    if (isVisited(n) || lessonProgress(n) > 0) return LessonStatus.inProgress;
    return LessonStatus.notStarted;
  }

  double unitProgress(int unit) {
    final ls = lessonsInUnit(unit);
    if (ls.isEmpty) return 0;
    return ls.fold(0.0, (s, l) => s + lessonProgress(l.n)) / ls.length;
  }

  bool unitCompleted(int unit) => lessonsInUnit(unit).every((l) => isCompleted(l.n));

  double get overallProgress =>
      kLessons.fold(0.0, (s, l) => s + lessonProgress(l.n)) / kLessons.length;

  int get totalExercisesDone => kLessons.fold(0, (s, l) => s + exercisesDone(l.n));
  int get totalExercises => kLessons.fold(0, (s, l) => s + exercisesTotal(l.n));

  /// Points: 10 per exercise star, 50 per completed lesson.
  int get xp =>
      kLessons.fold(0, (s, l) => s + starsForLesson(l.n) * 10 + (isCompleted(l.n) ? 50 : 0));

  /// Clears a lesson's answers AND its supplemental results/completion.
  Future<void> resetLessonAll(int n) async {
    final meta = lessonByN(n);
    if (meta == null) return;
    _exercises.removeWhere((k, _) => k.startsWith('$n:'));
    final done = _intSet('completed')..remove(n);
    _progress['completed'] = done.toList()..sort();
    await _resetLesson(meta.id);
    _saveProgress();
  }

  /// Wipes every lesson's answers and all progress (keeps theme/tashkeel).
  Future<void> resetAllProgress() async {
    for (final id in _lessonKeys.keys) {
      _saveTimers.remove(id)?.cancel();
      _lessons[id] = {};
      await _storage.clearBlob(_lessonKeys[id]!);
    }
    _progress = {};
    await _storage.clearBlob(_progressKey);
    notifyListeners();
  }

  @override
  void dispose() {
    flushPendingSaves();
    tts.removeListener(notifyListeners);
    super.dispose();
  }
}
