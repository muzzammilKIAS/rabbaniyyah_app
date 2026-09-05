import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/curriculum.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../common.dart';

/// أُحَلِّلُ وَأُطَبِّقُ — مقابلة قصيرة: المقارنة بين الوضوء والغسل.
class AnalyzeCard4 extends StatefulWidget {
  const AnalyzeCard4({super.key});

  @override
  State<AnalyzeCard4> createState() => _AnalyzeCard4State();
}

class _AnalyzeCard4State extends State<AnalyzeCard4> {
  late TextEditingController _wuduCtrl;
  late TextEditingController _ghuslCtrl;

  @override
  void initState() {
    super.initState();
    final app = context.read<AppState>();
    _wuduCtrl = TextEditingController(text: app.dars114Get('compareWudu', ''));
    _ghuslCtrl = TextEditingController(text: app.dars114Get('compareGhusl', ''));
  }

  @override
  void dispose() {
    _wuduCtrl.dispose();
    _ghuslCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardHeading('👥 مُقَابَلَةٌ قَصِيرَةٌ — المُقَارَنَةُ بَيْنَ الوُضُوءِ وَالغُسْلِ'),
          const CardInstruction('اُنْظُرْ إِلَى الجَدْوَلِ، ثُمَّ نَاقِشْ مَعَ زَمِيلِكَ الفَرْقَ بَيْنَ الوُضُوءِ وَالغُسْلِ:'),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(color: c.surface2, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Expanded(flex: 2, child: Text('وَجْهُ المُقَارَنَةِ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: c.textMuted))),
                Expanded(flex: 3, child: Text('الوُضُوءُ', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: c.accent))),
                Expanded(flex: 3, child: Text('الغُسْلُ', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: c.gold))),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Table(
            columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(3), 2: FlexColumnWidth(3)},
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              for (final row in Dars114.compareRows)
                TableRow(
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.border.withValues(alpha: 0.6)))),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                      child: Text(row.aspect, style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 14.5, fontWeight: FontWeight.w700, color: c.text)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                      child: Text(row.wudu, textAlign: TextAlign.center, style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 14.5, color: c.text)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                      child: Text(row.ghusl, textAlign: TextAlign.center, style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 14.5, color: c.text)),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 18),
          Text('📖 إِطَارُ الكِتَابَةِ', style: TextStyle(fontFamily: AppTheme.uiFont, fontSize: 14, fontWeight: FontWeight.w700, color: c.gold)),
          const SizedBox(height: 8),
          Text('أَكْمِلِ الجُمْلَتَيْنِ الآتِيَتَيْنِ بِأُسْلُوبِكَ:',
              style: TextStyle(fontFamily: AppTheme.instructionFont, fontSize: 14.5, color: c.textMuted)),
          const SizedBox(height: 10),
          Text('هَذَا الوُضُوءُ ____________ لِأَنَّهُ:', style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 16, color: c.text)),
          const SizedBox(height: 6),
          TextField(
            controller: _wuduCtrl,
            style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 16),
            decoration: const InputDecoration(hintText: 'اكتب هنا…'),
            onChanged: (v) => context.read<AppState>().dars114Set('compareWudu', v),
          ),
          const SizedBox(height: 14),
          Text('هَذَا الغُسْلُ ____________ لِأَنَّهُ:', style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 16, color: c.text)),
          const SizedBox(height: 6),
          TextField(
            controller: _ghuslCtrl,
            style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 16),
            decoration: const InputDecoration(hintText: 'اكتب هنا…'),
            onChanged: (v) => context.read<AppState>().dars114Set('compareGhusl', v),
          ),
        ],
      ),
    );
  }
}
