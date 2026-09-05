import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around SharedPreferences, storing arbitrary JSON-encodable
/// values under a single namespaced key so a whole lesson's state (answers,
/// checklist ticks, free-text drafts) round-trips as one blob.
class StorageService {
  StorageService._(this._prefs);
  final SharedPreferences _prefs;

  static Future<StorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService._(prefs);
  }

  Map<String, dynamic> readBlob(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      return {};
    } catch (_) {
      return {};
    }
  }

  Future<void> writeBlob(String key, Map<String, dynamic> value) async {
    await _prefs.setString(key, jsonEncode(value));
  }

  Future<void> clearBlob(String key) async {
    await _prefs.remove(key);
  }

  bool getBool(String key, bool fallback) => _prefs.getBool(key) ?? fallback;
  Future<void> setBool(String key, bool value) => _prefs.setBool(key, value);

  String getString(String key, String fallback) => _prefs.getString(key) ?? fallback;
  Future<void> setString(String key, String value) => _prefs.setString(key, value);
}
