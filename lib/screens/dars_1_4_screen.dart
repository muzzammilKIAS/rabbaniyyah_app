import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/curriculum.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/dars_1_4/analyze_card.dart';
import '../widgets/dars_1_4/reading_card.dart';
import '../widgets/dars_1_4/reflection_exit_card.dart';
import '../widgets/dars_1_4/rule_card.dart';
import '../widgets/dars_1_4/speaking_card.dart';
import '../widgets/dars_1_4/think_write_card.dart';
import '../widgets/dars_1_4/vocab_card.dart';
import '../widgets/dars1/celebration_dialog.dart';
import '../widgets/dars1/topic_intro_video.dart';
import '../widgets/atmosphere.dart';

class Dars114Screen extends StatefulWidget {
  const Dars114Screen({super.key});

  @override
  State<Dars114Screen> createState() => _Dars114ScreenState();
}

class _Dars114ScreenState extends State<Dars114Screen> {
  final _readingKey = GlobalKey();
  final _vocabKey = GlobalKey();
  final _speakingKey = GlobalKey();
  final _thinkKey = GlobalKey();
  final _analyzeKey = GlobalKey();
  final _reflectionKey = GlobalKey();
  final _closingKey = GlobalKey();
  int _active = 0;
  final ScrollController _scrollController = ScrollController();
  bool _isScrollingProgrammatically = false;

