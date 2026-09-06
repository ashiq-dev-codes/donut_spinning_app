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
    final stroke = Paint()
      ..color = Color.lerp(color, Colors.black, 0.55)!.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.045
      ..strokeJoin = StrokeJoin.round;

    final petal = _petalPath(radius);

    for (var i = 0; i < petalCount; i++) {
      canvas.save();
      canvas.rotate(i * (2 * math.pi / petalCount));
      canvas.drawPath(petal, fill);
      canvas.drawPath(petal, stroke);
      canvas.restore();
    }
  }

  Path _petalPath(double radius) {
    final tip = -radius * 0.96;
    return Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(radius * 0.58, tip * 0.62, 0, tip)
      ..quadraticBezierTo(-radius * 0.22, tip * 0.46, 0, 0)
      ..close();
  }

  @override
  bool shouldRepaint(covariant _SwirlPainter oldDelegate) =>
      oldDelegate.color != color;
}
