import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/game_link.dart';
import 'atmosphere.dart';

/// Banner promosi permainan kelas langsung "Rabbaniyyah Mountain Challenge".
///
/// Membuka [kGameUrl] pada tab/tetingkap baharu supaya pelajar tidak
/// kehilangan kemajuan modul semasa apabila kembali ke app ini.
class GameBanner extends StatefulWidget {
  const GameBanner({super.key});

  @override
  State<GameBanner> createState() => _GameBannerState();
}

class _GameBannerState extends State<GameBanner> {
  bool _hover = false;
  bool _opening = false;

  Future<void> _open() async {
    if (_opening) return;
    setState(() => _opening = true);
    try {
      final uri = Uri.parse(kGameUrl);
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر فتح رابط التحدي. حاول مرة أخرى.')),
        );
      }
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        transform: Matrix4.translationValues(0, _hover ? -4 : 0, 0),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: _open,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [c.accentStrong, c.accent],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: c.accent.withValues(alpha: _hover ? 0.35 : 0.22),
                    blurRadius: _hover ? 24 : 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    Positioned(
                      top: -20,
                      left: -20,
                      child: GeometricCornerMotif(color: Colors.white.withValues(alpha: 0.14), size: 110),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
                          ),
                          child: const Text('⛰', style: TextStyle(fontSize: 26)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: const Text(
                                      'جديد · لعبة صفية مباشرة',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'تحدي جبل الربانية',
                                style: TextStyle(
                                  fontFamily: AppTheme.uiFont,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'سِبَاقٌ إِلَى الْقِمَّةِ — أجب عن الأسئلة وتسلّق الجبل مباشرة أمام الفصل.',
                                style: TextStyle(
                                  fontFamily: AppTheme.uiFont,
                                  fontSize: 12.5,
                                  height: 1.6,
                                  color: Colors.white.withValues(alpha: 0.92),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: _opening
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'ابدأ اللعب',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                        color: c.accentStrong,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(Icons.arrow_outward_rounded, size: 16, color: c.accentStrong),
                                  ],
                                ),
                        ),
                      ],
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
