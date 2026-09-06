import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:donut_spinning_app/feature/donut/presentation/model/donut_flavor.dart';
import 'package:donut_spinning_app/feature/donut/presentation/widget/search_fab_button.dart';

/// A single transparent donut PNG in the carousel — no plate attached.
///
/// The plate lives once, statically, behind the whole [PageView] (see
/// [DonutCarousel]); this item only ever draws its donut, so every visual
/// property is pure algebra on [pageOffset] vs. this item's own [index] —
/// no local state, no controllers of its own — which is what lets the
/// whole card track the [PageView]'s live scroll position 1:1 during a
/// manual drag, including continuous Z-axis rotation as the user swipes.
class DonutCarouselItem extends StatelessWidget {
  const DonutCarouselItem({
    super.key,
    required this.flavor,
    required this.index,
    required this.pageOffset,
    required this.centerDonutSize,
    required this.onSearchTap,
  });

  final DonutFlavor flavor;
  final int index;
  final double pageOffset;
  final double centerDonutSize;
  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);

    // Signed distance, in pages, between this item and the live scroll
    // position: 0 when dead center, +/-1 when it's the fully settled
    // neighbour, growing further for items still more pages away.
    final offset = pageOffset - index;
    final absOffset = offset.abs();

    // Half a turn per page of drag — the donut spins continuously around
    // its own center as it's dragged toward or away from the middle,
    // tracking the finger 1:1 rather than snapping into place.
    final rotationAngle = offset * math.pi;
    final scale = (1 - (absOffset * 0.35)).clamp(0.6, 1.0);
    final opacity = (1 - (absOffset * 0.6)).clamp(0.3, 1.0);

    // The search glyph only makes sense once its donut is basically
    // centered over the plate, so it fades in/out much faster than the
    // donut itself as the item approaches or leaves the middle.
    final searchOpacity = (1 - absOffset * 3.2).clamp(0.0, 1.0);
    final searchScale = ui.lerpDouble(0.6, 1.0, searchOpacity)!;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: opacity,
            child: Transform.rotate(
              angle: rotationAngle,
              child: Transform.scale(
                scale: scale,
                child: Image.asset(
                  flavor.image,
                  width: centerDonutSize,
                  height: centerDonutSize,
                  cacheWidth: (centerDonutSize * dpr).round(),
                  filterQuality: FilterQuality.medium,
                ),
              ),
            ),
          ),
          if (searchOpacity > 0)
            Opacity(
              opacity: searchOpacity,
              child: Transform.scale(
                scale: searchScale,
                child: SearchFabButton(
                  size: math.max(centerDonutSize * 0.135, 34),
                  onTap: onSearchTap,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
