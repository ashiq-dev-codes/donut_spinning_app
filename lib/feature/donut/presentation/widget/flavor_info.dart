import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:donut_spinning_app/feature/donut/presentation/model/donut_flavor.dart';

/// Flavor name + description, crossfading live as the carousel scrolls.
///
/// Pure algebra on the live [page] value — no [AnimatedSwitcher], no
/// post-settle timer — matching every other transition in this app (the
/// donut, the plate, the background wash). In the Figma reference the
/// outgoing and incoming title/description are visibly overlaid mid-drag
/// (this is what a scroll-driven crossfade looks like, and the opposite
/// of a discrete "switch once settled" animation, which would only ever
/// show one block at a time), so this tracks the drag 1:1 and freezes the
/// instant it stops, exactly like the donut and plate already do.
class FlavorInfo extends StatelessWidget {
  const FlavorInfo({super.key, required this.flavors, required this.page});

  final List<DonutFlavor> flavors;
  final ValueListenable<double> page;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: ClipRect(
        child: ValueListenableBuilder<double>(
          valueListenable: page,
          builder: (context, value, _) {
            // Clamped, not wrapped — Strawberry Bliss and Pistachio
            // Perfection are a hard start/end, so an elastic overscroll
            // past either edge just holds that end's text in place
            // rather than crossfading toward a neighbour that isn't there.
            final clamped = value.clamp(0.0, flavors.length - 1.0);
            final lowIndex = clamped.floor();
            final highIndex = (lowIndex + 1).clamp(0, flavors.length - 1);
            final t = (clamped - lowIndex).clamp(0.0, 1.0);

            return Stack(
              alignment: Alignment.center,
              children: [
                if (t < 1.0)
                  _FlavorText(flavor: flavors[lowIndex], opacity: 1 - t),
                if (t > 0.0)
                  _FlavorText(flavor: flavors[highIndex], opacity: t),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// One flavor's title + description, faded in place by however far it's
/// traveled through the crossfade — no movement, just opacity, matching
/// the Figma reference (the text stays put; only its alpha changes).
class _FlavorText extends StatelessWidget {
  const _FlavorText({required this.flavor, required this.opacity});

  final DonutFlavor flavor;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            flavor.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 28,
              height: 1.15,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            flavor.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: flavor.accent.withValues(alpha: 0.75),
              fontWeight: FontWeight.w400,
              fontSize: 14.5,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
