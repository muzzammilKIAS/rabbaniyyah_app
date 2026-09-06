import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';

import '../utils/arabic_text.dart';

/// Reads lesson text aloud using high-quality Microsoft Edge Arabic Natural voices.
///
/// Pre-rendered MP3 assets synthesized with Microsoft Edge's `ar-SA-HamedNeural`
/// (Hamed, Saudi Arabia) engine ensure a pristine, standard-Fuṣḥā natural voice
/// across all browsers (including Chrome on Web) and offline platforms, with
/// seamless live system/browser voice fallback for any text not pre-rendered.
class TtsService with ChangeNotifier {
  final FlutterTts _systemTts = FlutterTts();
  final AudioPlayer _player = AudioPlayer();

  bool ready = false;
  bool _speaking = false;
  Map<String, String>? _selectedVoice;

  bool get isSpeaking => _speaking;
  bool get isEdgeNeural => true;

  String get activeVoiceName => 'Microsoft Hamed (Neural - Edge Natural, KSA)';

  static const String voiceHamed = 'ar-SA-HamedNeural';
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

    // الدرس الرابع — الطهارة: الوضوء والغسل. No لفظ الجلالة appears in any
    // of these lines, so plain TTS is safe here.
    'الطَّهَارَةُ شَرْطٌ مِنْ شُرُوطِ الصَّلَاةِ. نَتَوَضَّأُ قَبْلَ كُلِّ صَلَاةٍ.': 'assets/audio/tts_dars14/reading_0.mp3',
    'أَوَّلاً، نَنْوِي الوُضُوءَ فِي قَلْبِنَا.': 'assets/audio/tts_dars14/reading_1.mp3',
    'ثُمَّ نَغْسِلُ الوَجْهَ ثَلَاثَ مَرَّاتٍ.': 'assets/audio/tts_dars14/reading_2.mp3',
    'بَعْدَ ذَلِكَ نَغْسِلُ اليَدَيْنِ إِلَى المِرْفَقَيْنِ.': 'assets/audio/tts_dars14/reading_3.mp3',
    'ثُمَّ نَمْسَحُ الرَّأْسَ بِالمَاءِ.': 'assets/audio/tts_dars14/reading_4.mp3',
    'أَخِيراً نَغْسِلُ الرِّجْلَيْنِ إِلَى الكَعْبَيْنِ.': 'assets/audio/tts_dars14/reading_5.mp3',
    'هَذَا هُوَ الوُضُوءُ. أَمَّا الغُسْلُ فَهُوَ غَسْلُ جَمِيعِ الجَسَدِ بِالمَاءِ. نَغْتَسِلُ بَعْدَ الجَنَابَةِ.':
        'assets/audio/tts_dars14/reading_6.mp3',
    // الدرس الثاني — الإيمان بالملائكة والكتب والرسل. Reading line 5 names
    // لفظ الجلالة twice mid-sentence (genitive case, no matching reciter
    // clip) — deliberately absent from this map; see Dars112.readingNoAudio.
    'اَلْمَلَائِكَةُ خَلْقٌ مِنْ نُورٍ.': 'assets/audio/tts_dars12/reading_0.mp3',
    'جِبْرِيلُ مَلَكٌ، مُوَكَّلٌ بِالْوَحْيِ.': 'assets/audio/tts_dars12/reading_1.mp3',
    'مِيكَائِيلُ مَلَكٌ، مُوَكَّلٌ بِالْمَطَرِ وَالرِّزْقِ.': 'assets/audio/tts_dars12/reading_2.mp3',
    'إِسْرَافِيلُ مَلَكٌ، مُوَكَّلٌ بِنَفْخِ الصُّورِ.': 'assets/audio/tts_dars12/reading_3.mp3',
    'عَزْرَائِيلُ مَلَكٌ، مُوَكَّلٌ بِقَبْضِ الْأَرْوَاحِ.': 'assets/audio/tts_dars12/reading_4.mp3',
    'اَلتَّوْرَاةُ كِتَابُ مُوسَى، وَالْإِنْجِيلُ كِتَابُ عِيسَى، وَالزَّبُورُ كِتَابُ دَاوُودَ.': 'assets/audio/tts_dars12/reading_6.mp3',
    'اَلرَّسُولُ بَشَرٌ، وَمُحَمَّدٌ خَاتَمُ الرُّسُلِ.': 'assets/audio/tts_dars12/reading_7.mp3',
    'مَلَكٌ / مَلَائِكَةٌ': 'assets/audio/tts_dars12/vocab_0.mp3',
    'كِتَابٌ / كُتُبٌ': 'assets/audio/tts_dars12/vocab_1.mp3',
    'رَسُولٌ / رُسُلٌ': 'assets/audio/tts_dars12/vocab_2.mp3',
    'نَبِيٌّ / أَنْبِيَاءُ': 'assets/audio/tts_dars12/vocab_3.mp3',
    'اَلْوَحْيُ': 'assets/audio/tts_dars12/vocab_4.mp3',
    'مُوَكَّلٌ بِـ': 'assets/audio/tts_dars12/vocab_5.mp3',
    'خَاتَمٌ': 'assets/audio/tts_dars12/vocab_6.mp3',
    'نُورٌ': 'assets/audio/tts_dars12/vocab_7.mp3',
    'بَشَرٌ': 'assets/audio/tts_dars12/vocab_8.mp3',

