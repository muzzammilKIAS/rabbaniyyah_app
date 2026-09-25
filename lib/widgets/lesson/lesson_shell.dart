import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/supplemental_exercises.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../utils/arabic_text.dart';
import '../../utils/fullscreen.dart' as fullscreen;
import '../atmosphere.dart';
import '../common.dart';
import '../dars1/celebration_dialog.dart';
import '../exercises/supplemental_section.dart';
import '../projector_mode.dart';
import 'lesson_nav.dart';
import 'lesson_status.dart';
import 'lesson_video.dart';

/// One original section of a lesson (e.g. أقرأ وأفهم): its label in the
/// step rail, the label on its divider, its icon, and its existing cards.
class LessonSection {
  const LessonSection({required this.step, required this.divider, required this.icon, required this.children});
  final String step;
  final String divider;
  final IconData icon;
  final List<Widget> children;
}

class _Block {
  _Block(this.step, this.icon, this.body);
  final String step;
  final IconData icon;
  final Widget body;
  final GlobalKey key = GlobalKey();
}

/// The page frame shared by all twelve lessons. Each lesson screen supplies
/// only what is its own — hero, titles, and its original section cards —
/// and this shell adds the common learning experience around it:
///
///  hero → video (if any) → original sections → تدريبات إضافية →
///  الخاتمة → closing card → progress summary → previous / next lesson
///
/// plus the sticky step rail, projector mode, tashkeel toggle, bookmark,
/// progress ring, and a scroll-to-top button.
class LessonShell extends StatefulWidget {
  const LessonShell({
    super.key,
    required this.lesson,
    required this.breadcrumb,
    required this.title,
    required this.hero,
    required this.sections,
    required this.closingTitle,
    this.celebrationTitle,
    this.celebrationMessage,
  });

  final int lesson;
  final String breadcrumb;
  final String title;
  final Widget hero;

  /// Original sections in order; the last one is الخاتمة.
  final List<LessonSection> sections;
  final String closingTitle;
  final String? celebrationTitle;
  final String? celebrationMessage;

  @override
  State<LessonShell> createState() => _LessonShellState();
}

class _LessonShellState extends State<LessonShell> {
  final _scrollController = ScrollController();
  int _active = 0;
  bool _isScrollingProgrammatically = false;
  bool _showTop = false;

  /// Bumped on reset so every card rebuilds from the cleared state.
  int _generation = 0;

  late List<_Block> _blocks = _buildBlocks();

