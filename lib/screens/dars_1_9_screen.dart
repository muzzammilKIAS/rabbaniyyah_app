import 'package:flutter/material.dart';
import '../data/curriculum.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/dars_1_9/analyze_card.dart';
import '../widgets/dars_1_9/reading_card.dart';
import '../widgets/dars_1_9/reflection_exit_card.dart';
import '../widgets/dars_1_9/rule_card.dart';
import '../widgets/dars_1_9/speaking_card.dart';
import '../widgets/dars_1_9/think_write_card.dart';
import '../widgets/dars_1_9/vocab_card.dart';
import '../widgets/lesson/lesson_shell.dart';

class Dars119Screen extends StatelessWidget {
  const Dars119Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return LessonShell(
      lesson: 9,
      breadcrumb: 'الفصل الأول ‹ الوحدة الثالثة: الأخلاق',
      title: 'الدرس التاسع — الأخلاق في الأسرة والمجتمع',
      hero: _Hero9(),
      sections: const [
        LessonSection(
          step: 'أقرأ وأفهم',
          divider: 'أقرأ وأفهم',
          icon: Icons.menu_book_outlined,
          children: [ReadingCard9()],
        ),
        LessonSection(
          step: 'كلمات وقاعدة',
          divider: 'جدول الكلمات والقاعدة',
          icon: Icons.view_list_outlined,
          children: [VocabCard9(), RuleCard9()],
        ),
        LessonSection(
          step: 'أتكلم',
          divider: 'أتكلم باللغة العربية',
          icon: Icons.forum_outlined,
          children: [SpeakingCard9()],
        ),
        LessonSection(
          step: 'أفكر وأكتب',
          divider: 'أفكر وأكتب',
          icon: Icons.edit_note_outlined,
          children: [ThinkWriteCard9()],
        ),
        LessonSection(
          step: 'أحلل وأطبق',
          divider: 'أحلل وأطبق',
          icon: Icons.groups_outlined,
          children: [AnalyzeCard9()],
        ),
        LessonSection(
          step: 'الأخلاق والحياة',
          divider: 'الأخلاق والحياة',
          icon: Icons.favorite_border,
          children: [ReflectionCard9()],
        ),
        LessonSection(
          step: 'الخاتمة',
          divider: 'الخاتمة',
          icon: Icons.flag_outlined,
          children: [ExitTicketCard9(), SelfAssessCard9(), SizedBox(height: 12), DictionaryCard9()],
        ),
      ],
      closingTitle: 'بحمد الله وتوفيقه تم الدرس التاسع',
      celebrationTitle: 'أَحْسَنْتَ! 🎉',
      celebrationMessage: 'أَتْمَمْتَ الدَّرْسَ التَّاسِعَ: الْأَخْلَاقُ فِي الْأُسْرَةِ وَالْمُجْتَمَعِ',
    );
  }
}

class _Hero9 extends StatelessWidget {
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
                      Text('🌙', style: const TextStyle(fontSize: 13)),
                      const SizedBox(width: 6),
                      Text(
                        'الوحدة الثالثة: الأخلاق',
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
            'الأَخْلَاقُ فِي الأُسْرَةِ وَالمُجْتَمَعِ',
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
          for (final o in Dars119.objectives)
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
