import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:donut_spinning_app/feature/donut/presentation/model/donut_flavor.dart';

/// A flavor's four key colors, linearly blended with its neighbor by however
/// far through the page-scroll we currently are.
class FlavorPalette {
  const FlavorPalette({
    required this.glow,
    required this.mid,
    required this.edge,
    required this.accent,
  });

  final Color glow;
  final Color mid;
  final Color edge;
  final Color accent;

  factory FlavorPalette.blend(List<DonutFlavor> flavors, double page) {
    // Clamped, not wrapped: Strawberry Bliss and Pistachio Perfection are a
    // hard start/end, so an elastic overscroll past either edge should just
    // hold that end's colors rather than blending toward the other end.
    final clampedPage = page.clamp(0.0, flavors.length - 1.0);
    final lowIndex = clampedPage.floor();
    final highIndex = (lowIndex + 1).clamp(0, flavors.length - 1);
    final t = (clampedPage - lowIndex).clamp(0.0, 1.0);
    final low = flavors[lowIndex];
    final high = flavors[highIndex];
    return FlavorPalette(
      glow: Color.lerp(low.glow, high.glow, t)!,
      mid: Color.lerp(low.mid, high.mid, t)!,
      edge: Color.lerp(low.edge, high.edge, t)!,
      accent: Color.lerp(low.accent, high.accent, t)!,
    );
  }
}

/// Full-bleed radial gradient that crossfades between flavor colors in
/// real time as [page] changes, matching the color wash seen behind each
/// donut in the Figma prototype.
class AnimatedFlavorBackground extends StatelessWidget {
  const AnimatedFlavorBackground({
    super.key,
    required this.page,
    required this.flavors,
    required this.builder,
  });

  final ValueListenable<double> page;
  final List<DonutFlavor> flavors;
  final Widget Function(BuildContext context, FlavorPalette palette) builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // The Figma frame is landscape (1440x1024) — its corners and the
        // area straight down from center are comparably far from the glow,
        // so a plain circular gradient there already reaches proportionally
        // far in both directions. Our phone screen is tall and narrow, so
        // that's no longer true: going straight down to the bottom covers
        // almost as much distance as the actual (diagonal) corner does.
        // A plain circle tuned to keep the corners dark ends up fading out
        // right below the logo, long before it reaches the donut — a plain
        // circle tuned to reach the donut floods the corners with color.
        // _EllipticalGradientTransform below squashes the circle into an
        // ellipse matching the screen's own aspect ratio, so it reaches the
        // bottom edge and the side corners in the same proportion the
        // reference's landscape frame does.
        final size = constraints.biggest;
        final aspect = size.height / size.width;

        return ValueListenableBuilder<double>(
          valueListenable: page,
          builder: (context, value, _) {
            final palette = FlavorPalette.blend(flavors, value);
            return Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0, -0.09),
                        radius: 0.85,
                        colors: [palette.glow, palette.mid, palette.edge],
                        stops: const [0.0, 0.5, 1.0],
                        transform: _EllipticalGradientTransform(aspect),
                      ),
                    ),
                  ),
                ),
                const Positioned.fill(child: _GrainOverlay()),
                builder(context, palette),
              ],
            );
          },
        );
      },
    );
  }
}

/// Stretches a [RadialGradient]'s circle into an ellipse matching the
/// paint box's own aspect ratio, scaling around the box's center. Without
/// this, [RadialGradient.radius] (a fraction of the shorter side) makes a
/// gradient that reaches equally far in every direction — fine for a
/// roughly-square box, but on a tall phone screen that means either the
/// glow stays trapped near the top or it floods all the way out to the
/// side corners. See the call site for the full reasoning.
class _EllipticalGradientTransform extends GradientTransform {
  const _EllipticalGradientTransform(this.aspect);

  /// Height / width of the box the gradient is painted into.
  final double aspect;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    final center = bounds.center;
    return Matrix4.identity()
      ..translateByDouble(center.dx, center.dy, 0, 1)
      ..scaleByDouble(1.0, aspect, 1.0, 1)
      ..translateByDouble(-center.dx, -center.dy, 0, 1);
  }
}

/// The faint film-grain speckle visible over every flat area of the Figma
/// prototype's background — without it the gradient reads as flat,
/// digitally-smooth color instead of the slightly textured wash the
/// reference has everywhere.
///
/// Painted once as a fixed set of points (seeded, so it doesn't shimmer/
/// re-randomize on rebuild) and wrapped in [RepaintBoundary] so it's
/// composited to its own cached layer — it never needs to redraw just
/// because the gradient behind it is recoloring every scroll frame.
class _GrainOverlay extends StatelessWidget {
  const _GrainOverlay();

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(painter: _GrainPainter(), size: Size.infinite),
      ),
    );
  }
}

class _GrainPainter extends CustomPainter {
  const _GrainPainter();

  static final List<Offset> _unitPoints = List.generate(
    2400,
    (_) => Offset(_random.nextDouble(), _random.nextDouble()),
    growable: false,
  );
  static final math.Random _random = math.Random(7);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.035)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;
    final points = <Offset>[
      for (final p in _unitPoints) Offset(p.dx * size.width, p.dy * size.height),
    ];
    canvas.drawPoints(ui.PointMode.points, points, paint);
  }

  @override
  bool shouldRepaint(covariant _GrainPainter oldDelegate) => false;
}