  List<_Block> _buildBlocks() {
    final s = widget.sections;
    Widget sectionBody(LessonSection x) => Column(
      children: [
        StitchDivider(x.divider, icon: x.icon),
        ...x.children,
      ],
    );
    return [
      for (final x in s.take(s.length - 1)) _Block(x.step, x.icon, sectionBody(x)),
      if (exercisesFor(widget.lesson).isNotEmpty)
        _Block(
          'تدريبات إضافية',
          Icons.fitness_center_rounded,
          Column(
            children: [
              const StitchDivider('تدريبات إضافية', icon: Icons.fitness_center_rounded),
              SupplementalSection(lesson: widget.lesson),
            ],
          ),
        ),
      if (s.isNotEmpty) _Block(s.last.step, s.last.icon, sectionBody(s.last)),
    ];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AppState>().markVisited(widget.lesson);
    });
    _scrollController.addListener(() {
      final show = _scrollController.offset > 900;
      if (show != _showTop) setState(() => _showTop = show);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToIndex(int i) {
    setState(() => _active = i);
    _isScrollingProgrammatically = true;
    final ctx = _blocks[i].key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: (MediaQuery.maybeDisableAnimationsOf(context) ?? false)
            ? Duration.zero
            : const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
        alignment: 0.05,
      ).then((_) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) _isScrollingProgrammatically = false;
        });
      });
    } else {
      _isScrollingProgrammatically = false;
    }
  }

  /// Highlights whichever section currently sits near the viewport top.
  bool _onScroll(ScrollNotification notification) {
    if (_isScrollingProgrammatically) return false;
    const band = 180.0;
    var best = 0;
    var bestTop = double.negativeInfinity;
    for (var i = 0; i < _blocks.length; i++) {
      final box = _blocks[i].key.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.attached) continue;
      final top = box.localToGlobal(Offset.zero).dy;
      if (top <= band && top > bestTop) {
        bestTop = top;
        best = i;
      }
    }
    if (best != _active) setState(() => _active = best);
    return false;
  }

  List<ProjectorSlide> get _slides => [
    ProjectorSlide(
      label: widget.title,
      icon: Icons.auto_stories_rounded,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.hero,
          LessonVideo(lesson: widget.lesson),
        ],
      ),
    ),
    for (final b in _blocks) ProjectorSlide(label: b.step, icon: b.icon, child: b.body),
  ];

  Future<void> _confirmReset() async {
    final appState = context.read<AppState>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إعادة ضبط التقدم'),
        content: const Text('هل تريد إعادة ضبط كل التقدم في هذا الدرس؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('نعم')),
        ],
      ),
    );
    if (ok == true) {
      await appState.resetLessonAll(widget.lesson);
      if (mounted) {
        setState(() {
          _generation++;
          _blocks = _buildBlocks();
        });
      }
    }
  }

  void _openProjector() =>
      ProjectorModeView.open(context, lessonTitle: widget.title, slides: _slides, initialIndex: _active + 1);

  List<Widget> _actions(BuildContext context, bool narrow) {
    final c = context.colors;
    final app = context.watch<AppState>();
    final marked = app.isBookmarked(widget.lesson);
    final tashkeel = IconButton(
      tooltip: 'إظهار / إخفاء التشكيل',
      onPressed: () => context.read<AppState>().toggleTashkeel(),
      icon: Text(
        app.tashkeelOn ? 'بَ' : 'ب',
        style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 18, color: app.tashkeelOn ? c.accent : c.textMuted),
      ),
    );
    final bookmark = IconButton(
      tooltip: marked ? 'Buang tanda ulang kaji' : 'Tandakan untuk ulang kaji',
      onPressed: () => context.read<AppState>().toggleBookmark(widget.lesson),
      icon: Icon(
        marked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
        size: 21,
        color: marked ? c.gold : null,
      ),
    );
    final ring = Padding(
      padding: const EdgeInsets.only(left: 12, right: 4),
      child: Tooltip(
        message: 'Kemajuan pelajaran (penilaian kendiri + latihan)',
        child: ProgressRing(value: app.lessonProgress(widget.lesson)),
      ),
    );
    if (!narrow) {
      return [
        tashkeel,
        bookmark,
        IconButton(
          tooltip: 'إعادة ضبط التقدم',
          icon: const Icon(Icons.restart_alt_rounded, size: 20),
          onPressed: _confirmReset,
        ),
        IconButton(
          tooltip: 'العرض التقديمي (وضع الفصل)',
          icon: const Icon(Icons.co_present_rounded, size: 20),
          onPressed: _openProjector,
        ),
        const FullscreenToggleButton(),
        const ThemeToggleButton(),
        ring,
      ];
    }
    return [
      tashkeel,
      bookmark,
      PopupMenuButton<String>(
        tooltip: 'Menu lain',
        icon: const Icon(Icons.more_vert_rounded),
        onSelected: (v) async {
          switch (v) {
            case 'projector':
              _openProjector();
            case 'fullscreen':
              fullscreen.isFullscreen ? await fullscreen.exitFullscreen() : await fullscreen.enterFullscreen();
            case 'theme':
              context.read<AppState>().cycleThemeMode();
            case 'reset':
              await _confirmReset();
          }
        },
        itemBuilder: (_) => [
          const PopupMenuItem(
            value: 'projector',
            child: ListTile(leading: Icon(Icons.co_present_rounded), title: Text('العرض التقديمي (وضع الفصل)')),
          ),
          if (fullscreen.isFullscreenSupported)
            const PopupMenuItem(
              value: 'fullscreen',
              child: ListTile(leading: Icon(Icons.fullscreen_rounded), title: Text('وضع العارض (ملء الشاشة)')),
            ),
          const PopupMenuItem(
            value: 'theme',
            child: ListTile(leading: Icon(Icons.brightness_6_rounded), title: Text('المظهر')),
          ),
          const PopupMenuDivider(),
          const PopupMenuItem(
            value: 'reset',
            child: ListTile(leading: Icon(Icons.restart_alt_rounded), title: Text('إعادة ضبط التقدم')),
          ),
        ],
      ),
      // On phones the ring is left out to give the title room; the same
      // progress is shown in full in the summary at the end of the lesson.
      const SizedBox(width: 4),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final narrow = MediaQuery.sizeOf(context).width < 720;
    final steps = [for (final b in _blocks) LessonStepItem(icon: b.icon, label: b.step, sectionKey: b.key)];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          titleSpacing: 0,
          title: Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.breadcrumb,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: c.textMuted, fontWeight: FontWeight.normal),
                ),
                Semantics(
                  header: true,
                  child: Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: narrow ? 15 : 17),
                  ),
                ),
              ],
            ),
          ),
          actions: _actions(context, narrow),
        ),
        floatingActionButton: AnimatedScale(
          scale: _showTop ? 1 : 0,
          duration: const Duration(milliseconds: 180),
          child: FloatingActionButton.small(
            tooltip: 'Kembali ke atas',
            heroTag: 'lesson-top-${widget.lesson}',
            backgroundColor: c.surface,
            foregroundColor: c.accent,
            onPressed: () {
              _scrollController.animateTo(
                0,
                duration: (MediaQuery.maybeDisableAnimationsOf(context) ?? false)
                    ? const Duration(milliseconds: 1)
                    : const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
              );
              setState(() => _active = 0);
            },
            child: const Icon(Icons.keyboard_arrow_up_rounded),
          ),
        ),
        body: PageBackdrop(
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 880),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: c.surface.withValues(alpha: 0.96),
                        border: Border(bottom: BorderSide(color: c.border.withValues(alpha: 0.6))),
                      ),
                      child: LessonStepRail(items: steps, activeIndex: _active, onTapItem: _scrollToIndex),
                    ),
                    Expanded(
                      child: NotificationListener<ScrollNotification>(
                        onNotification: _onScroll,
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 72),
                          child: KeyedSubtree(
                            key: ValueKey(_generation),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                widget.hero,
                                LessonVideo(lesson: widget.lesson),
                                for (final b in _blocks) KeyedSubtree(key: b.key, child: b.body),
                                const SizedBox(height: 28),
                                _ClosingCard(
                                  title: widget.closingTitle,
                                  onCelebrate: () =>
                                      widget.celebrationTitle == null && widget.celebrationMessage == null
                                      ? CelebrationDialog.show(context)
                                      : CelebrationDialog.show(
                                          context,
                                          title: widget.celebrationTitle,
                                          message: widget.celebrationMessage,
                                          badge: 'أتممت كل أهداف الدرس ${toArabicNumerals(widget.lesson)}',
                                        ),
                                ),
                                LessonCompletionPanel(lesson: widget.lesson),
                                LessonPager(lesson: widget.lesson),
                              ],
                            ),
                          ),
                        ),
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

/// The original end-of-lesson card (text unchanged from the lesson screens).
class _ClosingCard extends StatelessWidget {
  const _ClosingCard({required this.title, required this.onCelebrate});
  final String title;
  final VoidCallback onCelebrate;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.goldBorder),
        boxShadow: [BoxShadow(color: c.cardShadow, blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            children: [
              Icon(Icons.auto_awesome_rounded, color: c.gold, size: 22),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTheme.uiFont,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: c.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'تأكد من مراجعة كلمات القاموس وإكمال التقييم الذاتي أعلاه.',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: AppTheme.uiFont, fontSize: 13, color: c.textMuted),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: onCelebrate,
                icon: const Icon(Icons.military_tech_rounded, size: 18),
                label: const Text('عرض وسام الإنجاز 🏆'),
              ),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.home_rounded, size: 18),
                label: const Text('الرجوع إلى القائمة'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
