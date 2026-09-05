import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';

import '../utils/arabic_text.dart';

/// Reads lesson text aloud using high-quality Microsoft Edge Arabic Natural voices.
///
/// Pre-rendered 24kHz studio MP3 assets synthesized with Microsoft Edge's
/// `ar-EG-ShakirNeural` engine ensure pristine natural voice across all browsers
/// (including Chrome on Web) and offline platforms, with seamless system voice fallback.
class TtsService with ChangeNotifier {
  final FlutterTts _systemTts = FlutterTts();
  final AudioPlayer _player = AudioPlayer();

  bool ready = false;
  bool _speaking = false;
  Map<String, String>? _selectedVoice;

  bool get isSpeaking => _speaking;
  bool get isEdgeNeural => true;

  String get activeVoiceName => 'Microsoft Shakir (Neural - Edge Natural)';

  static const String voiceShakir = 'ar-EG-ShakirNeural';
  static const String voiceZariyah = 'ar-SA-ZariyahNeural';

  /// Every text that contains لفظ الجلالة MUST resolve to an asset here —
  /// never to the live system voice. Neural Arabic voices do not apply
  /// تفخيم to the lām: measured across all twelve Edge `ar-*` voices, the
  /// lām of "الله" sits at F2 ≈ 1470–1710 Hz (clear/tarqīq), where a
  /// reciter's is ≈ 410–790 Hz (dark/tafkhīm). No spelling of the word
  /// changes that, so the divine name is only ever played from recitation.
  static const Map<String, String> _preRenderedAssets = {
    // Reading lines. reading_0 opens with لفظ الجلالة, so it is NOT a plain
    // synthesis: the first word is the reciter's, level-matched and joined
    // at the word boundary, and only the rest is the teaching voice. Do not
    // regenerate it with TTS alone — that silently restores the light lām.
    'اللَّهُ هُوَ الإِلَهُ الحَقُّ.': 'assets/audio/tts/reading_0.mp3',
    'اَللهُ هُوَ الإِلَهُ الحَقُّ.': 'assets/audio/tts/reading_0.mp3',
    'الله هو الإله الحق': 'assets/audio/tts/reading_0.mp3',
    'هُوَ وَاحِدٌ أَحَدٌ، لَيْسَ كَمِثْلِهِ شَيْءٌ.': 'assets/audio/tts/reading_1.mp3',
    'هُوَ الرَّحْمَنُ الرَّحِيمُ، يَرْحَمُ عِبَادَهُ.': 'assets/audio/tts/reading_2.mp3',
    'هُوَ الْعَلِيمُ الْخَبِيرُ، يَعْلَمُ كُلَّ شَيْءٍ.': 'assets/audio/tts/reading_3.mp3',
    'هُوَ السَّمِيعُ الْبَصِيرُ، يَسْمَعُ وَيَرَى.': 'assets/audio/tts/reading_4.mp3',
    'هُوَ الْعَزِيزُ الْحَكِيمُ.': 'assets/audio/tts/reading_5.mp3',
    // لفظ الجلالة — authentic recitation, never synthesized. Neural TTS
    // voices render the lām light; the divine name requires تفخيم (taghlīẓ
    // al-lām) after fatḥa/ḍamma, so this plays a real reciter's ٱللَّهُ
    // (Qur'an 2:255, ayah-initial, nominative) instead.
    'اللَّهُ': 'assets/audio/quran/lafz_jalalah.mp3',
    'اَللهُ': 'assets/audio/quran/lafz_jalalah.mp3',
    'اللهُ': 'assets/audio/quran/lafz_jalalah.mp3',
    'الله': 'assets/audio/quran/lafz_jalalah.mp3',
    // Other vocab words
    'الرَّحْمَنُ': 'assets/audio/tts/vocab_1.mp3',
    'الرَّحِيمُ': 'assets/audio/tts/vocab_2.mp3',
    'الْعَلِيمُ': 'assets/audio/tts/vocab_3.mp3',
    'الْخَبِيرُ': 'assets/audio/tts/vocab_4.mp3',
    'السَّمِيعُ': 'assets/audio/tts/vocab_5.mp3',
    'الْبَصِيرُ': 'assets/audio/tts/vocab_6.mp3',
    'الْعَزِيزُ': 'assets/audio/tts/vocab_7.mp3',
  };

  Future<void> init() async {
    await _initSystemTts();
    notifyListeners();
  }

  Future<void> _initSystemTts() async {
    try {
      await _systemTts.awaitSpeakCompletion(true);
      await _systemTts.setSpeechRate(0.42);
      await _systemTts.setPitch(1.0);

      final voice = await _findArabicSystemVoice();
      if (voice != null) {
        _selectedVoice = voice;
        final loc = voice['locale'] ?? 'ar-SA';
        final name = voice['name'] ?? '';
        debugPrint('TtsService: Selected Arabic voice: $name ($loc)');

        try {
          await _systemTts.setLanguage(loc);
        } catch (_) {}
        try {
          await _systemTts.setVoice({'name': name, 'locale': loc});
        } catch (_) {}
      } else {
        try {
          await _systemTts.setLanguage('ar-SA');
        } catch (_) {
          await _systemTts.setLanguage('ar');
        }
      }
      ready = true;
    } catch (e) {
      debugPrint('TtsService: system TTS init failed ($e)');
      ready = true;
    }
  }

