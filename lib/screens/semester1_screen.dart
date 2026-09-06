import 'package:flutter/material.dart';
import '../data/curriculum.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/arabic_text.dart';
import '../widgets/atmosphere.dart';
import '../widgets/common.dart';
import 'dars_1_1_screen.dart';
import 'dars_1_2_screen.dart';
import 'dars_1_3_screen.dart';
import 'dars_1_4_screen.dart';
import 'dars_1_5_screen.dart';
import 'dars_1_6_screen.dart';
import 'dars_1_7_screen.dart';
import 'dars_1_8_screen.dart';

/// Maps each lesson to its own screen by lesson number (LessonRef.n),
/// not by list position.
Widget _screenForLesson(int n) {
  return switch (n) {
    2 => const Dars112Screen(),
    3 => const Dars113Screen(),
    4 => const Dars114Screen(),
    5 => const Dars115Screen(),
    6 => const Dars116Screen(),
    7 => const Dars117Screen(),
    8 => const Dars118Screen(),
    _ => const Dars111Screen(),
  };
}

class Semester1Screen extends StatefulWidget {
  const Semester1Screen({super.key});

  @override
  State<Semester1Screen> createState() => _Semester1ScreenState();
}

class _Semester1ScreenState extends State<Semester1Screen> with SingleTickerProviderStateMixin {
  late final AnimationController _entrance;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n = kSemester1Units.length;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('الفصل الدراسي الأول'),
          actions: const [ThemeToggleButton()],
        ),
        body: PageBackdrop(
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                  children: [
                    Staggered(
                      controller: _entrance,
                      start: 0,
                      end: 0.5,
                      child: Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: context.colors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: context.colors.border),
                          boxShadow: [
                            BoxShadow(color: context.colors.cardShadow, blurRadius: 16, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: context.colors.accentSoft,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '١',
                                style: TextStyle(
                                  fontFamily: AppTheme.quranFont,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: context.colors.accent,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'اللغة العربية الربانية ١',
                                    style: TextStyle(
                                      fontFamily: AppTheme.uiFont,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 20,
                                      color: context.colors.text,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'أربع وحدات تعليمية · اثنا عشر درسا تطبيقيا',
                                    style: TextStyle(
                                      fontFamily: AppTheme.uiFont,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: context.colors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    for (var i = 0; i < n; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Staggered(
                          controller: _entrance,
                          start: 0.1 + i * (0.6 / n),
                          end: 0.55 + i * (0.6 / n),
                          child: _UnitCard(unit: kSemester1Units[i]),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UnitCard extends StatelessWidget {
  const _UnitCard({required this.unit});
  final UnitInfo unit;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.border),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: c.cardShadow, blurRadius: 14, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: c.accentSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(unit.icon, style: const TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 12),
                Text(
                  unit.title,
                  style: TextStyle(
                    fontFamily: AppTheme.uiFont,
                    fontWeight: FontWeight.w800,
                    fontSize: 16.5,
                    color: c.text,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: c.goldSoft,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    unit.topic,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: c.gold,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: c.border.withValues(alpha: 0.7)),
          for (var i = 0; i < unit.lessons.length; i++) ...[
            _LessonRow(lesson: unit.lessons[i]),
            if (i != unit.lessons.length - 1)
              Divider(height: 1, indent: 20, endIndent: 20, color: c.border.withValues(alpha: 0.5)),
          ],
        ],
      ),
    );
  }
}

class _LessonRow extends StatefulWidget {
  const _LessonRow({required this.lesson});
  final LessonRef lesson;

  @override
  State<_LessonRow> createState() => _LessonRowState();
}

class _LessonRowState extends State<_LessonRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final lesson = widget.lesson;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        color: (_hover && lesson.enabled) ? c.accentSoft.withValues(alpha: 0.45) : Colors.transparent,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: lesson.enabled
                ? () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => _screenForLesson(lesson.n)),
                    )
                : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Opacity(
                opacity: lesson.enabled ? 1 : 0.55,
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: lesson.enabled ? c.accent : c.surface2,
                      ),
                      child: Text(
                        toArabicNumerals(lesson.n),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: lesson.enabled ? Colors.white : c.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        stripTashkeel(lesson.title),
                        style: TextStyle(
                          fontFamily: AppTheme.uiFont,
                          fontSize: 15.5,
                          fontWeight: lesson.enabled ? FontWeight.w700 : FontWeight.normal,
                          color: c.text,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (lesson.enabled)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: c.accentSoft,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'ادخل الآن',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: c.accent,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.arrow_back_rounded, size: 14, color: c.accent),
                          ],
                        ),
                      )
                    else
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock_outline_rounded, size: 13, color: c.textMuted),
                          const SizedBox(width: 4),
                          Text('قريبا', style: TextStyle(fontSize: 12, color: c.textMuted)),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
