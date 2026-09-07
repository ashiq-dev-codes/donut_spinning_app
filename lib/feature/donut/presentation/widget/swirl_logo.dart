import 'dart:math' as math;
import 'package:flutter/material.dart';

/// The small pinwheel "dodonut" brand mark, continuously spinning.
///
/// Hand-painted with [CustomPainter] (no svg asset was supplied) so its
/// color can crossfade live with the current flavor's accent.
class SwirlLogo extends StatefulWidget {
  const SwirlLogo({super.key, required this.color, this.size = 34});

  final Color color;
  final double size;

  @override
  State<SwirlLogo> createState() => _SwirlLogoState();
}

class _SwirlLogoState extends State<SwirlLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 7),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(painter: _SwirlPainter(color: widget.color)),
      ),
    );
  }
}

class _SwirlPainter extends CustomPainter {
  _SwirlPainter({required this.color});

  final Color color;
  static const int petalCount = 8;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;

    canvas.translate(center.dx, center.dy);

    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final petal = _petalPath(radius);

    for (var i = 0; i < petalCount; i++) {
      canvas.save();
      canvas.rotate(i * (2 * math.pi / petalCount));
      canvas.drawPath(petal, fill);
      canvas.restore();
    }
  }

  // A fan blade that's narrow at the hub and rounded at the outer tip —
  // not a pointed star spike — rotated around the center this reads as a
  // spinning pinwheel/vortex, matching the Figma mark. No stroke: the
  // reference blends petals as solid overlapping fills, not outlined
  // segments.
  Path _petalPath(double radius) {
    final tip = -radius * 0.98;
    return Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(radius * 0.78, tip * 0.22, radius * 0.16, tip * 0.94)
      ..quadraticBezierTo(radius * 0.02, tip * 1.04, -radius * 0.14, tip * 0.9)
      ..quadraticBezierTo(-radius * 0.05, tip * 0.5, 0, 0)
      ..close();
  }

  @override
  bool shouldRepaint(covariant _SwirlPainter oldDelegate) =>
      oldDelegate.color != color;
}
