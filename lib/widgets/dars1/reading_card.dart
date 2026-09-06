import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/curriculum.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../atmosphere.dart';
import '../common.dart';

class ReadingCard extends StatefulWidget {
  const ReadingCard({super.key});

  @override
  State<ReadingCard> createState() => _ReadingCardState();
}

class _ReadingCardState extends State<ReadingCard> {
  int? _speakingLine; // null = none, -1 = ayah
  bool _playingAll = false;
  bool _showTranslation = true;
  bool _cancelAll = false; // lets _stopEverything break a running _playAll loop

  static const _ayahMalayTranslation =
      '“Pencipta langit dan bumi. Dia menjadikan bagi kamu dari jenis kamu sendiri pasangan-pasangan dan dari binatang ternak pasangan-pasangan (pula); dengan jalan itu Dia mengembangkan kamu. Tiada sesuatu pun yang serupa dengan-Nya, dan Dialah Yang Maha Mendengar lagi Maha Melihat.” (Surah Asy-Syura: 11)';

  /// Stops whatever is currently playing — a single line, the ayah, or the
  /// "play all" sequence — and resets every playback flag.
  Future<void> _stopEverything() async {
    _cancelAll = true;
    final app = context.read<AppState>();
    await app.tts.stop();
    await app.quranAudio.stop();
    if (mounted) {
      setState(() {
        _speakingLine = null;
        _playingAll = false;
      });
    }
  }

  Future<void> _speakLine(int i) async {
    if (_speakingLine == i) return _stopEverything();
    final tts = context.read<AppState>().tts;
    if (_playingAll) await _stopEverything();
    if (!mounted) return;
    if (!tts.ready) return _showMessage('لم يتم العثور على صوت عربي على هذا الجهاز.');
    setState(() => _speakingLine = i);
    await tts.speak(Dars111.readingLines[i]);
    if (mounted && _speakingLine == i) setState(() => _speakingLine = null);
  }

  Future<void> _playAyah() async {
    if (_speakingLine == -1) return _stopEverything();
    final quran = context.read<AppState>().quranAudio;
    if (_playingAll) await _stopEverything();
    if (!mounted) return;
    setState(() => _speakingLine = -1);
    final ok = await quran.playAyah(surah: Dars111.ayahSurahNum, ayah: Dars111.ayahNum);
    if (mounted && _speakingLine == -1) setState(() => _speakingLine = null);
    if (!ok) _showMessage('تعذّر تشغيل التلاوة — تحقّق من اتصالك بالإنترنت.');
  }