    // الدرس الثالث — الإيمان باليوم الآخر والقضاء والقدر. Reading lines 2,
    // 5 and 6 name لفظ الجلالة mid-sentence — absent here on purpose; see
    // Dars113.readingNoAudio.
    'كُلُّ إِنْسَانٍ يَمُوتُ، ثُمَّ يُبْعَثُ يَوْمَ الْقِيَامَةِ.': 'assets/audio/tts_dars13/reading_0.mp3',
    'اَلْيَوْمُ الآخِرُ يَوْمُ الْبَعْثِ وَالْحِسَابِ.': 'assets/audio/tts_dars13/reading_1.mp3',
    'مَنْ عَمِلَ خَيْرًا دَخَلَ الْجَنَّةَ، وَمَنْ عَمِلَ شَرًّا اسْتَحَقَّ النَّارَ.': 'assets/audio/tts_dars13/reading_3.mp3',
    'نَحْنُ نُؤْمِنُ بِالْقَدَرِ، خَيْرِهِ وَشَرِّهِ.': 'assets/audio/tts_dars13/reading_4.mp3',
    'هَذَا هُوَ مَعْنَى الْإِيمَانِ بِالْيَوْمِ الآخِرِ وَالْقَضَاءِ وَالْقَدَرِ.': 'assets/audio/tts_dars13/reading_7.mp3',
    'اَلْيَوْمُ الآخِرُ': 'assets/audio/tts_dars13/vocab_0.mp3',
    'اَلْمَوْتُ': 'assets/audio/tts_dars13/vocab_1.mp3',
    'اَلْبَعْثُ': 'assets/audio/tts_dars13/vocab_2.mp3',
    'اَلْحِسَابُ': 'assets/audio/tts_dars13/vocab_3.mp3',
    'اَلْجَنَّةُ': 'assets/audio/tts_dars13/vocab_4.mp3',
    'اَلنَّارُ': 'assets/audio/tts_dars13/vocab_5.mp3',
    'اَلْقَدَرُ': 'assets/audio/tts_dars13/vocab_6.mp3',
    'خَيْرٌ وَشَرٌّ': 'assets/audio/tts_dars13/vocab_7.mp3',

    'الطَّهَارَةُ': 'assets/audio/tts_dars14/vocab_0.mp3',
    'الْوُضُوءُ': 'assets/audio/tts_dars14/vocab_1.mp3',
    'الْغُسْلُ': 'assets/audio/tts_dars14/vocab_2.mp3',
    'نَغْسِلُ': 'assets/audio/tts_dars14/vocab_3.mp3',
    'نَمْسَحُ': 'assets/audio/tts_dars14/vocab_4.mp3',
    'أَوَّلاً': 'assets/audio/tts_dars14/vocab_5.mp3',
    'ثُمَّ': 'assets/audio/tts_dars14/vocab_6.mp3',
    'أَخِيراً': 'assets/audio/tts_dars14/vocab_7.mp3',
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
          // 1. Prioritize Microsoft Hamed Online (Natural, ar-SA — matches
          // the pre-rendered asset voice and standard Saudi Fuṣḥā diction).
          final hamed = voices.firstWhere(
            (v) {
              final name = (v['name'] ?? '').toLowerCase();
              return name.contains('natural') && name.contains('hamed');
            },
            orElse: () => const {},
          );
          if (hamed.isNotEmpty) return hamed;

          // 2. Prioritize Microsoft Shakir Online (Natural)
          final shakir = voices.firstWhere(
            (v) {
              final name = (v['name'] ?? '').toLowerCase();
              return name.contains('natural') && name.contains('shakir');
            },
            orElse: () => const {},
          );
          if (shakir.isNotEmpty) return shakir;

          // 3. Prioritize Microsoft Zariyah Online (Natural)
          final zariyah = voices.firstWhere(
            (v) {
              final name = (v['name'] ?? '').toLowerCase();
              return name.contains('natural') && name.contains('zariyah');
            },
            orElse: () => const {},
          );
          if (zariyah.isNotEmpty) return zariyah;

          // 4. Any Microsoft Natural Arabic voice
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

          // 5. Any Microsoft Arabic voice
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

          // 6. Any Google Arabic / Neural voice
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

          // 7. Arabic Saudi Arabia
          final saVoice = voices.firstWhere(
            (v) {
              final loc = (v['locale'] ?? '').toLowerCase();
              return loc.startsWith('ar-sa') || loc.startsWith('ar_sa');
            },
            orElse: () => const {},
          );
          if (saVoice.isNotEmpty) return saVoice;

          // 8. Any Arabic voice
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

      // Safety net: never let the live system/neural voice read لفظ الجلالة
      // (or the contracted "لِلَّهِ"). Those voices render the lām light,
      // but the divine name requires تفخيم (taghlīẓ al-lām) — if the text
      // wasn't resolved to a reciter clip above, refuse rather than
      // mispronounce it.
      final skeleton = stripTashkeel(text);
      if (skeleton.contains('الله') || skeleton.contains('لله')) {
        debugPrint('TtsService: refusing to synthesize "$text" — contains لفظ الجلالة with no matching reciter clip.');
        return;
      }

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
