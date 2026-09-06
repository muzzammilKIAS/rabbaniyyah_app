import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/curriculum.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../common.dart';

/// أُحَلِّلُ وَأُطَبِّقُ — مقابلة قصيرة، ثم إطار كتابة حر.
class AnalyzeCard11 extends StatefulWidget {
  const AnalyzeCard11({super.key});

  @override
  State<AnalyzeCard11> createState() => _AnalyzeCard11State();
}

class _AnalyzeCard11State extends State<AnalyzeCard11> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    final app = context.read<AppState>();
    _ctrl = TextEditingController(text: app.dars1111Get('compareWriting', ''));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final rows = Dars1111.compareLeft.length > Dars1111.compareRight.length
        ? Dars1111.compareLeft.length
        : Dars1111.compareRight.length;
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeading('👥 مُقَابَلَةٌ قَصِيرَةٌ — ${Dars1111.compareTitle}'),
          const SizedBox(height: 4),
          const CardInstruction('اُنْظُرْ إِلَى الجَدْوَلِ، ثُمَّ نَاقِشْ مَعَ زَمِيلِكَ:'),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(color: c.surface2, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Expanded(child: Text(Dars1111.compareLeftLabel, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: c.accent))),
                Expanded(child: Text(Dars1111.compareRightLabel, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: c.gold))),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Table(
            columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(1)},
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              for (var i = 0; i < rows; i++)
                TableRow(
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.border.withValues(alpha: 0.6)))),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                      child: Text(
                        i < Dars1111.compareLeft.length ? Dars1111.compareLeft[i] : '—',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 14.5, color: c.text),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                      child: Text(
                        i < Dars1111.compareRight.length ? Dars1111.compareRight[i] : '—',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 14.5, color: c.text),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 18),
          Text('📖 إِطَارُ الكِتَابَةِ', style: TextStyle(fontFamily: AppTheme.uiFont, fontSize: 14, fontWeight: FontWeight.w700, color: c.gold)),
          const SizedBox(height: 8),
          Text('${Dars1111.writingFramePrefix} ______________ ${Dars1111.writingFrameJoiner}:',
              style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 16, height: 1.6, color: c.text)),
          const SizedBox(height: 6),
          TextField(
            controller: _ctrl,
            maxLines: 2,
            minLines: 1,
            style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 16),
            decoration: const InputDecoration(hintText: 'اكتب هنا…'),
            onChanged: (v) => context.read<AppState>().dars1111Set('compareWriting', v),
          ),
        ],
      ),
    );
  }
}
