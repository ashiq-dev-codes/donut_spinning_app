import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:donut_spinning_app/feature/donut/presentation/model/donut_flavor.dart';
import 'package:donut_spinning_app/feature/donut/presentation/widget/search_fab_button.dart';

/// A single carousel item — a bare donut, no plate attached.
///
/// The plate is a single centered background layer owned by
/// [DonutCarousel]; it only shows through once a donut settles dead
/// center over it, so every item here is just the donut itself, riding a
/// curved arc — sagging slightly downward via [translateY] the further it
/// sits from the middle — rather than sliding on a flat horizontal line.
/// Every visual property is pure algebra on [pageOffset] vs. this item's
/// own [index] — no local state, no controllers of its own — which is
/// what lets the whole card track the [PageView]'s live scroll position
/// 1:1 during a manual drag. Rotation is layered on independently of the
/// arc/scale/opacity: the donut keeps spinning continuously around its
/// own center as it's dragged, on top of wherever the arc has placed it.
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
    final offset = index - pageOffset;
    final absOffset = offset.abs();

    // Curved arc: the further an item sits from center, the more it sags
    // downward (quadratically, so the arc steepens toward the edges)
    // instead of sliding past on a flat horizontal line.
    final translateY = math.pow(absOffset, 2) * 28.0;
    final scale = (1 - (absOffset * 0.35)).clamp(0.55, 1.0);
    final opacity = (1 - (absOffset * 0.55)).clamp(0.2, 1.0);

    // Half a turn per page of drag — the donut spins continuously around
    // its own center as it's dragged toward or away from the middle,
    // tracking the finger 1:1 rather than snapping into place. This is
    // layered independently of the arc translate/scale above.
    final rotationAngle = offset * math.pi;

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
            child: Transform.translate(
              offset: Offset(0, translateY),
              child: Transform.scale(
                scale: scale,
                child: Transform.rotate(
                  angle: rotationAngle,
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
