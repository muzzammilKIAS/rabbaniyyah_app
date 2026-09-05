import 'package:flutter/material.dart';
import '../../data/curriculum.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../common.dart';

class RuleCard2 extends StatelessWidget {
  const RuleCard2({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardHeading('💡 قَاعِدَةٌ'),
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
                Text(Dars112.ruleFormula,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 19, fontWeight: FontWeight.w700, color: c.accent2)),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Divider(color: c.accent2.withValues(alpha: 0.35)),
                ),
                Text(Dars112.ruleP1, style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 15, height: 1.8, color: c.text)),
                const SizedBox(height: 6),
                Text(Dars112.ruleP2, style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 15, height: 1.8, color: c.text)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: c.surface2, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Expanded(child: Text('الْمُبْتَدَأُ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: c.textMuted))),
                Expanded(child: Text('الْخَبَرُ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: c.textMuted))),
                Expanded(flex: 2, child: Text('الجُمْلَةُ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: c.textMuted))),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Table(
            columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(1), 2: FlexColumnWidth(2)},
            children: [
              for (final row in Dars112.ruleTable)
                TableRow(
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.border.withValues(alpha: 0.6)))),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      child: Text(row.$1, style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 15, fontWeight: FontWeight.w700, color: c.accent2)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      child: Text(row.$2, style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 15, color: c.text)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      child: Text('${row.$1} ${row.$2}', style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 15, color: c.textMuted)),
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
