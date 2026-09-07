import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:donut_spinning_app/feature/donut/presentation/model/donut_flavor.dart';
import 'package:donut_spinning_app/feature/donut/presentation/widget/search_fab_button.dart';
import 'package:donut_spinning_app/shared/path/app_images.dart';
import 'package:flutter/material.dart';

/// A single carousel item — a donut riding its own plate.
///
/// Every visual property here is pure algebra on [pageOffset] vs. this
/// item's own [index] — no local state, no controllers, no clock — so the
/// whole item tracks the [PageView]'s live scroll position 1:1 during a
/// manual drag and freezes the instant the drag stops.
///
/// The plate and the donut are built as two fully independent layers
/// ([_PlateLayer], [_DonutLayer]), each with its own isolated transform
/// chain. Nothing here ever wraps both layers (or the FAB) in a shared
/// `Transform.rotate` — that's what previously made the whole card appear
/// to tilt. The only rotation in this widget is the plate's own spin,
/// applied to nothing but its `Image.asset`.
class DonutCarouselItem extends StatelessWidget {
  const DonutCarouselItem({
    super.key,
    required this.flavor,
    required this.index,
    required this.pageOffset,
    required this.centerDonutSize,
    required this.itemExtent,
    required this.onSearchTap,
  });

  final DonutFlavor flavor;
  final int index;
  final double pageOffset;
  final double centerDonutSize;

  /// Live pixel width of one carousel page, supplied by [DonutCarousel]'s
  /// own [LayoutBuilder] — the unit of length the arc math needs to turn a
  /// page-fraction offset into a real vertical sag in logical pixels.
  final double itemExtent;
  final VoidCallback onSearchTap;

  /// Barely-there quadratic sag for the donut layer — the Figma reference
  /// (`UI/1.mov`) keeps the donut at almost exactly the same height the
  /// entire time it slides from center out to the settled neighbour spot,
  /// so this is just enough curvature to avoid a perfectly robotic flat
  /// line, nowhere near a real arc.
  static const _donutSagCoefficient = 0.02;

  /// How far the plate throws vertically per page of offset, as a
  /// multiple of [centerDonutSize]. In the reference recording the plate
  /// is never seen easing gently along with its donut — it's already
  /// off-screen (top or bottom) well before its donut reaches the
  /// neighbour position, like a separate object being lifted straight up
  /// out of frame rather than riding the donut's own arc.
  static const _plateThrowDistance = 2.2;

  /// Radians of plate spin per page of scroll — one full turn per page.
  /// Driven by the raw [pageOffset], not this item's own [index], so
  /// every plate on screen shows the same shared dish angle rather than
  /// each restarting from zero as it cycles into view.
  static const _plateSpinPerPage = 2 * math.pi;

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);

    // Signed distance, in pages, between this item and the live scroll
    // position: 0 when dead center, +/-1 when it's the fully settled
    // neighbour, growing further for items still more pages away.
    final dx = index - pageOffset;
    final absOffset = dx.abs();

    final donutTranslateY = _donutSagCoefficient * dx * dx * itemExtent;

    // Linear and signed, not the donut's symmetric quadratic sag: a plate
    // still arriving (positive dx) sits below center and rises up into
    // place; once it's passed (negative dx) it keeps rising up and away,
    // rather than mirroring back down. One continuous upward conveyor.
    final plateTranslateY = dx * centerDonutSize * _plateThrowDistance;

    // Horizontally, the plate rides the PageView's own left/right
    // placement of this item on the way in (dx > 0) — that's what puts an
    // arriving plate at bottom-*right*. But we don't want it to keep
    // riding that placement out to the left once the item has passed
    // (dx < 0): this term exactly cancels the PageView's own shift for
    // dx < 0 and replaces it with the mirror image, so the plate keeps
    // exiting toward the right — bottom-right in, top-right out — instead
    // of trailing off to the top-left with its donut.
    final plateTranslateX = dx < 0 ? -2 * dx * itemExtent : 0.0;

    final donutScale = (1.0 - absOffset * 0.62).clamp(0.32, 1.0);
    final donutOpacity = (1.0 - absOffset * 0.35).clamp(0.45, 1.0);

    final plateScale = (1.0 - absOffset * 1.0).clamp(0.15, 1.0);
    final plateOpacity = (1.0 - absOffset * 1.6).clamp(0.0, 1.0);
    final plateSize = centerDonutSize * 1.16;

    // One shared dish spinning flat under the whole carousel — bound
    // straight to scroll progress, never a per-item animation.
    final plateRotationAngle = pageOffset * _plateSpinPerPage;

    // Holds near-full opacity well past the halfway point, then drops
    // fast right at the end — matching the reference, where the FAB
    // stays fully visible through most of the transition and only
    // disappears once a donut is nearly at the neighbour position.
    final searchOpacity = (1 - (absOffset * absOffset) * 1.5).clamp(0.0, 1.0);
    final searchScale = ui.lerpDouble(0.6, 1.0, searchOpacity)!;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // LAYER 1 — plate (background spin). Rotation is applied only
          // inside _PlateLayer, directly on the plate Image.asset.
          if (plateOpacity > 0)
            _PlateLayer(
              image: AppImages.plate,
              size: plateSize,
              translateX: plateTranslateX,
              translateY: plateTranslateY,
              scale: plateScale,
              opacity: plateOpacity,
              rotationAngle: plateRotationAngle,
              dpr: dpr,
            ),

          // LAYER 2 — donut (foreground image). No Z-axis rotation here
          // at all — only translate + scale.
          _DonutLayer(
            image: flavor.image,
            size: centerDonutSize,
            translateY: donutTranslateY,
            scale: donutScale,
            opacity: donutOpacity,
            dpr: dpr,
          ),

          // LAYER 3 — search FAB, dead center, fading in as this item
          // approaches the middle of the viewport.
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

/// LAYER 1 — the plate. Spins continuously around its own center via
/// [rotationAngle]; the arc sag is a plain [Transform.translate] with no
/// rotation of its own, so the spin never reads as a 3D tilt.
class _PlateLayer extends StatelessWidget {
  const _PlateLayer({
    required this.image,
    required this.size,
    required this.translateX,
    required this.translateY,
    required this.scale,
    required this.opacity,
    required this.rotationAngle,
    required this.dpr,
  });

  final String image;
  final double size;
  final double translateX;
  final double translateY;
  final double scale;
  final double opacity;
  final double rotationAngle;
  final double dpr;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Transform.translate(
        offset: Offset(translateX, translateY),
        child: Transform.scale(
          scale: scale,
          child: Transform.rotate(
            angle: rotationAngle,
            child: Image.asset(
              image,
              width: size,
              height: size,
              cacheWidth: (size * dpr).round(),
              filterQuality: FilterQuality.medium,
            ),
          ),
        ),
      ),
    );
  }
}

/// LAYER 2 — the donut. Deliberately has no [Transform.rotate] anywhere in
/// its chain: it only ever translates (arc sag) and scales (depth
/// falloff), so it always renders upright regardless of scroll position.
class _DonutLayer extends StatelessWidget {
  const _DonutLayer({
    required this.image,
    required this.size,
    required this.translateY,
    required this.scale,
    required this.opacity,
    required this.dpr,
  });

  final String image;
  final double size;
  final double translateY;
  final double scale;
  final double opacity;
  final double dpr;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Transform.translate(
        offset: Offset(0, translateY),
        child: Transform.scale(
          scale: scale,
          child: Image.asset(
            image,
            width: size,
            height: size,
            cacheWidth: (size * dpr).round(),
            filterQuality: FilterQuality.medium,
          ),
        ),
      ),
    );
  }
}
