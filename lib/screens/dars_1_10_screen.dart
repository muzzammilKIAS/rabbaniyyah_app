import 'package:flutter/material.dart';
import '../data/curriculum.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/dars_1_10/analyze_card.dart';
import '../widgets/dars_1_10/reading_card.dart';
import '../widgets/dars_1_10/reflection_exit_card.dart';
import '../widgets/dars_1_10/rule_card.dart';
import '../widgets/dars_1_10/speaking_card.dart';
import '../widgets/dars_1_10/think_write_card.dart';
import '../widgets/dars_1_10/vocab_card.dart';
import '../widgets/lesson/lesson_shell.dart';

class Dars1110Screen extends StatelessWidget {
  const Dars1110Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return LessonShell(
      lesson: 10,
      breadcrumb: 'الفصل الأول ‹ الوحدة الرابعة: السيرة',
      title: 'الدرس العاشر — مولد النبي وحياته الأولى',
      hero: _Hero10(),
      sections: const [
        LessonSection(
          step: 'أقرأ وأفهم',
          divider: 'أقرأ وأفهم',
          icon: Icons.menu_book_outlined,
          children: [ReadingCard10()],
        ),
        LessonSection(
          step: 'كلمات وقاعدة',
          divider: 'جدول الكلمات والقاعدة',
          icon: Icons.view_list_outlined,
          children: [VocabCard10(), RuleCard10()],
        ),
        LessonSection(
          step: 'أتكلم',
          divider: 'أتكلم باللغة العربية',
          icon: Icons.forum_outlined,
          children: [SpeakingCard10()],
        ),
        LessonSection(
          step: 'أفكر وأكتب',
          divider: 'أفكر وأكتب',
          icon: Icons.edit_note_outlined,
          children: [ThinkWriteCard10()],
        ),
        LessonSection(
          step: 'أحلل وأطبق',
          divider: 'أحلل وأطبق',
          icon: Icons.groups_outlined,
          children: [AnalyzeCard10()],
        ),
        LessonSection(
          step: 'السيرة والحياة',
          divider: 'السيرة والحياة',
          icon: Icons.favorite_border,
          children: [ReflectionCard10()],
        ),
        LessonSection(
          step: 'الخاتمة',
          divider: 'الخاتمة',
          icon: Icons.flag_outlined,
          children: [ExitTicketCard10(), SelfAssessCard10(), SizedBox(height: 12), DictionaryCard10()],
        ),
      ],
      closingTitle: 'بحمد الله وتوفيقه تم الدرس العاشر',
      celebrationTitle: 'أَحْسَنْتَ! 🎉',
      celebrationMessage: 'أَتْمَمْتَ الدَّرْسَ الْعَاشِرَ: مَوْلِدُ النَّبِيِّ وَحَيَاتُهُ الْأُولَى',
    );
  }
}

class _Hero10 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: c.border),
        boxShadow: [BoxShadow(color: c.cardShadow, blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Wrap (not Row + Spacer): on a narrow phone the goal chip drops
          // under the unit chip instead of colliding with it.
          SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: c.accentSoft, borderRadius: BorderRadius.circular(999)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('📜', style: const TextStyle(fontSize: 13)),
                      const SizedBox(width: 6),
                      Text(
                        'الوحدة الرابعة: السيرة',
                        style: TextStyle(
                          fontFamily: AppTheme.uiFont,
                          fontSize: 12,
                          color: c.accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: c.goldSoft, borderRadius: BorderRadius.circular(999)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🎯', style: TextStyle(fontSize: 11.5)),
                      const SizedBox(width: 6),
                      Text(
                        'أهداف التعلم',
                        style: TextStyle(
                          fontFamily: AppTheme.uiFont,
                          fontSize: 11.5,
                          color: c.gold,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'مَوْلِدُ النَّبِيِّ وَحَيَاتُهُ الأُولَى',
            style: TextStyle(
              fontFamily: AppTheme.arabicFont,
              fontWeight: FontWeight.w800,
              fontSize: 30,
              color: c.accent,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'فِي نِهَايَةِ الدَّرْسِ، أَسْتَطِيعُ إِنْ شَاءَ اللهُ أَنْ:',
            style: TextStyle(fontFamily: AppTheme.instructionFont, fontSize: 17, color: c.gold),
          ),
          const SizedBox(height: 14),
          for (final o in Dars1110.objectives)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: c.surface2.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: c.border.withValues(alpha: 0.5)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(o.$1, style: const TextStyle(fontSize: 17)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        o.$2,
                        style: TextStyle(
                          fontFamily: AppTheme.instructionFont,
                          fontSize: 16.5,
                          height: 1.6,
                          color: c.text,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
