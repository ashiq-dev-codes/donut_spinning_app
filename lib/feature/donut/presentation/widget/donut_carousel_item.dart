import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:donut_spinning_app/feature/donut/presentation/model/donut_flavor.dart';
import 'package:donut_spinning_app/feature/donut/presentation/widget/search_fab_button.dart';
import 'package:donut_spinning_app/shared/path/app_images.dart';

/// A single plate+donut in the carousel.
///
/// [delta] is the signed distance (in pages) between this item and the
/// currently centered page: 0 when perfectly centered, +/-1 when it is the
/// fully settled neighbour. Every visual property is derived from it so the
/// whole card tracks the [PageView]'s live scroll position 1:1 during a
/// manual drag — including the plate, which rides in from below the
/// carousel as it becomes centered and exits upward as it's swiped away,
/// matching the Figma prototype.
class DonutCarouselItem extends StatelessWidget {
  const DonutCarouselItem({
    super.key,
    required this.flavor,
    required this.delta,
    required this.centerDonutSize,
    required this.plateTravelDistance,
    required this.onSearchTap,
  });

  final DonutFlavor flavor;
  final double delta;
  final double centerDonutSize;
  final double plateTravelDistance;
  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    final absDelta = delta.abs().clamp(0.0, 1.0);
    final dpr = MediaQuery.devicePixelRatioOf(context);

    final donutScale = ui.lerpDouble(1.0, 0.52, absDelta)!;
    final donutOpacity = ui.lerpDouble(1.0, 0.38, absDelta)!;

    // The plate rides a vertical lane: below the carousel while its donut
    // is still off to one side, sliding through center, then out the top
    // as it's swiped past. The carousel's own clipped bounds crop most of
    // that travel away, but a quick fade over the last stretch guarantees
    // no plate edge is left peeking in a corner once a card is fully
    // settled as a side item.
    final plateTranslateY = delta * plateTravelDistance;
    final plateScale = ui.lerpDouble(1.0, 0.9, absDelta)!;
    final plateTilt = delta * 0.09;
    final plateOpacity = (1 - ((absDelta - 0.7) / 0.3).clamp(0.0, 1.0));

    final searchOpacity = (1 - absDelta * 3.2).clamp(0.0, 1.0);
    final searchScale = ui.lerpDouble(0.6, 1.0, searchOpacity)!;

    final plateSize = centerDonutSize * 1.16;

    return Center(
      child: OverflowBox(
        minWidth: 0,
        minHeight: 0,
        maxWidth: centerDonutSize * 1.3,
        maxHeight: plateTravelDistance * 2 + plateSize,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            if (plateOpacity > 0)
              Opacity(
                opacity: plateOpacity,
                child: Transform.translate(
                  offset: Offset(0, plateTranslateY),
                  child: Transform.rotate(
                    angle: plateTilt,
                    child: Transform.scale(
                      scale: plateScale,
                      child: Image.asset(
                        AppImages.plate,
                        width: plateSize,
                        height: plateSize,
                        cacheWidth: (plateSize * dpr).round(),
                        filterQuality: FilterQuality.medium,
                      ),
                    ),
                  ),
                ),
              ),
            Opacity(
              opacity: donutOpacity,
              child: Transform.scale(
                scale: donutScale,
                child: Image.asset(
                  flavor.image,
                  width: centerDonutSize,
                  height: centerDonutSize,
                  cacheWidth: (centerDonutSize * dpr).round(),
                  filterQuality: FilterQuality.medium,
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
      ),
    );
  }
}
