import 'package:flutter/material.dart';
import '../data/curriculum.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/dars_1_11/analyze_card.dart';
import '../widgets/dars_1_11/reading_card.dart';
import '../widgets/dars_1_11/reflection_exit_card.dart';
import '../widgets/dars_1_11/rule_card.dart';
import '../widgets/dars_1_11/speaking_card.dart';
import '../widgets/dars_1_11/think_write_card.dart';
import '../widgets/dars_1_11/vocab_card.dart';
import '../widgets/lesson/lesson_shell.dart';

class Dars1111Screen extends StatelessWidget {
  const Dars1111Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return LessonShell(
      lesson: 11,
      breadcrumb: 'الفصل الأول ‹ الوحدة الرابعة: السيرة',
      title: 'الدرس الحادي عشر — الإسراء والمعراج والهجرة',
      hero: _Hero11(),
      sections: const [
        LessonSection(
          step: 'أقرأ وأفهم',
          divider: 'أقرأ وأفهم',
          icon: Icons.menu_book_outlined,
          children: [ReadingCard11()],
        ),
        LessonSection(
          step: 'كلمات وقاعدة',
          divider: 'جدول الكلمات والقاعدة',
          icon: Icons.view_list_outlined,
          children: [VocabCard11(), RuleCard11()],
        ),
        LessonSection(
          step: 'أتكلم',
          divider: 'أتكلم باللغة العربية',
          icon: Icons.forum_outlined,
          children: [SpeakingCard11()],
        ),
        LessonSection(
          step: 'أفكر وأكتب',
          divider: 'أفكر وأكتب',
          icon: Icons.edit_note_outlined,
          children: [ThinkWriteCard11()],
        ),
        LessonSection(
          step: 'أحلل وأطبق',
          divider: 'أحلل وأطبق',
          icon: Icons.groups_outlined,
          children: [AnalyzeCard11()],
        ),
        LessonSection(
          step: 'السيرة والحياة',
          divider: 'السيرة والحياة',
          icon: Icons.favorite_border,
          children: [ReflectionCard11()],
        ),
        LessonSection(
          step: 'الخاتمة',
          divider: 'الخاتمة',
          icon: Icons.flag_outlined,
          children: [ExitTicketCard11(), SelfAssessCard11(), SizedBox(height: 12), DictionaryCard11()],
        ),
      ],
      closingTitle: 'بحمد الله وتوفيقه تم الدرس الحادي عشر',
      celebrationTitle: 'أَحْسَنْتَ! 🎉',
      celebrationMessage: 'أَتْمَمْتَ الدَّرْسَ الْحَادِيَ عَشَرَ: الْإِسْرَاءُ وَالْمِعْرَاجُ وَالْهِجْرَةُ',
    );
  }
}

class _Hero11 extends StatelessWidget {
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
            'الْإِسْرَاءُ وَالْمِعْرَاجُ وَالْهِجْرَةُ',
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
          for (final o in Dars1111.objectives)
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
