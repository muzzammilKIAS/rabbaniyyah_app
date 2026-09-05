import 'package:flutter/material.dart';
import '../services/quran_audio_service.dart';
import '../services/storage_service.dart';
import '../services/tts_service.dart';

const _navPrefix = 'rabbaniyyah_nav_tashkeel_on';
const _themeModeKey = 'rabbaniyyah_nav_theme_mode';

/// Storage key prefix per lesson, keyed by the same numeric id used in its
/// class/file names (111, 112, 113, 114 = س1و1د1..د3, س1و2د4).
const Map<String, String> _lessonKeys = {
  '111': 'rabbaniyyah_s1_u1_d1_state',
  '112': 'rabbaniyyah_s1_u1_d2_state',
  '113': 'rabbaniyyah_s1_u1_d3_state',
  '114': 'rabbaniyyah_s1_u2_d4_state',
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

  void load() {
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
    _storage.writeBlob(_lessonKeys[id]!, _lessons[id]!);
    notifyListeners();
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

  @override
  void dispose() {
    tts.removeListener(notifyListeners);
    super.dispose();
  }
}
