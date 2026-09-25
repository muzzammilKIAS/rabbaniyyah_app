import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

/// Label, icon and colours for a [LessonStatus] — one mapping for every
/// place that shows it (unit list, lesson page, dashboard).
({String label, IconData icon, Color fg, Color bg}) lessonStatusStyle(BuildContext context, LessonStatus s) {
  final c = context.colors;
  return switch (s) {
    LessonStatus.notStarted => (
      label: 'Belum mula',
      icon: Icons.radio_button_unchecked_rounded,
      fg: c.textMuted,
      bg: c.surface2,
    ),
    LessonStatus.inProgress => (
      label: 'Sedang belajar',
      icon: Icons.timelapse_rounded,
      fg: c.accent2,
      bg: c.accent2Soft,
    ),
    LessonStatus.completed => (label: 'Selesai', icon: Icons.check_circle_rounded, fg: c.success, bg: c.successSoft),
  };
}

class LessonStatusChip extends StatelessWidget {
  const LessonStatusChip({super.key, required this.status, this.compact = false});
  final LessonStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final st = lessonStatusStyle(context, status);
    return Semantics(
      label: 'Status: ${st.label}',
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: compact ? 7 : 10, vertical: 4),
        decoration: BoxDecoration(color: st.bg, borderRadius: BorderRadius.circular(999)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(st.icon, size: 14, color: st.fg),
            if (!compact) ...[
              const SizedBox(width: 5),
              Text(
                st.label,
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  fontFamily: AppTheme.uiFont,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: st.fg,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Small circular progress with the percentage inside.
class ProgressRing extends StatelessWidget {
  const ProgressRing({super.key, required this.value, this.size = 36, this.stroke = 3.5, this.color, this.fontSize});
  final double value;
  final double size;
  final double stroke;
  final Color? color;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final col = color ?? c.accent;
    return Semantics(
      label: 'Kemajuan ${(value * 100).round()} peratus',
      child: SizedBox(
        width: size,
        height: size,
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: value.clamp(0.0, 1.0)),
          duration: (MediaQuery.maybeDisableAnimationsOf(context) ?? false)
              ? Duration.zero
              : const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          builder: (context, v, _) => Stack(
            alignment: Alignment.center,
            children: [
              SizedBox.expand(
                child: CircularProgressIndicator(
                  value: v,
                  strokeWidth: stroke,
                  backgroundColor: c.border,
                  valueColor: AlwaysStoppedAnimation(col),
                ),
              ),
              Text(
                '${(v * 100).round()}٪',
                style: TextStyle(fontSize: fontSize ?? size * 0.27, fontWeight: FontWeight.w800, color: col),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

IconData unitIcon(int unit) => switch (unit) {
  0 => Icons.auto_awesome_outlined,
  1 => Icons.mosque_outlined,
  2 => Icons.volunteer_activism_outlined,
  _ => Icons.history_edu_outlined,
};
