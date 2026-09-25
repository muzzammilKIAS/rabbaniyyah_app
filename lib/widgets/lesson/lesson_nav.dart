import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/lesson_catalog.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../utils/arabic_text.dart';
import '../../utils/lesson_router.dart';
import '../dars1/celebration_dialog.dart';
import 'lesson_status.dart';

/// End-of-lesson summary: combined progress, what counts towards it, and
/// the two student actions — mark the lesson finished, and flag it for
/// revision.
class LessonCompletionPanel extends StatelessWidget {
  const LessonCompletionPanel({super.key, required this.lesson});
  final int lesson;

  Future<void> _toggleComplete(BuildContext context) async {
    final app = context.read<AppState>();
    final meta = lessonByN(lesson)!;
    final wasDone = app.isCompleted(lesson);
    app.setCompleted(lesson, !wasDone);
    if (wasDone) return;
    if (app.unitCompleted(meta.unit) && !app.unitCelebrated(meta.unit)) {
      app.markUnitCelebrated(meta.unit);
      await CelebrationDialog.show(
        context,
        title: 'أَحْسَنْتَ! 🎉',
        message: 'Tahniah! Semua pelajaran dalam ${meta.unitInfo.title}: ${meta.unitInfo.topic} telah selesai.',
        badge: 'أتممت ${meta.unitInfo.title}',
        confetti: true,
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pelajaran ditanda selesai · +50 XP'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final app = context.watch<AppState>();
    final meta = lessonByN(lesson);
    if (meta == null) return const SizedBox.shrink();
    final progress = app.lessonProgress(lesson);
    final done = app.isCompleted(lesson);
    final marked = app.isBookmarked(lesson);
    final selfDone = (app.selfAssessFraction(lesson) * meta.selfAssessCount).round();

    Widget stat(IconData icon, String label, String value) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: c.textMuted),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(fontFamily: AppTheme.uiFont, fontSize: 13, color: c.textMuted),
        ),
        Text(
          value,
          style: TextStyle(fontFamily: AppTheme.uiFont, fontSize: 13, fontWeight: FontWeight.w800, color: c.text),
        ),
      ],
    );

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: done ? c.success.withValues(alpha: 0.5) : c.border),
        boxShadow: [BoxShadow(color: c.cardShadow, blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                ProgressRing(value: progress, size: 64, stroke: 6, color: done ? c.success : c.accent),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            'Ringkasan kemajuan',
                            style: TextStyle(
                              fontFamily: AppTheme.uiFont,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: c.text,
                            ),
                          ),
                          LessonStatusChip(status: app.lessonStatus(lesson)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 16,
                        runSpacing: 6,
                        children: [
                          stat(Icons.fact_check_outlined, 'Penilaian kendiri', '$selfDone / ${meta.selfAssessCount}'),
                          stat(
                            Icons.fitness_center_rounded,
                            'Latihan',
                            '${app.exercisesDone(lesson)} / ${app.exercisesTotal(lesson)}',
                          ),
                          stat(Icons.star_rounded, 'Bintang', '${app.starsForLesson(lesson)}'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _toggleComplete(context),
                  icon: Icon(done ? Icons.undo_rounded : Icons.check_circle_outline_rounded, size: 18),
                  label: Text(done ? 'Batal tanda selesai' : 'Tandakan pelajaran selesai'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 46),
                    backgroundColor: done ? c.surface2 : c.accent,
                    foregroundColor: done ? c.text : Colors.white,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.read<AppState>().toggleBookmark(lesson),
                  icon: Icon(marked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, size: 18, color: c.gold),
                  label: Text(marked ? 'Ditanda untuk ulang kaji' : 'Tandakan untuk ulang kaji'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 46),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Kemajuan = separuh daripada penilaian kendiri (الخاتمة) + separuh daripada Aktiviti Pengukuhan. '
              'Disimpan dalam pelayar ini sahaja.',
              style: TextStyle(fontFamily: AppTheme.uiFont, fontSize: 12, height: 1.5, color: c.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

/// Previous / next lesson cards, plus "back to units" at either end.
class LessonPager extends StatelessWidget {
  const LessonPager({super.key, required this.lesson});
  final int lesson;

  @override
  Widget build(BuildContext context) {
    final i = kLessons.indexWhere((l) => l.n == lesson);
    if (i < 0) return const SizedBox.shrink();
    final prev = i > 0 ? kLessons[i - 1] : null;
    final next = i < kLessons.length - 1 ? kLessons[i + 1] : null;

    return LayoutBuilder(
      builder: (context, box) {
        final wide = box.maxWidth >= 560;
        final prevCard = _PagerCard(
          caption: 'الدرس السابق',
          title: prev == null ? 'الرجوع إلى القائمة' : stripTashkeel(prev.title),
          icon: Icons.arrow_back_rounded,
          leading: true,
          onTap: prev == null ? () => Navigator.of(context).pop() : () => openLesson(context, prev.n, replace: true),
        );
        final nextCard = _PagerCard(
          caption: next == null ? 'نهاية الفصل الأول' : 'الدرس التالي',
          title: next == null ? 'الرجوع إلى القائمة' : stripTashkeel(next.title),
          icon: Icons.arrow_forward_rounded,
          leading: false,
          primary: true,
          onTap: next == null ? () => Navigator.of(context).pop() : () => openLesson(context, next.n, replace: true),
        );
        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: wide
              ? Row(
                  children: [
                    Expanded(child: prevCard),
                    const SizedBox(width: 12),
                    Expanded(child: nextCard),
                  ],
                )
              : Column(children: [nextCard, const SizedBox(height: 10), prevCard]),
        );
      },
    );
  }
}

class _PagerCard extends StatelessWidget {
  const _PagerCard({
    required this.caption,
    required this.title,
    required this.icon,
    required this.leading,
    required this.onTap,
    this.primary = false,
  });
  final String caption;
  final String title;
  final IconData icon;
  final bool leading;
  final bool primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fg = primary ? Colors.white : c.text;
    final arrow = Icon(icon, color: primary ? Colors.white : c.accent);
    return Material(
      color: primary ? c.accent : c.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: primary ? c.accent : c.border),
          ),
          child: Row(
            children: [
              if (leading) ...[arrow, const SizedBox(width: 12)],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      caption,
                      style: TextStyle(
                        fontFamily: AppTheme.uiFont,
                        fontSize: 12,
                        color: primary ? Colors.white70 : c.textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTheme.uiFont,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: fg,
                      ),
                    ),
                  ],
                ),
              ),
              if (!leading) ...[const SizedBox(width: 12), arrow],
            ],
          ),
        ),
      ),
    );
  }
}
