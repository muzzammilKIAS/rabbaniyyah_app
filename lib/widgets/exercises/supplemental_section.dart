import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/exercise_models.dart';
import '../../data/supplemental_exercises.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import 'arrange_exercises.dart';
import 'choice_exercises.dart';
import 'exercise_frame.dart';

/// Renders one [ExerciseSpec] inside its [ExerciseFrame].
class SupplementalExerciseCard extends StatelessWidget {
  const SupplementalExerciseCard({super.key, required this.lesson, required this.spec, required this.index});
  final int lesson;
  final ExerciseSpec spec;
  final int index;

  @override
  Widget build(BuildContext context) {
    final body = switch (spec) {
      final McqExercise s => McqExerciseView(lesson: lesson, spec: s),
      final TrueFalseExercise s => TrueFalseExerciseView(lesson: lesson, spec: s),
      final CategorizeExercise s => CategorizeExerciseView(lesson: lesson, spec: s),
      final SequenceExercise s => SequenceExerciseView(lesson: lesson, spec: s),
      final FlashcardExercise s => FlashcardExerciseView(lesson: lesson, spec: s),
      final PairMatchExercise s => PairMatchExerciseView(lesson: lesson, spec: s),
    };
    return ExerciseFrame(lesson: lesson, spec: spec, index: index, child: body);
  }
}

/// The "تدريبات إضافية · Aktiviti Pengukuhan" block of a lesson: a header
/// that states plainly these are supplemental (not the original text),
/// live progress, then every exercise. Renders nothing for a lesson that
/// has no exercises.
class SupplementalSection extends StatelessWidget {
  const SupplementalSection({super.key, required this.lesson});
  final int lesson;

  @override
  Widget build(BuildContext context) {
    final specs = exercisesFor(lesson);
    if (specs.isEmpty) return const SizedBox.shrink();
    final c = context.colors;
    final app = context.watch<AppState>();
    final done = app.exercisesDone(lesson);
    final stars = app.starsForLesson(lesson);
    final total = specs.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: c.accentSoft.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: c.accent.withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(color: c.accent, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.fitness_center_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تدريبات إضافية',
                          style: TextStyle(
                            fontFamily: AppTheme.uiFont,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: c.accent,
                          ),
                        ),
                        Text(
                          'Aktiviti Pengukuhan',
                          textDirection: TextDirection.ltr,
                          style: TextStyle(fontFamily: AppTheme.uiFont, fontSize: 13, color: c.textMuted),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_rounded, size: 18, color: c.gold),
                          const SizedBox(width: 3),
                          Text(
                            '$stars / ${total * 3}',
                            textDirection: TextDirection.ltr,
                            style: TextStyle(fontWeight: FontWeight.w800, color: c.text),
                          ),
                        ],
                      ),
                      Text(
                        '$done / $total selesai',
                        textDirection: TextDirection.ltr,
                        style: TextStyle(fontFamily: AppTheme.uiFont, fontSize: 12, color: c.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TweenAnimationBuilder<double>(
                tween: Tween(end: total == 0 ? 0 : done / total),
                duration: motion(context, 500),
                curve: Curves.easeOutCubic,
                builder: (context, v, _) => ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: v,
                    minHeight: 7,
                    backgroundColor: c.surface,
                    valueColor: AlwaysStoppedAnimation(c.accent),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Latihan tambahan ini berdasarkan pelajaran di atas (teks bacaan, kosa kata dan kaedah). '
                'Ia bukan sebahagian daripada teks asal buku.',
                textDirection: TextDirection.ltr,
                style: TextStyle(fontFamily: AppTheme.uiFont, fontSize: 12.5, height: 1.5, color: c.textMuted),
              ),
            ],
          ),
        ),
        for (var i = 0; i < specs.length; i++) SupplementalExerciseCard(lesson: lesson, spec: specs[i], index: i),
      ],
    );
  }
}
