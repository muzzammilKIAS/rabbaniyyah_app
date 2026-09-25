import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/curriculum.dart';
import '../data/lesson_catalog.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/arabic_text.dart';
import '../utils/lesson_router.dart';
import '../widgets/atmosphere.dart';
import '../widgets/common.dart';
import '../widgets/lesson/lesson_status.dart';
import 'search_screen.dart';

void openSearch(BuildContext context) =>
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SearchScreen()));

class Semester1Screen extends StatefulWidget {
  const Semester1Screen({super.key, this.reviewOnly = false});

  /// Start with the "Ulang kaji" (bookmarked lessons) filter on.
  final bool reviewOnly;

  @override
  State<Semester1Screen> createState() => _Semester1ScreenState();
}

class _Semester1ScreenState extends State<Semester1Screen> with SingleTickerProviderStateMixin {
  late final AnimationController _entrance;
  late bool _reviewOnly = widget.reviewOnly;

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
    final c = context.colors;
    final app = context.watch<AppState>();
    final n = kSemester1Units.length;
    final bookmarks = app.bookmarks;
    final width = MediaQuery.sizeOf(context).width;
    final twoCol = width >= 980;

    final unitCards = <Widget>[
      for (var i = 0; i < n; i++)
        if (!_reviewOnly || kSemester1Units[i].lessons.any((l) => bookmarks.contains(l.n)))
          Staggered(
            controller: _entrance,
            start: 0.1 + i * (0.6 / n),
            end: 0.55 + i * (0.6 / n),
            child: _UnitCard(unitIndex: i, reviewOnly: _reviewOnly),
          ),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('الفصل الدراسي الأول'),
          actions: [
            IconButton(tooltip: 'Cari', icon: const Icon(Icons.search_rounded), onPressed: () => openSearch(context)),
            const FullscreenToggleButton(),
            const ThemeToggleButton(),
          ],
        ),
        body: PageBackdrop(
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: twoCol ? 1180 : 760),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
                  children: [
                    Staggered(controller: _entrance, start: 0, end: 0.5, child: const _BookHeader()),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        ChoiceChip(
                          label: const Text('Semua unit'),
                          selected: !_reviewOnly,
                          onSelected: (_) => setState(() => _reviewOnly = false),
                        ),
                        ChoiceChip(
                          avatar: Icon(Icons.bookmark_rounded, size: 16, color: c.gold),
                          label: Text('Ulang kaji (${bookmarks.length})'),
                          selected: _reviewOnly,
                          onSelected: (_) => setState(() => _reviewOnly = true),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (_reviewOnly && unitCards.isEmpty)
                      _EmptyReview(onShowAll: () => setState(() => _reviewOnly = false))
                    else if (twoCol)
                      _TwoColumn(children: unitCards)
                    else
                      for (final w in unitCards) Padding(padding: const EdgeInsets.only(bottom: 16), child: w),
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

class _TwoColumn extends StatelessWidget {
  const _TwoColumn({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += 2) {
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: children[i]),
              const SizedBox(width: 16),
              Expanded(child: i + 1 < children.length ? children[i + 1] : const SizedBox.shrink()),
            ],
          ),
        ),
      );
    }
    return Column(children: rows);
  }
}

class _BookHeader extends StatelessWidget {
  const _BookHeader();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final app = context.watch<AppState>();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.border),
        boxShadow: [BoxShadow(color: c.cardShadow, blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(color: c.accentSoft, borderRadius: BorderRadius.circular(14)),
                alignment: Alignment.center,
                child: Text(
                  '١',
                  style: TextStyle(
                    fontFamily: AppTheme.quranFont,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: c.accent,
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
                        color: c.text,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'أربع وحدات تعليمية · اثنا عشر درسا تطبيقيا',
                      style: TextStyle(
                        fontFamily: AppTheme.uiFont,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: c.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              ProgressRing(value: app.overallProgress, size: 56, stroke: 5),
            ],
          ),
          const SizedBox(height: 14),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Wrap(
              spacing: 18,
              runSpacing: 6,
              children: [
                _Metric(
                  icon: Icons.check_circle_outline_rounded,
                  text: '${app.completedCount} / ${kLessons.length} pelajaran selesai',
                ),
                _Metric(
                  icon: Icons.fitness_center_rounded,
                  text: '${app.totalExercisesDone} / ${app.totalExercises} latihan',
                ),
                _Metric(icon: Icons.bolt_rounded, text: '${app.xp} XP', color: c.gold),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Material(
            color: c.surface2,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => openSearch(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded, color: c.textMuted),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'ابحث عن درس أو كلمة · Cari pelajaran atau perkataan',
                        style: TextStyle(fontFamily: AppTheme.uiFont, fontSize: 13.5, color: c.textMuted),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.text, this.color});
  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color ?? c.accent),
        const SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(fontFamily: AppTheme.uiFont, fontSize: 13, fontWeight: FontWeight.w700, color: c.text),
        ),
      ],
    );
  }
}

