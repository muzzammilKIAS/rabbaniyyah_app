import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/atmosphere.dart';
import 'dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _pulse;
  bool _showCta = false;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..repeat();
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) setState(() => _showCta = true);
    });
  }

  @override
  void dispose() {
    _entrance.dispose();
    _pulse.dispose();
    super.dispose();
  }

  void _go() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PageBackdrop(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _go,
          child: Center(
            child: FadeTransition(
              opacity: CurvedAnimation(parent: _entrance, curve: const Interval(0, 0.6)),
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
                    .animate(CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: _pulse,
                      builder: (context, child) {
                        final t = _pulse.value;
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Opacity(
                              opacity: (1 - t).clamp(0.0, 1.0),
                              child: Container(
                                width: 84 + t * 36,
                                height: 84 + t * 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: c.gold.withValues(alpha: 0.5)),
                                ),
                              ),
                            ),
                            child!,
                          ],
                        );
                      },
                      child: Container(
                        width: 84,
                        height: 84,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: c.gold, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: c.accent.withValues(alpha: 0.4),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset('assets/images/rabbani_mark_circle.png', fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'اللغة العربية الربانية',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTheme.uiFont,
                        fontWeight: FontWeight.w900,
                        fontSize: 38,
                        color: c.text,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'كِتَابٌ يَجْمَعُ بَيْنَ تَعَلُّمِ اللُّغَةِ وَتَرْسِيخِ الْقِيَمِ الرَّبَّانِيَّةِ فِي آنٍ وَاحِدٍ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppTheme.arabicFont,
                          fontSize: 17.5,
                          color: c.accent,
                          height: 1.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 38),
                    AnimatedOpacity(
                      opacity: _showCta ? 1 : 0,
                      duration: const Duration(milliseconds: 500),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: c.surface,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: c.border),
                          boxShadow: [
                            BoxShadow(
                              color: c.cardShadow,
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'انقر للبدء في التعلم',
                              style: TextStyle(
                                fontFamily: AppTheme.uiFont,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: c.accent,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.arrow_back_rounded, color: c.gold, size: 18),
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
