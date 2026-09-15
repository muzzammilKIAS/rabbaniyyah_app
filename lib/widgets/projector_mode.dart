import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// One section of a lesson, shown as a single full-screen page in
/// [ProjectorModeView]. [child] is the section's existing content
/// (usually a [StitchDivider] plus one or more cards) — the same widget
/// used in the lesson's normal scrolling view, so nothing is duplicated
/// or re-authored just for presentation mode.
class ProjectorSlide {
  const ProjectorSlide({required this.label, required this.icon, required this.child});
  final String label;
  final IconData icon;
  final Widget child;
}

/// A distraction-free, one-section-at-a-time presentation view for use
/// with a classroom LCD/projector. Unlike [FullscreenToggleButton] (which
/// only toggles the browser's fullscreen chrome), this replaces the long
/// scrolling lesson page with discrete slides navigated only by the
/// left/right arrow buttons, arrow keys, or a swipe — nothing to scroll
/// past to find the next activity.
class ProjectorModeView extends StatefulWidget {
  const ProjectorModeView({
    super.key,
    required this.lessonTitle,
    required this.slides,
    this.initialIndex = 0,
  });

  final String lessonTitle;
  final List<ProjectorSlide> slides;
  final int initialIndex;

  static Future<void> open(
    BuildContext context, {
    required String lessonTitle,
    required List<ProjectorSlide> slides,
    int initialIndex = 0,
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (_, __, ___) => ProjectorModeView(
          lessonTitle: lessonTitle,
          slides: slides,
          initialIndex: initialIndex,
        ),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  State<ProjectorModeView> createState() => _ProjectorModeViewState();
}

class _ProjectorModeViewState extends State<ProjectorModeView> {
  late int _index = widget.initialIndex.clamp(0, widget.slides.length - 1);
  late final _pageController = PageController(initialPage: _index);
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _pageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _go(int delta) {
    final next = (_index + delta).clamp(0, widget.slides.length - 1);
    if (next == _index) return;
    _pageController.animateToPage(next, duration: const Duration(milliseconds: 260), curve: Curves.easeOutCubic);
  }

  void _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowRight:
      case LogicalKeyboardKey.pageDown:
      case LogicalKeyboardKey.space:
        _go(1);
      case LogicalKeyboardKey.arrowLeft:
      case LogicalKeyboardKey.pageUp:
        _go(-1);
      case LogicalKeyboardKey.escape:
        Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final slides = widget.slides;
    final last = slides.length - 1;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: c.surface2,
        body: KeyboardListener(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: _handleKey,
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: 'إغلاق العرض التقديمي',
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.lessonTitle,
                        style: TextStyle(fontFamily: AppTheme.uiFont, fontSize: 13, color: c.textMuted),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Text(
                        '${_index + 1} / ${slides.length}',
                        style: TextStyle(
                          fontFamily: AppTheme.uiFont,
                          fontSize: 13,
                          color: c.textMuted,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      _EdgeNavButton(
                        icon: Icons.chevron_left_rounded,
                        onPressed: _index > 0 ? () => _go(-1) : null,
                      ),
                      Expanded(
                        child: PageView(
                          controller: _pageController,
                          onPageChanged: (i) => setState(() => _index = i),
                          children: [
                            for (final s in slides)
                              _ProjectorPage(icon: s.icon, label: s.label, child: s.child),
                          ],
                        ),
                      ),
                      _EdgeNavButton(
                        icon: Icons.chevron_right_rounded,
                        onPressed: _index < last ? () => _go(1) : null,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < slides.length; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: i == _index ? 20 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: i == _index ? c.accent : c.border,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProjectorPage extends StatelessWidget {
  const _ProjectorPage({required this.icon, required this.label, required this.child});
  final IconData icon;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: child,
        ),
      ),
    );
  }
}

class _EdgeNavButton extends StatelessWidget {
  const _EdgeNavButton({required this.icon, required this.onPressed});
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final enabled = onPressed != null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Material(
        color: c.surface,
        shape: const CircleBorder(),
        elevation: enabled ? 2 : 0,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, size: 30, color: enabled ? c.accent : c.border),
          ),
        ),
      ),
    );
  }
}
