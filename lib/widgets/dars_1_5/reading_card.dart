import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/curriculum.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../common.dart';

class ReadingCard5 extends StatefulWidget {
  const ReadingCard5({super.key});

  @override
  State<ReadingCard5> createState() => _ReadingCard5State();
}

class _ReadingCard5State extends State<ReadingCard5> {
  int? _speakingLine;
  bool _playingAll = false;
  bool _cancelAll = false;

  Future<void> _stopEverything() async {
    _cancelAll = true;
    await context.read<AppState>().tts.stop();
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
    await tts.speak(Dars115.readingLines[i]);
    if (mounted && _speakingLine == i) setState(() => _speakingLine = null);
  }

  Future<void> _playAll() async {
    if (_playingAll) return _stopEverything();
    final app = context.read<AppState>();
    if (!app.tts.ready) return _showMessage('لم يتم العثور على صوت عربي على هذا الجهاز.');
    _cancelAll = false;
    setState(() => _playingAll = true);
    for (var i = 0; i < Dars115.readingLines.length; i++) {
      if (!mounted || _cancelAll) return;
      setState(() => _speakingLine = i);
      await app.tts.speak(Dars115.readingLines[i]);
    }
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
          const SizedBox(height: 16),
          for (var i = 0; i < Dars115.readingLines.length; i++)
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
                    child: Text(
                      Dars115.readingLines[i],
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
          // Hadith quote — reference text only, never TTS: it names لفظ
          // الجلالة mid-sentence and there is no reciter clip for this
          // ḥadīth to splice in (see TtsService's rule on the divine name).
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: c.goldSoft,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: c.goldBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.menu_book_rounded, size: 15, color: c.gold),
                    const SizedBox(width: 6),
                    Text(Dars115.hadithNarrator,
                        style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 13.5, color: c.textMuted)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '﴿${Dars115.hadithText}﴾',
                  style: TextStyle(
                    fontFamily: AppTheme.quranFont,
                    fontSize: 19,
                    height: 1.9,
                    color: c.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text('(${Dars115.hadithSource})', style: TextStyle(fontSize: 12, color: c.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
