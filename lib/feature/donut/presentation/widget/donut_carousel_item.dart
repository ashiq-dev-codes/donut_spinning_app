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
/// to tilt. The only rotation in this widget is the donut's own spin,
/// applied to nothing but its `Image.asset`; the plate never rotates.
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

  /// Radians of donut spin per page of offset — half a turn, a simple,
  /// clearly-visible amount well short of a dizzying full rotation. Tied
  /// to this item's own signed `dx` rather than the raw [pageOffset]: that
  /// keeps every settled, dead-center donut sitting at exactly zero
  /// rotation regardless of how many pages have been scrolled overall,
  /// matching the reference where a settled donut always sits upright.
  static const _donutSpinPerPage = math.pi;

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

    final plateSize = centerDonutSize * 1.16;

    // The donut spins flat around its own center as it's dragged, bound to
    // this item's own signed dx so it always lands back at exactly zero
    // once settled dead-center, rather than drifting to some off-kilter
    // angle depending on how far the carousel has been scrolled overall.
    final donutRotationAngle = dx * _donutSpinPerPage;

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
          // LAYER 1 — plate. Never rotates — a fixed-size, fixed-orientation
          // object that simply travels into and out of frame, so it "comes
          // and goes" purely by traveling far enough off-position to leave
          // the screen — not by easing its opacity, size, or angle (the
          // PageView itself doesn't clip it; see the class doc above on
          // `Clip.none`).
          _PlateLayer(
            image: AppImages.plate,
            size: plateSize,
            translateX: plateTranslateX,
            translateY: plateTranslateY,
            dpr: dpr,
          ),

          // LAYER 2 — donut (foreground image). Rotation is applied only
          // here, directly on the donut Image.asset.
          _DonutLayer(
            image: flavor.image,
            size: centerDonutSize,
            translateY: donutTranslateY,
            scale: donutScale,
            opacity: donutOpacity,
            rotationAngle: donutRotationAngle,
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

/// LAYER 1 — the plate. Deliberately has no [Transform.rotate] anywhere in
/// its chain: it only ever translates (in and out of frame), so it always
/// renders at the same fixed orientation regardless of scroll position.
class _PlateLayer extends StatelessWidget {
  const _PlateLayer({
    required this.image,
    required this.size,
    required this.translateX,
    required this.translateY,
    required this.dpr,
  });

  final String image;
  final double size;
  final double translateX;
  final double translateY;
  final double dpr;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(translateX, translateY),
      child: Image.asset(
        image,
        width: size,
        height: size,
        cacheWidth: (size * dpr).round(),
        filterQuality: FilterQuality.medium,
      ),
    );
  }
}

/// LAYER 2 — the donut. Spins continuously around its own center via
/// [rotationAngle]; the arc sag is a plain [Transform.translate] with no
/// rotation of its own, so the spin never reads as a 3D tilt — this is a
/// flat, top-down turn, layered independently on top of the translate and
/// scale.
class _DonutLayer extends StatelessWidget {
  const _DonutLayer({
    required this.image,
    required this.size,
    required this.translateY,
    required this.scale,
    required this.opacity,
    required this.rotationAngle,
    required this.dpr,
  });

  final String image;
  final double size;
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
        offset: Offset(0, translateY),
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
