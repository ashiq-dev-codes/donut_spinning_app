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
    return ValueListenableBuilder<double>(
      valueListenable: page,
      builder: (context, value, _) {
        final palette = FlavorPalette.blend(flavors, value);
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, -0.55),
              radius: 1.3,
              colors: [palette.glow, palette.mid, palette.edge],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: builder(context, palette),
        );
      },
    );
  }
}
