import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/curriculum.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../common.dart';

class ReadingCard3 extends StatefulWidget {
  const ReadingCard3({super.key});

  @override
  State<ReadingCard3> createState() => _ReadingCard3State();
}

class _ReadingCard3State extends State<ReadingCard3> {
  int? _speakingLine; // null = none, -1 = ayah
  bool _playingAll = false;
  bool _cancelAll = false;

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
    if (Dars113.readingNoAudio.contains(i)) return;
    if (_speakingLine == i) return _stopEverything();
    final tts = context.read<AppState>().tts;
    if (_playingAll) await _stopEverything();
    if (!mounted) return;
    if (!tts.ready) return _showMessage('لم يتم العثور على صوت عربي على هذا الجهاز.');
    setState(() => _speakingLine = i);
    await tts.speak(Dars113.readingLines[i]);
    if (mounted && _speakingLine == i) setState(() => _speakingLine = null);
  }

  Future<void> _playAyah() async {
    if (_speakingLine == -1) return _stopEverything();
    final quran = context.read<AppState>().quranAudio;
    if (_playingAll) await _stopEverything();
    if (!mounted) return;
    setState(() => _speakingLine = -1);
    final ok1 = await quran.playAyah(surah: Dars113.ayahSurahNum, ayah: Dars113.ayahNum);
    if (!mounted || _speakingLine != -1) return;
    final ok2 = await quran.playAyah(surah: Dars113.ayahSurahNum, ayah: Dars113.ayahNum2);
    if (mounted && _speakingLine == -1) setState(() => _speakingLine = null);
    if (!ok1 || !ok2) _showMessage('تعذّر تشغيل التلاوة — تحقّق من اتصالك بالإنترنت.');
  }

  Future<void> _playAll() async {
    if (_playingAll) return _stopEverything();
    final app = context.read<AppState>();
    if (!app.tts.ready) return _showMessage('لم يتم العثور على صوت عربي على هذا الجهاز.');
    _cancelAll = false;
    setState(() => _playingAll = true);
    for (var i = 0; i < Dars113.readingLines.length; i++) {
      if (!mounted || _cancelAll) return;
      if (Dars113.readingNoAudio.contains(i)) continue;
      setState(() => _speakingLine = i);
      await app.tts.speak(Dars113.readingLines[i]);
    }
    if (!mounted || _cancelAll) return;
    setState(() => _speakingLine = -1);
    await app.quranAudio.playAyah(surah: Dars113.ayahSurahNum, ayah: Dars113.ayahNum);
    if (!mounted || _cancelAll) return;
    await app.quranAudio.playAyah(surah: Dars113.ayahSurahNum, ayah: Dars113.ayahNum2);
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
                icon: Icon(_playingAll ? Icons.stop_rounded : Icons.play_arrow_rounded, size: 18, color: Colors.white),
                label: Text(_playingAll ? 'إيقاف' : 'استمع للنص كاملاً', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _playingAll ? c.danger : c.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < Dars113.readingLines.length; i++)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _speakingLine == i ? c.accentSoft : c.surface2.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _speakingLine == i ? c.accent.withValues(alpha: 0.5) : Colors.transparent, width: 1.2),
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
                    child: Text('${i + 1}',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _speakingLine == i ? Colors.white : c.textMuted)),
                  ),
                  const SizedBox(width: 12),
                  if (Dars113.readingNoAudio.contains(i))
                    const SizedBox(width: 32)
                  else
                    SpeakButton(onTap: () => _speakLine(i), size: 32, speaking: _speakingLine == i),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      Dars113.readingLines[i],
                      style: TextStyle(
                        fontFamily: AppTheme.arabicFont,
                        fontSize: 18.5,
                        height: 1.9,
                        color: _speakingLine == i ? c.accent : c.text,
                        fontWeight: _speakingLine == i ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          // Quran ayah — always played from real recitation, never TTS.
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [c.surface2, c.surface], begin: Alignment.topRight, end: Alignment.bottomLeft),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: c.goldBorder, width: 1.6),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: c.surface.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: c.goldBorder.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        '﴿${Dars113.ayahDisplay}﴾',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: AppTheme.quranFont, fontSize: 20, height: 2.2, color: c.accent, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: c.border)),
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
                                  Icon(_speakingLine == -1 ? Icons.stop_rounded : Icons.play_arrow_rounded,
                                      size: 18, color: _speakingLine == -1 ? Colors.white : c.gold),
                                  const SizedBox(width: 6),
                                  Text(_speakingLine == -1 ? 'إيقاف التلاوة' : 'استمع للتلاوة',
                                      style: TextStyle(
                                          fontFamily: AppTheme.uiFont,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: _speakingLine == -1 ? Colors.white : c.gold)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(Dars113.ayahRef,
                                style: TextStyle(fontFamily: AppTheme.uiFont, fontWeight: FontWeight.w700, fontSize: 12.5, color: c.text)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
