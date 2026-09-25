import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/exercise_models.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../utils/arabic_text.dart';

/// True when the OS/browser asks for reduced motion.
bool reduceMotionOf(BuildContext context) => MediaQuery.maybeDisableAnimationsOf(context) ?? false;

/// Duration helper that collapses to zero under reduced motion.
Duration motion(BuildContext context, int ms) => reduceMotionOf(context) ? Duration.zero : Duration(milliseconds: ms);

IconData exerciseIcon(ExerciseSpec spec) => switch (spec) {
  McqExercise(isQuickCheck: true) => Icons.bolt_rounded,
  McqExercise() => Icons.checklist_rounded,
  TrueFalseExercise() => Icons.rule_rounded,
  CategorizeExercise() => Icons.category_outlined,
  SequenceExercise() => Icons.format_list_numbered_rtl_rounded,
  FlashcardExercise() => Icons.style_outlined,
  PairMatchExercise() => Icons.compare_arrows_rounded,
};

/// Arabic or Malay text, styled for exercises. Arabic honours the global
/// tashkeel toggle; Malay text may embed «Arabic» fragments.
class ExText extends StatelessWidget {
  const ExText(this.text, {super.key, required this.arabic, this.size, this.weight, this.color, this.align});
  final String text;
  final bool arabic;
  final double? size;
  final FontWeight? weight;
  final Color? color;
  final TextAlign? align;

  @override
  Widget build(BuildContext context) {
    final on = context.select<AppState, bool>((s) => s.tashkeelOn);
    final shown = on ? text : stripTashkeel(text);
    final style = TextStyle(
      fontFamily: arabic ? AppTheme.arabicFont : AppTheme.uiFont,
      fontSize: size ?? (arabic ? 20 : 15),
      fontWeight: weight,
      height: arabic ? 1.75 : 1.5,
      color: color ?? context.colors.text,
    );
    final t = Text(shown, style: style, textAlign: align);
    return arabic ? t : Directionality(textDirection: TextDirection.ltr, child: t);
  }
}

class StarRow extends StatelessWidget {
  const StarRow({super.key, required this.stars, this.size = 18});
  final int stars;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      label: '$stars / 3 bintang',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 3; i++)
            Icon(
              i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
              size: size,
              color: i < stars ? c.gold : c.border,
            ),
        ],
      ),
    );
  }
}

/// Correct / try-again banner shown after checking an answer.
class ExerciseFeedback extends StatelessWidget {
  const ExerciseFeedback({super.key, required this.correct, this.detail});
  final bool correct;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fg = correct ? c.success : c.accent2;
    final bg = correct ? c.successSoft : c.accent2Soft;
    return Semantics(
      liveRegion: true,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.96, end: 1),
        duration: motion(context, 260),
        curve: Curves.easeOutBack,
        builder: (context, v, child) => Transform.scale(scale: v, child: child),
        child: Container(
          margin: const EdgeInsets.only(top: 14),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: fg.withValues(alpha: 0.5)),
          ),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              children: [
                Icon(correct ? Icons.check_circle_rounded : Icons.refresh_rounded, color: fg, size: 20),
                const SizedBox(width: 8),
                Text(
                  correct ? '✓ Betul' : 'Cuba lagi',
                  style: TextStyle(fontFamily: AppTheme.uiFont, fontWeight: FontWeight.w800, fontSize: 15, color: fg),
                ),
                if (detail != null) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      detail!,
                      style: TextStyle(fontFamily: AppTheme.uiFont, fontSize: 13, color: c.textMuted),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Primary / secondary buttons in an exercise footer.
class ExerciseActions extends StatelessWidget {
  const ExerciseActions({
    super.key,
    this.onCheck,
    this.checkLabel = 'Semak jawapan',
    this.onReset,
    this.resetLabel = 'Ulang semula',
  });
  final VoidCallback? onCheck;
  final String checkLabel;
  final VoidCallback? onReset;
  final String resetLabel;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Wrap(
          spacing: 10,
          runSpacing: 8,
          alignment: WrapAlignment.end,
          children: [
            if (onReset != null)
              OutlinedButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.replay_rounded, size: 18),
                label: Text(resetLabel),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            if (checkLabel.isNotEmpty)
              ElevatedButton.icon(
                onPressed: onCheck,
                icon: const Icon(Icons.task_alt_rounded, size: 18),
                label: Text(checkLabel),
                style: ElevatedButton.styleFrom(minimumSize: const Size(0, 44)),
              ),
          ],
        ),
      ),
    );
  }
}

/// Card chrome shared by every supplemental exercise: kind chip, best
/// stars, title, Malay instruction, then the exercise body.
class ExerciseFrame extends StatelessWidget {
  const ExerciseFrame({super.key, required this.lesson, required this.spec, required this.index, required this.child});
  final int lesson;
  final ExerciseSpec spec;
  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final result = context.select<AppState, ExerciseResult?>((s) => s.exerciseResult(lesson, spec.id));
    final done = result != null;
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: done ? c.success.withValues(alpha: 0.45) : c.border),
        boxShadow: [BoxShadow(color: c.cardShadow, blurRadius: 12, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: done ? c.success : c.accentSoft, shape: BoxShape.circle),
                child: done
                    ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
                    : Text(
                        toArabicNumerals(index + 1),
                        style: TextStyle(fontWeight: FontWeight.w800, color: c.accent, fontSize: 14),
                      ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: c.surface2, borderRadius: BorderRadius.circular(999)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(exerciseIcon(spec), size: 14, color: c.accent),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          spec.kindLabel,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c.accent),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              if (done) StarRow(stars: result.stars),
            ],
          ),
          const SizedBox(height: 12),
          ExText(spec.title, arabic: true, size: 21, weight: FontWeight.w700, color: c.accent),
          const SizedBox(height: 2),
          ExText(spec.instruction, arabic: false, size: 14, color: c.textMuted),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
