import 'package:flutter/material.dart';
import '../../data/curriculum.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../common.dart';

class RuleCard extends StatelessWidget {
  const RuleCard({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: CardHeading('💡 قَاعِدَةٌ نَحْوِيَّةٌ أَسَاسِيَّةٌ')),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: c.goldSoft,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: c.goldBorder),
                ),
                child: Text('الجملة الاسمية', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: c.gold)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: c.goldSoft.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: c.goldBorder, width: 1.4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: c.goldBorder),
                  ),
                  child: Text(
                    Dars111.ruleFormula,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTheme.arabicFont,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: c.accent,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: c.goldBorder.withValues(alpha: 0.6)),
                ),
                Text(
                  Dars111.ruleP1,
                  style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 16, height: 1.8, color: c.text),
                ),
                const SizedBox(height: 8),
                Text(
                  Dars111.ruleP2,
                  style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 16, height: 1.8, color: c.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
