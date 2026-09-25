import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around SharedPreferences, storing arbitrary JSON-encodable
/// values under a single namespaced key so a whole lesson's state (answers,
/// checklist ticks, free-text drafts) round-trips as one blob.
///
/// On the web SharedPreferences is backed by localStorage, which a browser
/// can refuse outright (private mode, blocked site data). When that happens
/// the app must still open — so every call falls back to an in-memory map:
/// progress simply isn't kept past a refresh instead of the app crashing.
class StorageService {
  StorageService._(this._prefs);
  final SharedPreferences? _prefs;
  final Map<String, Object> _memory = {};

  /// False when localStorage was unavailable and progress lives only in
  /// memory for this session.
  bool get isPersistent => _prefs != null;

  static Future<StorageService> create() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return StorageService._(prefs);
    } catch (e) {
      debugPrint('StorageService: persistent storage unavailable ($e); using memory.');
      return StorageService._(null);
    }
  }

  String? _getString(String key) {
    try {
      return _prefs?.getString(key) ?? _memory[key] as String?;
    } catch (_) {
      return _memory[key] as String?;
    }
  }

  Future<void> _setString(String key, String value) async {
    _memory[key] = value;
    try {
      await _prefs?.setString(key, value);
    } catch (_) {}
  }

  Map<String, dynamic> readBlob(String key) {
    final raw = _getString(key);
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      return {};
    } catch (_) {
      return {};
    }
  }

  Future<void> writeBlob(String key, Map<String, dynamic> value) => _setString(key, jsonEncode(value));

  Future<void> clearBlob(String key) async {
    _memory.remove(key);
    try {
      await _prefs?.remove(key);
    } catch (_) {}
  }

  bool getBool(String key, bool fallback) {
    try {
      return _prefs?.getBool(key) ?? _memory[key] as bool? ?? fallback;
    } catch (_) {
      return fallback;
    }
  }

  Future<void> setBool(String key, bool value) async {
    _memory[key] = value;
    try {
      await _prefs?.setBool(key, value);
    } catch (_) {}
  }

  String getString(String key, String fallback) => _getString(key) ?? fallback;
  Future<void> setString(String key, String value) => _setString(key, value);
}