  Future<void> _playAll() async {
    if (_playingAll) return _stopEverything();
    final app = context.read<AppState>();
    if (!app.tts.ready) return _showMessage('لم يتم العثور على صوت عربي على هذا الجهاز.');
    _cancelAll = false;
    setState(() => _playingAll = true);
    for (var i = 0; i < Dars111.readingLines.length; i++) {
      if (!mounted || _cancelAll) return;
      setState(() => _speakingLine = i);
      await app.tts.speak(Dars111.readingLines[i]);
    }
    if (!mounted || _cancelAll) return;
    setState(() => _speakingLine = -1);
    await app.quranAudio.playAyah(surah: Dars111.ayahSurahNum, ayah: Dars111.ayahNum);
    if (mounted && !_cancelAll) {
      setState(() {
        _speakingLine = null;
        _playingAll = false;
      });
    }
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: CardHeading('🎧 اِقْرَأِ النَّصَّ بِصَوْتٍ مُرْتَفِعٍ مَعَ زَمِيلِكَ')),
              ElevatedButton.icon(
                onPressed: _playAll,
                icon: Icon(
                  _playingAll ? Icons.stop_rounded : Icons.play_arrow_rounded,
                  size: 18,
                  color: Colors.white,
                ),
                label: Text(
                  _playingAll ? 'إيقاف' : 'استمع للنص كاملاً',
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _playingAll ? c.danger : c.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: c.surface2,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: c.border.withValues(alpha: 0.7)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  size: 14,
                  color: c.gold,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'مفعل: صوت Microsoft Edge الطبيعي (ar-SA-Hamed Neural)',
                    style: TextStyle(
                      fontFamily: AppTheme.uiFont,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: c.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Reading text lines
          for (var i = 0; i < Dars111.readingLines.length; i++)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _speakingLine == i ? c.accentSoft : c.surface2.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _speakingLine == i ? c.accent.withValues(alpha: 0.5) : Colors.transparent,
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _speakingLine == i ? c.accent : c.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: c.border),
                    ),
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _speakingLine == i ? Colors.white : c.textMuted,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SpeakButton(onTap: () => _speakLine(i), size: 32, speaking: _speakingLine == i),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TashkeelText(
                      Dars111.readingLines[i],
                      style: TextStyle(
                        fontSize: 18.5,
                        height: 1.9,
                        color: _speakingLine == i ? c.accent : c.text,
                        fontWeight: _speakingLine == i ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (_speakingLine == i) const _PulsingAudioWaves(),
                ],
              ),
            ),
          const SizedBox(height: 18),
          // Ornate Quran Ayah Showcase Card
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [c.surface2, c.surface],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: c.goldBorder, width: 1.6),
              boxShadow: [
                BoxShadow(
                  color: c.gold.withValues(alpha: 0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  Positioned(
                    top: -15,
                    left: -15,
                    child: GeometricCornerMotif(color: c.gold.withValues(alpha: 0.16), size: 90),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: c.goldSoft,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: c.goldBorder),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.menu_book_rounded, size: 14, color: c.gold),
                                  const SizedBox(width: 6),
                                  Text(
                                    'شاهد من القرآن الكريم',
                                    style: TextStyle(
                                      fontFamily: AppTheme.uiFont,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                      color: c.gold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            // Translation toggle
                            TextButton.icon(
                              onPressed: () => setState(() => _showTranslation = !_showTranslation),
                              icon: Icon(
                                _showTranslation ? Icons.visibility_off_outlined : Icons.translate_rounded,
                                size: 15,
                                color: c.accent,
                              ),
                              label: Text(
                                _showTranslation ? 'إخفاء الترجمة' : 'ترجمة (BM)',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: c.accent,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // Ayah Text in AmiriQuran
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: c.surface.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: c.goldBorder.withValues(alpha: 0.5)),
                          ),
                          child: TashkeelText(
                            Dars111.ayahDisplay,
                            font: AppTheme.quranFont,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 21,
                              height: 2.2,
                              color: c.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (_showTranslation) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: c.surface2.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _ayahMalayTranslation,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.6,
                                fontStyle: FontStyle.italic,
                                color: c.textMuted,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),
                        // Audio Reciter Player Bar
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: c.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: c.border),
                          ),
                          child: Row(
                            children: [
                              InkWell(
                                onTap: _playAyah,
                                borderRadius: BorderRadius.circular(999),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _speakingLine == -1 ? c.accent : c.goldSoft,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _speakingLine == -1
                                            ? Icons.stop_rounded
                                            : Icons.play_arrow_rounded,
                                        size: 18,
                                        color: _speakingLine == -1 ? Colors.white : c.gold,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        _speakingLine == -1 ? 'إيقاف التلاوة' : 'استمع للتلاوة',
                                        style: TextStyle(
                                          fontFamily: AppTheme.uiFont,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: _speakingLine == -1 ? Colors.white : c.gold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      Dars111.ayahRef,
                                      style: TextStyle(
                                        fontFamily: AppTheme.uiFont,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12.5,
                                        color: c.text,
                                      ),
                                    ),
                                    Text(
                                      'تلاوة الشيخ مشاري راشد العفاسي',
                                      style: TextStyle(fontSize: 11.5, color: c.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                              if (_speakingLine == -1) const _PulsingAudioWaves(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingAudioWaves extends StatefulWidget {
  const _PulsingAudioWaves();

  @override
  State<_PulsingAudioWaves> createState() => _PulsingAudioWavesState();
}

class _PulsingAudioWavesState extends State<_PulsingAudioWaves> with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        final t = _anim.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _bar(8 + t * 14, c.accent),
            const SizedBox(width: 3),
            _bar(18 - t * 10, c.gold),
            const SizedBox(width: 3),
            _bar(10 + t * 12, c.accent),
            const SizedBox(width: 3),
            _bar(16 - t * 8, c.gold),
          ],
        );
      },
    );
  }

  Widget _bar(double h, Color color) {
    return Container(
      width: 3.5,
      height: h.clamp(6.0, 22.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