  late final _steps = [
    LessonStepItem(icon: Icons.menu_book_outlined, label: 'أقرأ وأفهم', sectionKey: _readingKey),
    LessonStepItem(icon: Icons.view_list_outlined, label: 'كلمات وقاعدة', sectionKey: _vocabKey),
    LessonStepItem(icon: Icons.forum_outlined, label: 'أتكلم', sectionKey: _speakingKey),
    LessonStepItem(icon: Icons.edit_note_outlined, label: 'أفكر وأكتب', sectionKey: _thinkKey),
    LessonStepItem(icon: Icons.groups_outlined, label: 'أحلل وأطبق', sectionKey: _analyzeKey),
    LessonStepItem(icon: Icons.favorite_border, label: 'الفقه والحياة', sectionKey: _reflectionKey),
    LessonStepItem(icon: Icons.flag_outlined, label: 'الخاتمة', sectionKey: _closingKey),
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToIndex(int i) {
    setState(() => _active = i);
    _isScrollingProgrammatically = true;
    final ctx = _steps[i].sectionKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 500),
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

  bool _onScroll(ScrollNotification notification) {
    if (_isScrollingProgrammatically) return false;
    const band = 180.0;
    var best = 0;
    var bestTop = double.negativeInfinity;
    for (var i = 0; i < _steps.length; i++) {
      final box = _steps[i].sectionKey.currentContext?.findRenderObject() as RenderBox?;
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

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final app = context.watch<AppState>();
    final progress = app.dars114Progress(Dars114.selfAssessItems.length);

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
                Text('الفصل الأول ‹ الوحدة الثانية: الفقه',
                    style: TextStyle(fontSize: 11, color: c.textMuted, fontWeight: FontWeight.normal)),
                const Text('الدرس الرابع — الطهارة: الوضوء والغسل', style: TextStyle(fontSize: 17)),
              ],
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'إظهار / إخفاء التشكيل',
              onPressed: () => context.read<AppState>().toggleTashkeel(),
              icon: Text(
                app.tashkeelOn ? 'بَ' : 'ب',
                style: TextStyle(fontFamily: AppTheme.arabicFont, fontSize: 18, color: app.tashkeelOn ? c.accent : c.textMuted),
              ),
            ),
            IconButton(
              tooltip: 'إعادة ضبط التقدم',
              icon: const Icon(Icons.restart_alt_rounded, size: 20),
              onPressed: () async {
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
                  await appState.resetDars114();
                }
              },
            ),
            const ThemeToggleButton(),
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 4),
              child: SizedBox(
                width: 36,
                height: 36,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 3.5,
                      backgroundColor: c.border,
                      valueColor: AlwaysStoppedAnimation(c.accent),
                    ),
                    Text('${(progress * 100).round()}٪', style: TextStyle(fontSize: 9.5, color: c.accent)),
                  ],
                ),
              ),
            ),
          ],
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
                      child: LessonStepRail(items: _steps, activeIndex: _active, onTapItem: _scrollToIndex),
                    ),
                    Expanded(
                      child: NotificationListener<ScrollNotification>(
                        onNotification: _onScroll,
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 48),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _Hero4(),
                              const TopicIntroVideo(assetPath: 'assets/video/topik4.mp4'),
                              KeyedSubtree(
                                key: _readingKey,
                                child: Column(children: [
                                  const StitchDivider('أقرأ وأفهم', icon: Icons.menu_book_outlined),
                                  const ReadingCard4(),
                                ]),
                              ),
                              KeyedSubtree(
                                key: _vocabKey,
                                child: Column(children: [
                                  const StitchDivider('جدول الكلمات والقاعدة', icon: Icons.view_list_outlined),
                                  const VocabCard4(),
                                  const RuleCard4(),
                                ]),
                              ),
                              KeyedSubtree(
                                key: _speakingKey,
                                child: Column(children: [
                                  const StitchDivider('أتكلم باللغة العربية', icon: Icons.forum_outlined),
                                  const SpeakingCard4(),
                                ]),
                              ),
                              KeyedSubtree(
                                key: _thinkKey,
                                child: Column(children: [
                                  const StitchDivider('أفكر وأكتب', icon: Icons.edit_note_outlined),
                                  const ThinkWriteCard4(),
                                ]),
                              ),
                              KeyedSubtree(
                                key: _analyzeKey,
                                child: Column(children: [
                                  const StitchDivider('أحلل وأطبق', icon: Icons.groups_outlined),
                                  const AnalyzeCard4(),
                                ]),
                              ),
                              KeyedSubtree(
                                key: _reflectionKey,
                                child: Column(children: [
                                  const StitchDivider('الفقه والحياة', icon: Icons.favorite_border),
                                  const ReflectionCard4(),
                                ]),
                              ),
                              KeyedSubtree(
                                key: _closingKey,
                                child: Column(children: [
                                  const StitchDivider('الخاتمة', icon: Icons.flag_outlined),
                                  const ExitTicketCard4(),
                                  const SelfAssessCard4(),
                                  const SizedBox(height: 12),
                                  const DictionaryCard4(),
                                ]),
                              ),
                              const SizedBox(height: 28),
                              Container(
                                padding: const EdgeInsets.all(22),
                                decoration: BoxDecoration(
                                  color: c.surface,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: c.goldBorder),
                                  boxShadow: [
                                    BoxShadow(color: c.cardShadow, blurRadius: 16, offset: const Offset(0, 4)),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.auto_awesome_rounded, color: c.gold, size: 22),
                                        const SizedBox(width: 8),
                                        Text(
                                          'بحمد الله وتوفيقه تم الدرس الرابع',
                                          style: TextStyle(fontFamily: AppTheme.uiFont, fontWeight: FontWeight.bold, fontSize: 18, color: c.accent),
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
                                          onPressed: () => CelebrationDialog.show(
                                            context,
                                            title: 'أَحْسَنْتَ! 🎉',
                                            message: 'أَتْمَمْتَ الدَّرْسَ الرَّابِعَ: الطَّهَارَةُ — الوُضُوءُ وَالغُسْلُ',
                                          ),
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
                              ),
                            ],
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

class _Hero4 extends StatelessWidget {
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
        boxShadow: [
          BoxShadow(color: c.cardShadow, blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: c.accentSoft, borderRadius: BorderRadius.circular(999)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🕌', style: const TextStyle(fontSize: 13)),
                    const SizedBox(width: 6),
                    Text('الوحدة الثانية: الفقه',
                        style: TextStyle(fontFamily: AppTheme.uiFont, fontSize: 12, color: c.accent, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: c.goldSoft, borderRadius: BorderRadius.circular(999)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🎯', style: TextStyle(fontSize: 11.5)),
                    const SizedBox(width: 6),
                    Text('أهداف التعلم',
                        style: TextStyle(fontFamily: AppTheme.uiFont, fontSize: 11.5, color: c.gold, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text('الطَّهَارَةُ: الوُضُوءُ وَالغُسْلُ',
              style: TextStyle(fontFamily: AppTheme.arabicFont, fontWeight: FontWeight.w800, fontSize: 34, color: c.accent)),
          const SizedBox(height: 6),
          Text('فِي نِهَايَةِ الدَّرْسِ، أَسْتَطِيعُ إِنْ شَاءَ اللهُ أَنْ:',
              style: TextStyle(fontFamily: AppTheme.instructionFont, fontSize: 17, color: c.gold)),
          const SizedBox(height: 14),
          for (final o in Dars114.objectives)
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
                      child: Text(o.$2,
                          style: TextStyle(fontFamily: AppTheme.instructionFont, fontSize: 16.5, height: 1.6, color: c.text)),
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
