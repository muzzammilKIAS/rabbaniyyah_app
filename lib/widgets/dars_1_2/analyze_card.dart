import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/curriculum.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../common.dart';

/// أُحَلِّلُ وَأُطَبِّقُ — تَمْثِيلُ الْأَدْوَارِ: أَنَا أُؤْمِنُ بِأَنَّ...
class AnalyzeCard2 extends StatefulWidget {
  const AnalyzeCard2({super.key});

  @override
  State<AnalyzeCard2> createState() => _AnalyzeCard2State();
}

class _AnalyzeCard2State extends State<AnalyzeCard2> {
  late List<TextEditingController> _typeCtrls;
  late List<TextEditingController> _meaningCtrls;
  late TextEditingController _dialogueCtrl;

  @override
  void initState() {
    super.initState();
    final app = context.read<AppState>();
    _typeCtrls = List.generate(Dars112.analyzeNames.length, (i) => TextEditingController(text: app.dars112Get('analyzeType$i', '')));
    _meaningCtrls = List.generate(Dars112.analyzeNames.length, (i) => TextEditingController(text: app.dars112Get('analyzeMeaning$i', '')));
    _dialogueCtrl = TextEditingController(text: app.dars112Get('roleplay', ''));
  }

  @override
  void dispose() {
    for (final c in _typeCtrls) {
      c.dispose();
    }
    for (final c in _meaningCtrls) {
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
          const CardHeading('👥 تَمْثِيلُ الْأَدْوَارِ: أَنَا أُؤْمِنُ بِأَنَّ...'),
          const CardInstruction('أَوَّلًا، أَكْمِلِ الْجَدْوَلَ:'),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(color: c.surface2, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Expanded(flex: 2, child: Text('الاِسْمُ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: c.textMuted))),
                Expanded(flex: 2, child: Text('النَّوْعُ', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: c.textMuted))),
                Expanded(flex: 3, child: Text('التَّفْسِيرُ', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: c.textMuted))),
              ],
            ),
          ),
          const SizedBox(height: 6),
          for (var i = 0; i < Dars112.analyzeNames.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(Dars112.analyzeNames[i], style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 16, fontWeight: FontWeight.w700, color: c.accent)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: TextField(
                        controller: _typeCtrls[i],
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 15),
                        decoration: const InputDecoration(hintText: 'ملك / كتاب / رسول', isDense: true),
                        onChanged: (v) => context.read<AppState>().dars112Set('analyzeType$i', v),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _meaningCtrls[i],
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 15),
                      decoration: const InputDecoration(hintText: 'العمل أو المعنى', isDense: true),
                      onChanged: (v) => context.read<AppState>().dars112Set('analyzeMeaning$i', v),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 18),
          Text('ثَانِيًا، مَثِّلِ الْحِوَارَ مَعَ زَمِيلِكَ بِاسْتِخْدَامِ إِطَارِ الْكَلَامِ. طَالِبٌ (أ) دَاعِيَةٌ، طَالِبٌ (ب) يُصَحِّحُ أَوْ يُؤَكِّدُ.',
              style: TextStyle(fontFamily: AppTheme.instructionFont, fontSize: 14.5, color: c.textMuted, height: 1.6)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: c.goldSoft, borderRadius: BorderRadius.circular(10), border: Border.all(color: c.goldBorder)),
            child: Text('الطَّالِبُ (أ): أَنَا أُؤْمِنُ بِأَنَّ ______ (الِاسْمُ) ______ (نَوْعُهُ)، وَعَمَلُهُ/مَعْنَاهُ ______.',
                style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 15.5, height: 1.8, color: c.text)),
          ),
          const SizedBox(height: 8),
          Text('الطَّالِبُ (ب): نَعَمْ، صَحِيحٌ. إِنَّ...', style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 16, color: c.text)),
          const SizedBox(height: 6),
          TextField(
            controller: _dialogueCtrl,
            style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 16),
            decoration: const InputDecoration(hintText: 'اكتب هنا…'),
            onChanged: (v) => context.read<AppState>().dars112Set('roleplay', v),
          ),
        ],
      ),
    );
  }
}
