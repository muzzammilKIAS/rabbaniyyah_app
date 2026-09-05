import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Draws one eight-pointed star motif — two squares overlapped at 45°
/// with a small rosette at the centre, the classic geometric building
/// block of Islamic ornament. Shared by [GeometricPatternOverlay] (tiled
/// across a background) and [GeometricCornerMotif] (a single accent on a
/// card corner). Ported from aplikasi_haji_pintar's shared motif painter.
void drawStarMotif(Canvas canvas, Offset center, double r, Paint paint) {
  final s = r * 0.86;
  final square = Path()
    ..addPolygon(<Offset>[
      center + Offset(-s, -s),
      center + Offset(s, -s),
      center + Offset(s, s),
      center + Offset(-s, s),
    ], true);
  canvas.drawPath(square, paint);
  canvas.save();
  canvas.translate(center.dx, center.dy);
  canvas.rotate(math.pi / 4);
  canvas.translate(-center.dx, -center.dy);
  canvas.drawPath(square, paint);
  canvas.restore();
  canvas.drawCircle(center, r * 0.22, paint);
}

/// Faint, full-bleed repeating geometric pattern — a subtle nod to
/// manuscript/mosque ornament, never strong enough to compete with content.
class GeometricPatternOverlay extends StatelessWidget {
  const GeometricPatternOverlay({super.key, required this.color, this.opacity = 0.045});
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(painter: _PatternPainter(color: color.withValues(alpha: opacity))),
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  _PatternPainter({required this.color});
  final Color color;
  static const double _tile = 132;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    final cols = (size.width / _tile).ceil() + 1;
    final rows = (size.height / _tile).ceil() + 1;
    for (var row = -1; row < rows; row++) {
      for (var col = -1; col < cols; col++) {
        final center = Offset(col * _tile + _tile / 2, row * _tile + _tile / 2);
        drawStarMotif(canvas, center, _tile * 0.5, stroke);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PatternPainter old) => old.color != color;
}

/// A single star motif for a card corner — usually positioned slightly
/// off-canvas so it's clipped by the card's rounded corner.
class GeometricCornerMotif extends StatelessWidget {
  const GeometricCornerMotif({super.key, required this.color, this.size = 84});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(size: Size(size, size), painter: _CornerPainter(color: color)),
    );
  }
}

class _CornerPainter extends CustomPainter {
  _CornerPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    drawStarMotif(canvas, Offset(size.width / 2, size.height / 2), size.width / 2, stroke);
  }

  @override
  bool shouldRepaint(covariant _CornerPainter old) => old.color != color;
}

/// A large, heavily-blurred colour disc used to build soft ambient glow
/// behind a page's content — cheap atmosphere that reads as depth rather
/// than decoration.
class GlowCircle extends StatelessWidget {
  const GlowCircle({super.key, required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: const SizedBox.expand()),
    );
  }
}

/// Plays a fade + slide-up entrance for [child] over the slice
/// [start, end] of [controller]'s 0..1 timeline — used to stagger a
/// page's sections in from top to bottom instead of popping in at once.
class Staggered extends StatelessWidget {
  const Staggered({super.key, required this.controller, required this.start, required this.end, required this.child});
  final AnimationController controller;
  final double start;
  final double end;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final fade = CurvedAnimation(parent: controller, curve: Interval(start, end, curve: Curves.easeOutCubic));
    return FadeTransition(
      opacity: fade,
      child: AnimatedBuilder(
        animation: fade,
        builder: (context, innerChild) => Transform.translate(offset: Offset(0, (1 - fade.value) * 18), child: innerChild),
        child: child,
      ),
    );
  }
}

/// Full-bleed page background shared by every screen: a soft 3-stop
/// gradient, a faint tiled geometric pattern, and two slowly "breathing"
/// glow discs — so the page reads as one atmospheric web surface rather
/// than a small card floating in blank space either side.
class PageBackdrop extends StatefulWidget {
  const PageBackdrop({super.key, required this.child});
  final Widget child;

  @override
  State<PageBackdrop> createState() => _PageBackdropState();
}

class _PageBackdropState extends State<PageBackdrop> with SingleTickerProviderStateMixin {
  late final AnimationController _breathe;

  @override
  void initState() {
    super.initState();
    _breathe = AnimationController(vsync: this, duration: const Duration(milliseconds: 3600))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breathe.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [c.gradientStart, c.gradientMiddle, c.gradientEnd],
        ),
      ),
      child: Stack(
        children: [
          GeometricPatternOverlay(color: c.text),
          AnimatedBuilder(
            animation: _breathe,
            builder: (context, child) {
              final t = _breathe.value;
              return Stack(children: [
                Positioned(
                  top: -120 + t * 12,
                  right: -90,
                  child: GlowCircle(size: 300 + t * 16, color: c.accent.withValues(alpha: 0.14 + t * 0.05)),
                ),
                Positioned(
                  bottom: -150 + t * 14,
                  left: -100,
                  child: GlowCircle(size: 320 - t * 18, color: c.accent2.withValues(alpha: 0.10 + t * 0.04)),
                ),
              ]);
            },
          ),
          widget.child,
        ],
      ),
    );
  }
}
