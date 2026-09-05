import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/arabic_text.dart';

/// Arabic text that respects the global "baris" (tashkeel) toggle — shows
/// [text] as authored when the toggle is on, or with diacritics stripped
/// when off. Never touches the student's own typed input.
class TashkeelText extends StatelessWidget {
  const TashkeelText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.font = AppTheme.arabicFont,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final String font;

  @override
  Widget build(BuildContext context) {
    final on = context.select<AppState, bool>((s) => s.tashkeelOn);
    return Text(
      on ? text : stripTashkeel(text),
      textAlign: textAlign,
      style: (style ?? const TextStyle()).copyWith(fontFamily: font),
    );
  }
}

class SectionCard extends StatelessWidget {
  const SectionCard({super.key, required this.child, this.margin});
  final Widget child;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      margin: margin ?? const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.border),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: c.cardShadow, blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }
}

class CardHeading extends StatelessWidget {
  const CardHeading(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      stripTashkeel(text),
      style: TextStyle(
        fontFamily: AppTheme.headingFont,
        fontSize: 18.5,
        fontWeight: FontWeight.w800,
        color: context.colors.text,
      ),
    );
  }
}

class CardInstruction extends StatelessWidget {
  const CardInstruction(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    final on = context.select<AppState, bool>((s) => s.tashkeelOn);
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        on ? text : stripTashkeel(text),
        style: TextStyle(
          fontFamily: AppTheme.instructionFont,
          fontSize: 16.5,
          fontWeight: FontWeight.w600,
          color: context.colors.textMuted,
          height: 1.65,
        ),
      ),
    );
  }
}

class StitchDivider extends StatelessWidget {
  const StitchDivider(this.label, {super.key, this.icon});
  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(top: 32, bottom: 14),
      child: Row(
        children: [
          Expanded(child: Divider(color: c.border.withValues(alpha: 0.8))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: c.border),
                boxShadow: [
                  BoxShadow(color: c.cardShadow, blurRadius: 6, offset: const Offset(0, 2)),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 16, color: c.gold),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    stripTashkeel(label),
                    style: TextStyle(
                      fontFamily: AppTheme.uiFont,
                      color: c.accent,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(child: Divider(color: c.border.withValues(alpha: 0.8))),
        ],
      ),
    );
  }
}

class ScoreBadge extends StatelessWidget {
  const ScoreBadge({super.key, this.correct, this.total});
  final int? correct;
  final int? total;

  @override
  Widget build(BuildContext context) {
    if (correct == null || total == null) return const SizedBox.shrink();
    final c = context.colors;
    final isFull = correct == total;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isFull ? c.successSoft : c.accentSoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: isFull ? c.success : c.accent),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isFull ? Icons.stars_rounded : Icons.scoreboard_outlined,
            size: 16,
            color: isFull ? c.success : c.accent,
          ),
          const SizedBox(width: 6),
          Text(
            'النتيجة: $correct / $total',
            style: TextStyle(
              fontSize: 12.5,
              color: isFull ? c.success : c.accent,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class SpeakButton extends StatelessWidget {
  const SpeakButton({super.key, required this.onTap, this.size = 32, this.speaking = false});
  final VoidCallback onTap;
  final double size;
  final bool speaking;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: speaking ? c.accent2Soft : c.surface2,
          border: Border.all(color: speaking ? c.accent2 : c.border),
        ),
        child: Icon(
          speaking ? Icons.stop_rounded : Icons.volume_up_rounded,
          size: size * 0.5,
          color: c.accent2,
        ),
      ),
    );
  }
}

/// One entry in a [LessonStepRail]: the section it jumps to, its icon and
/// short label.
class LessonStepItem {
  const LessonStepItem({required this.icon, required this.label, required this.sectionKey});
  final IconData icon;
  final String label;
  final GlobalKey sectionKey;
}

/// Horizontal quick-nav for a lesson's sections — replaces a long vertical
/// stack of same-looking dividers with one scannable row. Tapping a chip
/// scrolls its section into view; [activeIndex] highlights whichever
/// section currently sits at the top of the viewport.
class LessonStepRail extends StatelessWidget {
  const LessonStepRail({
    super.key,
    required this.items,
    required this.activeIndex,
    this.onTapItem,
  });
  final List<LessonStepItem> items;
  final int activeIndex;
  final ValueChanged<int>? onTapItem;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final item = items[i];
          final active = i == activeIndex;
          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () {
                onTapItem?.call(i);
                final ctx = item.sectionKey.currentContext;
                if (ctx != null) {
                  Scrollable.ensureVisible(
                    ctx,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOutCubic,
                    alignment: 0.05,
                  );
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: active ? c.accent : c.surface,
                  border: Border.all(color: active ? c.accent : c.border),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(item.icon, size: 15, color: active ? c.surface : c.textMuted),
                    const SizedBox(width: 6),
                    Text(
                      stripTashkeel(item.label),
                      style: TextStyle(
                        fontFamily: AppTheme.uiFont,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: active ? c.surface : c.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Cycles the app's theme mode (نظام → فاتح → داكن) on tap.
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<AppState>().themeMode;
    final (icon, tooltip) = switch (mode) {
      ThemeMode.system => (Icons.brightness_auto_rounded, 'المظهر: تلقائي (النظام)'),
      ThemeMode.light => (Icons.light_mode_rounded, 'المظهر: فاتح'),
      ThemeMode.dark => (Icons.dark_mode_rounded, 'المظهر: داكن'),
    };
    return IconButton(
      tooltip: tooltip,
      icon: Icon(icon, size: 20),
      onPressed: () => context.read<AppState>().cycleThemeMode(),
    );
  }
}
