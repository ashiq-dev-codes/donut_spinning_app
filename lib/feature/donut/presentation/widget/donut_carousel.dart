import 'package:flutter/material.dart';
import 'package:donut_spinning_app/feature/donut/presentation/model/donut_flavor.dart';
import 'package:donut_spinning_app/feature/donut/presentation/widget/donut_carousel_item.dart';
import 'package:donut_spinning_app/shared/path/app_images.dart';

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
  SpringDescription get spring =>
      SpringDescription.withDampingRatio(mass: 0.5, stiffness: 100, ratio: 0.72);
}

/// The manually swiped donut carousel — purely user-driven, matching the
/// Figma prototype (no autoplay, and no wraparound: Strawberry Bliss is a
/// hard start, Pistachio Perfection is a hard end).
///
/// The ceramic plate is a single, statically centered background layer: it
/// lives once in this [Stack] and never animates. Above it, [PageView]
/// carries nothing but transparent donut PNGs — every donut's scale,
/// opacity and rotation is driven straight off the shared [controller]'s
/// live scroll position (see [DonutCarouselItem]), so only the donut that
/// currently sits at `page == index` ever lines up over the plate; every
/// other donut is just a preview floating past it.
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

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final plateSize = centerDonutSize * 1.16;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Static background layer — drawn once, centered, and never
        // touched again. Donuts slide over it; it never slides itself.
        IgnorePointer(
          child: Image.asset(
            AppImages.plate,
            width: plateSize,
            height: plateSize,
            cacheWidth: (plateSize * dpr).round(),
            filterQuality: FilterQuality.medium,
          ),
        ),
        PageView.builder(
          controller: controller,
          itemCount: flavors.length,
          physics: const _BouncyPagePhysics(),
          itemBuilder: (context, index) {
            final flavor = flavors[index];
            return AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                final pageOffset = controller.hasClients
                    ? (controller.page ?? controller.initialPage.toDouble())
                    : controller.initialPage.toDouble();
                return DonutCarouselItem(
                  flavor: flavor,
                  index: index,
                  pageOffset: pageOffset,
                  centerDonutSize: centerDonutSize,
                  onSearchTap: () => onSearchTap(flavor),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