  /// Searches available browser/system voices prioritizing Microsoft Edge Natural voices.
  Future<Map<String, String>?> _findArabicSystemVoice() async {
    for (var attempt = 0; attempt < 10; attempt++) {
      try {
        final raw = await _systemTts.getVoices;
        final voices = _parseVoices(raw);
        if (voices.isNotEmpty) {
          // 1. Prioritize Microsoft Shakir Online (Natural)
          final shakir = voices.firstWhere(
            (v) {
              final name = (v['name'] ?? '').toLowerCase();
              return name.contains('natural') && name.contains('shakir');
            },
            orElse: () => const {},
          );
          if (shakir.isNotEmpty) return shakir;

          // 2. Prioritize Microsoft Zariyah Online (Natural)
          final zariyah = voices.firstWhere(
            (v) {
              final name = (v['name'] ?? '').toLowerCase();
              return name.contains('natural') && name.contains('zariyah');
            },
            orElse: () => const {},
          );
          if (zariyah.isNotEmpty) return zariyah;

          // 3. Any Microsoft Natural Arabic voice
          final anyNaturalArabic = voices.firstWhere(
            (v) {
              final name = (v['name'] ?? '').toLowerCase();
              final loc = (v['locale'] ?? '').toLowerCase();
              final isAr = loc.startsWith('ar') || name.contains('arabic');
              return isAr && name.contains('natural');
            },
            orElse: () => const {},
          );
          if (anyNaturalArabic.isNotEmpty) return anyNaturalArabic;

          // 4. Any Microsoft Arabic voice
          final anyMicrosoftArabic = voices.firstWhere(
            (v) {
              final name = (v['name'] ?? '').toLowerCase();
              final loc = (v['locale'] ?? '').toLowerCase();
              final isAr = loc.startsWith('ar') || name.contains('arabic');
              return isAr && name.contains('microsoft');
            },
            orElse: () => const {},
          );
          if (anyMicrosoftArabic.isNotEmpty) return anyMicrosoftArabic;

          // 5. Any Google Arabic / Neural voice
          final googleArabic = voices.firstWhere(
            (v) {
              final name = (v['name'] ?? '').toLowerCase();
              final loc = (v['locale'] ?? '').toLowerCase();
              return loc.startsWith('ar') &&
                  (name.contains('google') || name.contains('wavenet') || name.contains('neural'));
            },
            orElse: () => const {},
          );
          if (googleArabic.isNotEmpty) return googleArabic;

          // 6. Arabic Saudi Arabia
          final saVoice = voices.firstWhere(
            (v) {
              final loc = (v['locale'] ?? '').toLowerCase();
              return loc.startsWith('ar-sa') || loc.startsWith('ar_sa');
            },
            orElse: () => const {},
          );
          if (saVoice.isNotEmpty) return saVoice;

          // 7. Any Arabic voice
          final anyArabic = voices.firstWhere(
            (v) => (v['locale'] ?? '').toLowerCase().startsWith('ar'),
            orElse: () => const {},
          );
          if (anyArabic.isNotEmpty) return anyArabic;

          return null;
        }
      } catch (_) {}
      await Future.delayed(const Duration(milliseconds: 200));
    }
    return null;
  }

  List<Map<String, String>> _parseVoices(dynamic raw) {
    if (raw is! List) return const [];
    final out = <Map<String, String>>[];
    for (final entry in raw) {
      if (entry is Map) {
        final name = entry['name']?.toString();
        final locale = entry['locale']?.toString();
        if (name != null && locale != null) out.add({'name': name, 'locale': locale});
      }
    }
    return out;
  }

  Future<void> speak(String text) async {
    if (!ready) return;
    _speaking = true;
    notifyListeners();
    try {
      // 1. First priority: Pre-rendered high-fidelity Microsoft Edge Arabic Natural audio
      final playedAsset = await _playPreRenderedAsset(text);
      if (playedAsset) return;

      // 2. Browser/system natural voice fallback
      if (_selectedVoice != null) {
        try {
          await _systemTts.setVoice(_selectedVoice!);
        } catch (_) {}
      }

      await _systemTts.stop();
      await Future.delayed(const Duration(milliseconds: 60));
      await _systemTts.speak(text);
    } finally {
      _speaking = false;
      notifyListeners();
    }
  }

  Future<bool> _playPreRenderedAsset(String text) async {
    final normalized = text.trim();
    String? asset = _preRenderedAssets[normalized];
    if (asset == null) {
      final stripped = stripTashkeel(normalized);
      for (final entry in _preRenderedAssets.entries) {
        if (stripTashkeel(entry.key) == stripped) {
          asset = entry.value;
          break;
        }
      }
    }
    if (asset == null) return false;

    try {
      await _player.stop();
      await _player.setAsset(asset);
      await _player.play();
      await _player.playerStateStream.firstWhere(
        (s) => s.processingState == ProcessingState.completed || s.processingState == ProcessingState.idle,
      );
      return true;
    } catch (e) {
      debugPrint('TtsService: Pre-rendered asset playback failed ($e) — falling back.');
      return false;
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (_) {}
    try {
      await _systemTts.stop();
    } catch (_) {}
    _speaking = false;
    notifyListeners();
  }
}
