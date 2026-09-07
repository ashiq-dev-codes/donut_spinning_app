import 'package:donut_spinning_app/feature/donut/presentation/model/donut_flavor.dart';
import 'package:donut_spinning_app/feature/donut/presentation/widget/donut_carousel_item.dart';
import 'package:flutter/material.dart';

/// The scroll physics [PageView] hands its page-to-page snap simulation.
///
/// A page's target-reaching spring is normally critically/over-damped
/// (ratio 1.1 — no overshoot). Dropping the damping ratio below 1 makes it
/// underdamped, so once you release a swipe the settle overshoots the
/// target page slightly and springs back — the little rotational "bounce"
/// seen on every donut settle in the Figma prototype, since the donut's
/// rotation is itself driven by this same page position.
class _BouncyPagePhysics extends BouncingScrollPhysics {
  const _BouncyPagePhysics({super.parent});

  @override
  _BouncyPagePhysics applyTo(ScrollPhysics? ancestor) {
    return _BouncyPagePhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => SpringDescription.withDampingRatio(
    mass: 0.5,
    stiffness: 100,
    ratio: 0.72,
  );
}

/// The manually swiped donut carousel — purely user-driven (no autoplay,
/// no wraparound).
///
/// [DonutCarouselItem] renders its plate and its donut as two fully
/// isolated visual layers (see that widget for details). This widget's
/// only job is to keep both layers fed with a live, per-pixel `pageOffset`:
/// the [PageView.builder] is rebuilt from a [ListenableBuilder] on
/// [controller] itself, rather than each item listening independently, so
/// every layer of every visible item recomputes off the exact same scroll
/// value on the exact same frame.
///
/// The page view's own clipping is disabled ([Clip.none]) so a
/// slightly-scaled-up center item, or a plate riding above its own item's
/// bounds, is never hard-cropped at the page boundary.
class DonutCarousel extends StatelessWidget {
  const DonutCarousel({
    super.key,
    required this.controller,
    required this.flavors,
    required this.centerDonutSize,
    required this.onSearchTap,
  });

  final PageController controller;
  final List<DonutFlavor> flavors;
  final double centerDonutSize;
  final ValueChanged<DonutFlavor> onSearchTap;

  double _pageOffsetOf(PageController controller) {
    if (!controller.hasClients || !controller.position.haveDimensions) {
      return controller.initialPage.toDouble();
    }
    return controller.page ?? controller.initialPage.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Pixel width of a single page — the unit the arc math in
        // DonutCarouselItem needs to turn a page-fraction offset into a
        // real horizontal distance from the screen's center.
        final itemExtent = constraints.maxWidth * controller.viewportFraction;

        return ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            final pageOffset = _pageOffsetOf(controller);

            return PageView.builder(
              controller: controller,
              itemCount: flavors.length,
              physics: const _BouncyPagePhysics(),
              clipBehavior: Clip.none,
              itemBuilder: (context, index) {
                final flavor = flavors[index];
                return DonutCarouselItem(
                  flavor: flavor,
                  index: index,
                  pageOffset: pageOffset,
                  centerDonutSize: centerDonutSize,
                  itemExtent: itemExtent,
                  onSearchTap: () => onSearchTap(flavor),
                );
              },
            );
          },
        );
      },
    );
  }
}
