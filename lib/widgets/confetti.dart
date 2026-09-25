import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A short, light confetti burst drawn with a CustomPainter (no package).
/// Plays once for ~1.6 s, ignores pointer input, and renders nothing when
/// the user prefers reduced motion.
class ConfettiBurst extends StatefulWidget {
  const ConfettiBurst({super.key, this.pieces = 70});
  final int pieces;

  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<ConfettiBurst> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))
    ..forward();
  late final List<_Piece> _pieces;

  @override
  void initState() {
    super.initState();
    final r = math.Random(42);
    _pieces = List.generate(widget.pieces, (_) {
      final angle = -math.pi / 2 + (r.nextDouble() - 0.5) * math.pi * 0.9;
      final speed = 0.55 + r.nextDouble() * 0.6;
      return _Piece(
        vx: math.cos(angle) * speed,
        vy: math.sin(angle) * speed,
        spin: (r.nextDouble() - 0.5) * 12,
        size: 5 + r.nextDouble() * 5,
        colorIndex: r.nextInt(4),
      );
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) return const SizedBox.shrink();
    final col = context.colors;
    final palette = [col.gold, col.accent, col.accent2, col.success];
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) =>
            CustomPaint(painter: _ConfettiPainter(_pieces, _c.value, palette), size: Size.infinite),
      ),
    );
  }
}

class _Piece {
  _Piece({required this.vx, required this.vy, required this.spin, required this.size, required this.colorIndex});
  final double vx, vy, spin, size;
  final int colorIndex;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.pieces, this.t, this.palette);
  final List<_Piece> pieces;
  final double t;
  final List<Color> palette;

  @override
  void paint(Canvas canvas, Size size) {
    final origin = Offset(size.width / 2, size.height * 0.45);
    final scale = size.shortestSide * 0.9;
    final fade = t < 0.7 ? 1.0 : (1 - (t - 0.7) / 0.3);
    for (final p in pieces) {
      final x = origin.dx + p.vx * scale * t;
      final y = origin.dy + p.vy * scale * t + 0.9 * scale * t * t; // gravity
      final paint = Paint()..color = palette[p.colorIndex].withValues(alpha: fade.clamp(0.0, 1.0));
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.spin * t);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.55),
          const Radius.circular(1.5),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => old.t != t;
}
