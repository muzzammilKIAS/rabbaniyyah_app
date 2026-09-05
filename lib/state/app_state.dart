import 'package:flutter/material.dart';
import '../services/quran_audio_service.dart';
import '../services/storage_service.dart';
import '../services/tts_service.dart';

const _navPrefix = 'rabbaniyyah_nav_tashkeel_on';
const _themeModeKey = 'rabbaniyyah_nav_theme_mode';
const _dars111Key = 'rabbaniyyah_s1_u1_d1_state';

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

  late Map<String, dynamic> _dars111;

  void load() {
    _tashkeelOn = _storage.getBool(_navPrefix, true);
    _themeMode = _themeModeFromString(_storage.getString(_themeModeKey, 'system'));
    _dars111 = _storage.readBlob(_dars111Key);
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

  T dars111Get<T>(String key, T fallback) {
    final v = _dars111[key];
    if (v == null) return fallback;
    return v as T;
  }

  void dars111Set(String key, dynamic value) {
    _dars111[key] = value;
    _storage.writeBlob(_dars111Key, _dars111);
    notifyListeners();
  }

  Map<String, bool> dars111SelfChecks() {
    final raw = _dars111['selfChecks'];
    if (raw is Map) {
      return raw.map((k, v) => MapEntry(k.toString(), v == true));
    }
    return {};
  }

  void dars111SetSelfCheck(int index, bool value) {
    final checks = dars111SelfChecks();
    checks[index.toString()] = value;
    dars111Set('selfChecks', checks);
  }

  double dars111Progress(int totalItems) {
    final checks = dars111SelfChecks();
    final done = checks.values.where((v) => v).length;
    if (totalItems == 0) return 0;
    return done / totalItems;
  }

  Future<void> resetDars111() async {
    _dars111 = {};
    await _storage.clearBlob(_dars111Key);
    notifyListeners();
  }

  @override
  void dispose() {
    tts.removeListener(notifyListeners);
    super.dispose();
  }
}
