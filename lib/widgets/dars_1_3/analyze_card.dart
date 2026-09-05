import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/curriculum.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../common.dart';

/// أُحَلِّلُ وَأُطَبِّقُ — مُقَابَلَةٌ قَصِيرَةٌ: مُحَاكَاةُ التَّوَاصُلِ
class AnalyzeCard3 extends StatefulWidget {
  const AnalyzeCard3({super.key});

  @override
  State<AnalyzeCard3> createState() => _AnalyzeCard3State();
}

class _AnalyzeCard3State extends State<AnalyzeCard3> {
  late List<TextEditingController> _answerCtrls;
  late TextEditingController _dialogueCtrl;

  @override
  void initState() {
    super.initState();
    final app = context.read<AppState>();
    _answerCtrls = List.generate(Dars113.interviewQuestions.length, (i) => TextEditingController(text: app.dars113Get('interviewAnswer$i', '')));
    _dialogueCtrl = TextEditingController(text: app.dars113Get('roleplay', ''));
  }

  @override
  void dispose() {
    for (final c in _answerCtrls) {
      c.dispose();
    }
    _dialogueCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardHeading('🎙️ مُقَابَلَةٌ قَصِيرَةٌ: مُحَاكَاةُ التَّوَاصُلِ'),
          const CardInstruction('أَوَّلًا، اِسْتَعِدَّ لِلْمُقَابَلَةِ بِكِتَابَةِ إِجَابَتِكَ عَلَى كُلِّ سُؤَالٍ:'),
          const SizedBox(height: 14),
          for (var i = 0; i < Dars113.interviewQuestions.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(top: 2),
                        decoration: BoxDecoration(color: c.accentSoft, shape: BoxShape.circle),
                        child: Text('${i + 1}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: c.accent)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(Dars113.interviewQuestions[i],
                            style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 17, fontWeight: FontWeight.w700, color: c.text)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(right: 32),
                    child: TextField(
                      controller: _answerCtrls[i],
                      maxLines: 2,
                      minLines: 1,
                      style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 15.5, height: 1.6),
                      decoration: const InputDecoration(hintText: 'اكتب إجابتك هنا…'),
                      onChanged: (v) => context.read<AppState>().dars113Set('interviewAnswer$i', v),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Text('ثَانِيًا، مَثِّلِ الْمُقَابَلَةَ مَعَ زَمِيلِكَ بِاسْتِخْدَامِ إِطَارِ الْكَلَامِ. طَالِبٌ (أ) مُذِيعٌ، طَالِبٌ (ب) يُجِيبُ.',
              style: TextStyle(fontFamily: AppTheme.instructionFont, fontSize: 14.5, color: c.textMuted, height: 1.6)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: c.goldSoft, borderRadius: BorderRadius.circular(10), border: Border.all(color: c.goldBorder)),
            child: Text('اَلْمُذِيعُ: هَلْ تَرْضَى بِقَضَاءِ اللهِ؟',
                style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 15.5, height: 1.8, color: c.text)),
          ),
          const SizedBox(height: 8),
          Text('اَلطَّالِبُ: نَعَمْ، أَرْضَى بِقَضَاءِ اللهِ لِأَنَّ...', style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 16, color: c.text)),
          const SizedBox(height: 6),
          TextField(
            controller: _dialogueCtrl,
            style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 16),
            decoration: const InputDecoration(hintText: 'اكتب هنا…'),
            onChanged: (v) => context.read<AppState>().dars113Set('roleplay', v),
          ),
        ],
      ),
    );
  }
}
