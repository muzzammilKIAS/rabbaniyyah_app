import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/curriculum.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../common.dart';
import '../shared/match_pairs_activity.dart';

class SpeakingCard3 extends StatefulWidget {
  const SpeakingCard3({super.key});

  @override
  State<SpeakingCard3> createState() => _SpeakingCard3State();
}

class _SpeakingCard3State extends State<SpeakingCard3> {
  final _matchKey = GlobalKey<MatchPairsActivityState>();
  late Map<int, int> _initialPairs;

  @override
  void initState() {
    super.initState();
    final raw = context.read<AppState>().dars113Get<Map<String, dynamic>>('speakingPairs', {});
    _initialPairs = raw.map((k, v) => MapEntry(int.parse(k), v as int));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardHeading('🗣️ النَّشَاطُ ١: طَابِقِ السُّؤَالَ بِالْحَرْفِ الْمُنَاسِبِ'),
          const CardInstruction('اِقْرَأِ الْأَسْئِلَةَ وَالْأَجْوِبَةَ مَعَ زَمِيلِكَ شَفَهِيًّا، ثُمَّ اُنْقُرِ السُّؤَالَ ثُمَّ الْجَوَابَ الْمُنَاسِبَ لَهُ.'),
          const SizedBox(height: 14),
          MatchPairsActivity(
            key: _matchKey,
            rightItems: Dars113.matchQuestions,
            leftItems: List.generate(Dars113.matchAnswers.length, (i) => '${Dars113.matchAnswerLetters[i]}) ${Dars113.matchAnswers[i]}'),
            correctIndexForRight: Dars113.matchCorrectIndex,
            rightHeader: 'الأَسْئِلَةُ',
            leftHeader: 'الأَجْوِبَةُ',
            initialPairs: _initialPairs,
            onChanged: (pairs) => context.read<AppState>().dars113Set('speakingPairs', pairs.map((k, v) => MapEntry(k.toString(), v))),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => setState(_matchKey.currentState!.check),
                icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                label: const Text('تحقق من الإجابات'),
              ),
              const SizedBox(width: 10),
              ScoreBadge(
                correct: _matchKey.currentState?.results != null ? _matchKey.currentState!.correctCount : null,
                total: _matchKey.currentState?.results != null ? Dars113.matchQuestions.length : null,
              ),
            ],
          ),
          const SizedBox(height: 28),
          Divider(color: c.border),
          const SizedBox(height: 14),
          const CardHeading('👥 النَّشَاطُ ٢: كَارْدُ الحِوَارِ'),
          const CardInstruction('اِسْأَلْ زَمِيلَكَ وَأَجِبْ. ثُمَّ تَبَادَلَا الدَّوْرَ.'),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(border: Border.all(color: c.border), borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(color: c.surface2, borderRadius: const BorderRadius.vertical(top: Radius.circular(12))),
                  child: Row(
                    children: [
                      Expanded(child: Text('الطَّالِبُ (ب) 👤', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.textMuted))),
                      Expanded(child: Text('الطَّالِبُ (أ) 👤', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.textMuted))),
                    ],
                  ),
                ),
                for (var i = 0; i < Dars113.dialogue.length; i++)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(border: Border(top: BorderSide(color: c.border.withValues(alpha: 0.6)))),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: Text(Dars113.dialogue[i].studentB, textAlign: TextAlign.center, style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 15.5, height: 1.7, color: c.text))),
                        Container(width: 1, height: 40, color: c.border),
                        Expanded(child: Text(Dars113.dialogue[i].studentA, textAlign: TextAlign.center, style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 15.5, height: 1.7, fontWeight: FontWeight.w600, color: c.accent))),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text('الآنَ: بَدِّلِ الدَّوْرَ وَاسْتَخْدِمْ كَلِمَاتٍ أُخْرَى مِنَ الْجَدْوَلِ. 🔄',
              style: TextStyle(fontFamily: AppTheme.instructionFont, fontSize: 14, color: c.textMuted)),
        ],
      ),
    );
  }
}
