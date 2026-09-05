import 'package:flutter/material.dart';
import '../../data/curriculum.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../common.dart';

class RuleCard3 extends StatelessWidget {
  const RuleCard3({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeading('💡 قَاعِدَةٌ: ${Dars113.ruleTitle}'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: c.accent2Soft,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: c.accent2.withValues(alpha: 0.35)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(Dars113.ruleIntro, style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 15, height: 1.8, color: c.text)),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Divider(color: c.accent2.withValues(alpha: 0.35)),
                ),
                Text(Dars113.rulePattern1,
                    style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 16.5, fontWeight: FontWeight.w700, color: c.accent2)),
                const SizedBox(height: 6),
                Text(Dars113.rulePattern2,
                    style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 16.5, fontWeight: FontWeight.w700, color: c.accent2)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: c.surface2, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Expanded(child: Text('النَّمَطُ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: c.textMuted))),
                Expanded(flex: 2, child: Text('السُّؤَالُ', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: c.textMuted))),
                Expanded(flex: 2, child: Text('الجَوَابُ', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: c.textMuted))),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Table(
            columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(2), 2: FlexColumnWidth(2)},
            children: [
              for (final row in Dars113.ruleTable)
                TableRow(
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.border.withValues(alpha: 0.6)))),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      child: Text(row.$1, style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 13.5, fontWeight: FontWeight.w700, color: c.accent2)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      child: Text(row.$2, style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 15, color: c.text)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      child: Text(row.$3, style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 15, color: c.textMuted)),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
