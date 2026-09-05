import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

class CelebrationDialog extends StatefulWidget {
  const CelebrationDialog({super.key, this.title, this.message});

  final String? title;
  final String? message;

  static Future<void> show(BuildContext context, {String? title, String? message}) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => CelebrationDialog(title: title, message: message),
    );
  }

  @override
  State<CelebrationDialog> createState() => _CelebrationDialogState();
}

class _CelebrationDialogState extends State<CelebrationDialog> with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ScaleTransition(
      scale: CurvedAnimation(parent: _anim, curve: Curves.elasticOut),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 440),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: c.goldBorder, width: 1.6),
            boxShadow: [
              BoxShadow(
                color: c.gold.withValues(alpha: 0.25),
                blurRadius: 36,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [c.gold, c.accent2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: c.gold.withValues(alpha: 0.4),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(Icons.star_rounded, color: c.gold, size: 28),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.title ?? 'ممتاز! بارك الله فيك',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTheme.uiFont,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  color: c.accent,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.message ??
                    'لقد أتممت أنشطة وتقييم الدرس الأول (الإيمان بالله) بنجاح. هنيئا لك هذا التقدم المبارك!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: c.textMuted,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: c.accentSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.military_tech_rounded, size: 20, color: c.accent),
                    const SizedBox(width: 8),
                    Text(
                      'أتممت كل أهداف الدرس ١',
                      style: TextStyle(
                        fontFamily: AppTheme.uiFont,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: c.accent,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('الحمد لله · تابع'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

