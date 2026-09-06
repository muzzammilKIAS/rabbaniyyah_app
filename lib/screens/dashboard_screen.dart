import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/curriculum.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/arabic_text.dart';
import '../widgets/atmosphere.dart';
import '../widgets/common.dart';
import 'dars_1_1_screen.dart';
import 'semester1_screen.dart';

class _SemesterInfo {
  final int n;
  final String title;
  final String meta;
  final String unitsPreview;
  final bool enabled;
  const _SemesterInfo(this.n, this.title, this.meta, this.unitsPreview, this.enabled);
}

const _semesters = [
  _SemesterInfo(1, 'اللغة العربية الربانية ١', '٤ وحدات · ١٢ درسا', 'العقيدة · الفقه · الأخلاق · السيرة', true),
  _SemesterInfo(2, 'اللغة العربية الربانية ٢', 'قيد الإعداد', 'النحو التطبيقي · البلاغة والبيان', false),
  _SemesterInfo(3, 'اللغة العربية الربانية ٣', 'قيد الإعداد', 'القراءة الموسعة · التعبير والإنشاء', false),
];

String _greetingByTime() {
  final h = DateTime.now().hour;
  if (h >= 5 && h < 12) return 'صباح الخير والبركة';
  if (h >= 12 && h < 15) return 'طاب يومك وظهرك';
  if (h >= 15 && h < 19) return 'طاب مساؤك بالخير';
  return 'مساء الخير والسرور';
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _entrance;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: PageBackdrop(
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final wide = width >= 800;
                final hpad = width >= 1200 ? 56.0 : (width >= 700 ? 32.0 : 18.0);
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(hpad, 20, hpad, 48),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Staggered(controller: _entrance, start: 0, end: 0.4, child: const _TopNavBar()),
                          const SizedBox(height: 20),
                          Staggered(controller: _entrance, start: 0.08, end: 0.55, child: const _HeroBanner()),
                          const SizedBox(height: 22),
                          Staggered(controller: _entrance, start: 0.16, end: 0.65, child: const _StatsRow()),
                          const SizedBox(height: 24),
                          Staggered(
                            controller: _entrance,
                            start: 0.22,
                            end: 0.75,
                            child: wide
                                ? const IntrinsicHeight(
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(flex: 3, child: _SemesterSectionHeader()),
                                        SizedBox(width: 20),
                                        Expanded(flex: 2, child: _DailyQuoteCard()),
                                      ],
                                    ),
                                  )
                                : const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _DailyQuoteCard(),
                                      SizedBox(height: 22),
                                      _SemesterSectionHeader(),
                                    ],
                                  ),
                          ),
                          const SizedBox(height: 14),
                          Staggered(
                            controller: _entrance,
                            start: 0.28,
                            end: 0.85,
                            child: wide
                                ? Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: _semesters
                                        .map((s) => Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                                child: _SemesterCard(info: s),
                                              ),
                                            ))
                                        .toList(),
                                  )
                                : Column(
                                    children: _semesters
                                        .map((s) => Padding(
                                              padding: const EdgeInsets.only(bottom: 14),
                                              child: _SemesterCard(info: s),
                                            ))
                                        .toList(),
                                  ),
                          ),
                          const SizedBox(height: 28),
                          Staggered(controller: _entrance, start: 0.34, end: 0.9, child: const _CopyrightFooter()),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _CopyrightFooter extends StatelessWidget {
  const _CopyrightFooter();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final year = DateTime.now().year;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 1,
            color: c.border,
            margin: const EdgeInsets.only(bottom: 14),
          ),
          Text(
            'روحيدي هابيل  |  محمد أبا الخير  |  أحمد مزمل نجيب  |  سعيد رمضان شكري  |  محمد إخوان يوسف',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTheme.uiFont,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: c.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'كلية الدراسات الإسلامية واللغة العربية — كياس',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTheme.uiFont,
              fontSize: 11,
              color: c.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '© $year جميع الحقوق محفوظة',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTheme.uiFont,
              fontSize: 10.5,
              color: c.textMuted.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopNavBar extends StatelessWidget {
  const _TopNavBar();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: c.surface.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
        boxShadow: [
          BoxShadow(color: c.cardShadow, blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: c.accent.withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 3)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset('assets/images/rabbani_mark.png', fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'اللغة العربية الربانية',
                      style: TextStyle(
                        fontFamily: AppTheme.uiFont,
                        fontWeight: FontWeight.w800,
                        fontSize: 16.5,
                        color: c.text,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: c.accentSoft,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'KIAS',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: c.accent,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  'كلية السلطان إسماعيل فترا الجامعية الإسلامية العالمية — منصة التعلم التفاعلي',
                  style: TextStyle(
                    fontFamily: AppTheme.uiFont,
                    fontSize: 11.5,
                    color: c.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: c.surface2,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: c.border),
            ),
            child: const ThemeToggleButton(),
          ),
        ],
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final progress = context.watch<AppState>().dars111Progress(Dars111.selfAssessItems.length);
    final percent = (progress * 100).round();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [c.heroGradientStart, c.heroGradientEnd],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: c.heroGradientStart.withValues(alpha: 0.35),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned(
              top: -30,
              left: -30,
              child: GeometricCornerMotif(
                color: c.gold.withValues(alpha: 0.15),
                size: 160,
              ),
            ),
            Positioned(
              bottom: -40,
              right: 180,
              child: GeometricCornerMotif(
                color: Colors.white.withValues(alpha: 0.05),
                size: 140,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(28),
              child: LayoutBuilder(
                builder: (context, box) {
                  final wide = box.maxWidth >= 720;
                  final content = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: c.gold.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: c.gold.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome_rounded, size: 14, color: c.gold),
                            const SizedBox(width: 6),
                            Text(
                              _greetingByTime(),
                              style: TextStyle(
                                fontFamily: AppTheme.uiFont,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: c.gold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'مرحبا بك في رحاب اللغة العربية الربانية',
                        style: TextStyle(
                          fontFamily: AppTheme.uiFont,
                          fontWeight: FontWeight.w900,
                          fontSize: 26,
                          color: Colors.white,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'منهج تعليمي معاصر يجمع بين فقه اللغة وترسيخ العقيدة والقيم الإسلامية الرفيعة.',
                        style: TextStyle(
                          fontFamily: AppTheme.uiFont,
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.88),
                          height: 1.6,
                        ),
                      ),
                    ],
                  );

                  final resumeCard = Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: c.gold.withValues(alpha: 0.25),
                              ),
                              child: Icon(Icons.bookmark_rounded, size: 18, color: c.gold),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'الدرس الجاري',
                                    style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.7)),
                                  ),
                                  const Text(
                                    'الدرس ١: الإيمان بالله',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: c.gold,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '٪$percent',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                  color: Color(0xFF451A03),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: progress > 0 ? progress : 0.05,
                            minHeight: 6,
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            valueColor: AlwaysStoppedAnimation(c.gold),
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const Dars111Screen()),
                              );
                            },
                            icon: const Icon(Icons.play_circle_fill_rounded, size: 18),
                            label: const Text('واصل التعلم الآن'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: c.gold,
                              foregroundColor: const Color(0xFF381A03),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (wide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(flex: 5, child: content),
                        const SizedBox(width: 28),
                        Expanded(flex: 4, child: resumeCard),
                      ],
                    );
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        content,
                        const SizedBox(height: 20),
                        resumeCard,
                      ],
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final progress = context.watch<AppState>().dars111Progress(Dars111.selfAssessItems.length);
    final percent = (progress * 100).round();

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 640;
        final items = [
          _StatTile(
            icon: Icons.menu_book_rounded,
            iconColor: c.accent,
            bgColor: c.accentSoft,
            title: '٤ وحدات تعليمية',
            subtitle: '١٢ درسا في الفصل الأول',
          ),
          _StatTile(
            icon: Icons.spellcheck_rounded,
            iconColor: c.gold,
            bgColor: c.goldSoft,
            title: '٨ مفردات متقنة',
            subtitle: 'أسماء الله الحسنى والقواعد',
          ),
          _StatTile(
            icon: Icons.stars_rounded,
            iconColor: c.success,
            bgColor: c.successSoft,
            title: '٪$percent الإنجاز العام',
            subtitle: percent > 0 ? 'تقدم رائع، واصل!' : 'ابدأ درسك اليوم',
          ),
        ];

        if (wide) {
          return Row(
            children: items
                .map((it) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: it,
                      ),
                    ))
                .toList(),
          );
        } else {
          return Column(
            children: items
                .map((it) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: it,
                    ))
                .toList(),
          );
        }
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
        boxShadow: [
          BoxShadow(color: c.cardShadow, blurRadius: 12, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: AppTheme.uiFont,
                    fontWeight: FontWeight.w800,
                    fontSize: 14.5,
                    color: c.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: c.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyQuoteCard extends StatefulWidget {
  const _DailyQuoteCard();

  @override
  State<_DailyQuoteCard> createState() => _DailyQuoteCardState();
}

class _DailyQuoteCardState extends State<_DailyQuoteCard> {
  // سورة طه، الآية ١١٤ — matches the ayah text and reference shown below.
  static const _surah = 20;
  static const _ayah = 114;

  bool _playing = false;

  Future<void> _toggle() async {
    final quran = context.read<AppState>().quranAudio;
    if (_playing) {
      await quran.stop();
      if (mounted) setState(() => _playing = false);
      return;
    }
    setState(() => _playing = true);
    final ok = await quran.playAyah(surah: _surah, ayah: _ayah);
    if (mounted) setState(() => _playing = false);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذّر تشغيل التلاوة — تحقّق من اتصالك بالإنترنت.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.goldBorder.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: c.gold.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: c.goldSoft,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lightbulb_outline_rounded, size: 14, color: c.gold),
                    const SizedBox(width: 4),
                    Text(
                      'كلمة اليوم الربانية',
                      style: TextStyle(
                        fontFamily: AppTheme.uiFont,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: c.gold,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text('سورة طه: ١١٤', style: TextStyle(fontSize: 11, color: c.textMuted)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  '﴿وَقُل رَّبِّ زِدْنِي عِلْمًا﴾',
                  style: TextStyle(
                    fontFamily: AppTheme.quranFont,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: c.accent,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: _toggle,
                customBorder: const CircleBorder(),
                child: Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _playing ? c.gold : c.goldSoft,
                    border: Border.all(color: c.gold),
                  ),
                  child: Icon(
                    _playing ? Icons.stop_rounded : Icons.play_arrow_rounded,
                    size: 19,
                    color: _playing ? c.surface : c.gold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '“Dan katakanlah: Wahai Tuhanku, tambahkanlah kepadaku ilmu pengetahuan.”',
            style: TextStyle(
              fontSize: 12.5,
              fontStyle: FontStyle.italic,
              color: c.textMuted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SemesterSectionHeader extends StatelessWidget {
  const _SemesterSectionHeader();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.border),
        boxShadow: [
          BoxShadow(color: c.cardShadow, blurRadius: 18, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 22,
              decoration: BoxDecoration(
                color: c.accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'اللغة العربية الربانية ١ - ٣',
              style: TextStyle(
                fontFamily: AppTheme.uiFont,
                fontWeight: FontWeight.w900,
                fontSize: 20,
                color: c.text,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'اختر الكتاب لمتابعة الفصول والوحدات والأنشطة التفاعلية.',
          style: TextStyle(
            fontFamily: AppTheme.uiFont,
            fontSize: 13,
            color: c.textMuted,
          ),
        ),
        ],
      ),
    );
  }
}

class _SemesterCard extends StatefulWidget {
  const _SemesterCard({required this.info});
  final _SemesterInfo info;

  @override
  State<_SemesterCard> createState() => _SemesterCardState();
}

class _SemesterCardState extends State<_SemesterCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final info = widget.info;
    final progress = info.n == 1
        ? context.watch<AppState>().dars111Progress(Dars111.selfAssessItems.length)
        : null;

    final isEnabled = info.enabled;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        transform: Matrix4.translationValues(0, (_hover && isEnabled) ? -4 : 0, 0),
        child: Material(
          color: c.surface,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: isEnabled
                ? () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const Semester1Screen()),
                    )
                : null,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: (_hover && isEnabled)
                      ? c.accent
                      : (isEnabled ? c.border : c.border.withValues(alpha: 0.6)),
                  width: (_hover && isEnabled) ? 1.6 : 1,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (_hover && isEnabled)
                        ? c.accent.withValues(alpha: 0.16)
                        : c.cardShadow,
                    blurRadius: (_hover && isEnabled) ? 20 : 12,
                    offset: Offset(0, (_hover && isEnabled) ? 8 : 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    Positioned(
                      top: -24,
                      right: -24,
                      child: GeometricCornerMotif(
                        color: isEnabled
                            ? c.accent.withValues(alpha: 0.12)
                            : Colors.grey.withValues(alpha: 0.08),
                        size: 96,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(22),
                      child: Opacity(
                        opacity: isEnabled ? 1 : 0.6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 46,
                                  height: 46,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isEnabled ? c.accentSoft : c.surface2,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isEnabled
                                          ? c.accent.withValues(alpha: 0.3)
                                          : c.border,
                                    ),
                                  ),
                                  child: Text(
                                    toArabicNumerals(info.n),
                                    style: TextStyle(
                                      fontFamily: AppTheme.quranFont,
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: isEnabled ? c.accent : c.textMuted,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isEnabled ? c.accentSoft : c.surface2,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isEnabled ? Icons.check_circle_rounded : Icons.lock_outline_rounded,
                                        size: 12,
                                        color: isEnabled ? c.accent : c.textMuted,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        isEnabled ? 'متاح الآن' : 'قريبا',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: isEnabled ? c.accent : c.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              info.title,
                              style: TextStyle(
                                fontFamily: AppTheme.uiFont,
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                                color: c.text,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              info.meta,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: c.gold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              info.unitsPreview,
                              style: TextStyle(fontSize: 12, color: c.textMuted, height: 1.4),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 16),
                            if (progress != null && progress > 0) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('التقدم في الفصل', style: TextStyle(fontSize: 11, color: c.textMuted)),
                                  Text('٪${(progress * 100).round()}',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: c.accent)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 6,
                                  backgroundColor: c.border,
                                  valueColor: AlwaysStoppedAnimation(c.accent),
                                ),
                              ),
                              const SizedBox(height: 14),
                            ] else ...[
                              Divider(height: 24, color: c.border.withValues(alpha: 0.6)),
                            ],
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  isEnabled ? 'ادخل الفصل' : 'مغلق حاليا',
                                  style: TextStyle(
                                    fontFamily: AppTheme.uiFont,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: isEnabled ? c.accent : c.textMuted,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_back_rounded,
                                  size: 16,
                                  color: isEnabled ? c.accent : c.textMuted,
                                ),
                              ],
                            ),
                          ],
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