class _EmptyReview extends StatelessWidget {
  const _EmptyReview({required this.onShowAll});
  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.border),
      ),
      child: Column(
        children: [
          Icon(Icons.bookmark_border_rounded, size: 40, color: c.gold),
          const SizedBox(height: 10),
          Text(
            'Belum ada pelajaran ditanda untuk ulang kaji.\nTekan ikon penanda buku di dalam pelajaran untuk menambahnya di sini.',
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
            style: TextStyle(fontFamily: AppTheme.uiFont, color: c.textMuted, height: 1.6),
          ),
          const SizedBox(height: 12),
          TextButton(onPressed: onShowAll, child: const Text('Papar semua unit')),
        ],
      ),
    );
  }
}

class _UnitCard extends StatelessWidget {
  const _UnitCard({required this.unitIndex, required this.reviewOnly});
  final int unitIndex;
  final bool reviewOnly;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final app = context.watch<AppState>();
    final unit = kSemester1Units[unitIndex];
    final progress = app.unitProgress(unitIndex);
    final done = unit.lessons.where((l) => app.isCompleted(l.n)).length;
    final lessons = reviewOnly ? unit.lessons.where((l) => app.isBookmarked(l.n)).toList() : unit.lessons;

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: app.unitCompleted(unitIndex) ? c.success.withValues(alpha: 0.5) : c.border),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: c.cardShadow, blurRadius: 14, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: c.accentSoft, borderRadius: BorderRadius.circular(12)),
                      child: Icon(unitIcon(unitIndex), color: c.accent, size: 21),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 10,
                        runSpacing: 4,
                        children: [
                          Semantics(
                            header: true,
                            child: Text(
                              unit.title,
                              style: TextStyle(
                                fontFamily: AppTheme.uiFont,
                                fontWeight: FontWeight.w800,
                                fontSize: 16.5,
                                color: c.text,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(color: c.goldSoft, borderRadius: BorderRadius.circular(999)),
                            child: Text(
                              unit.topic,
                              style: TextStyle(fontSize: 11.5, color: c.gold, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${(progress * 100).round()}٪',
                      style: TextStyle(fontWeight: FontWeight.w800, color: c.accent, fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(end: progress),
                    duration: (MediaQuery.maybeDisableAnimationsOf(context) ?? false)
                        ? Duration.zero
                        : const Duration(milliseconds: 600),
                    builder: (context, v, _) => LinearProgressIndicator(
                      value: v,
                      minHeight: 6,
                      backgroundColor: c.border,
                      valueColor: AlwaysStoppedAnimation(app.unitCompleted(unitIndex) ? c.success : c.accent),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$done / ${unit.lessons.length} pelajaran selesai',
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.right,
                  style: TextStyle(fontFamily: AppTheme.uiFont, fontSize: 12, color: c.textMuted),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: c.border.withValues(alpha: 0.7)),
          for (var i = 0; i < lessons.length; i++) ...[
            _LessonRow(lesson: lessons[i]),
            if (i != lessons.length - 1)
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
    final app = context.watch<AppState>();
    final lesson = widget.lesson;
    final meta = lessonByN(lesson.n);
    final status = app.lessonStatus(lesson.n);
    final st = lessonStatusStyle(context, status);
    final narrow = MediaQuery.sizeOf(context).width < 420;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        color: (_hover && lesson.enabled) ? c.accentSoft.withValues(alpha: 0.45) : Colors.transparent,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: lesson.enabled ? () => openLesson(context, lesson.n) : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
              child: Opacity(
                opacity: lesson.enabled ? 1 : 0.55,
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: status == LessonStatus.completed ? c.success : (lesson.enabled ? c.accent : c.surface2),
                      ),
                      child: status == LessonStatus.completed
                          ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
                          : Text(
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stripTashkeel(lesson.title),
                            style: TextStyle(
                              fontFamily: AppTheme.uiFont,
                              fontSize: 15.5,
                              fontWeight: lesson.enabled ? FontWeight.w700 : FontWeight.normal,
                              color: c.text,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              LessonStatusChip(status: status),
                              if (meta != null && meta.hasVideo)
                                Tooltip(
                                  message: 'Ada video pengenalan',
                                  child: Icon(Icons.smart_display_outlined, size: 17, color: c.textMuted),
                                ),
                              if (app.isBookmarked(lesson.n))
                                Tooltip(
                                  message: 'Ditanda untuk ulang kaji',
                                  child: Icon(Icons.bookmark_rounded, size: 17, color: c.gold),
                                ),
                              if (app.exercisesDone(lesson.n) > 0)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.star_rounded, size: 15, color: c.gold),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${app.starsForLesson(lesson.n)}',
                                      style: TextStyle(fontSize: 12, color: c.textMuted, fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (lesson.enabled)
                      narrow
                          ? Icon(Icons.arrow_back_rounded, size: 18, color: st.fg == c.textMuted ? c.accent : st.fg)
                          : Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: c.accentSoft, borderRadius: BorderRadius.circular(999)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'ادخل الآن',
                                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: c.accent),
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
