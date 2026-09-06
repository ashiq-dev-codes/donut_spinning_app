import 'package:flutter/material.dart';
import 'package:donut_spinning_app/feature/donut/presentation/model/donut_flavor.dart';
import 'package:donut_spinning_app/feature/donut/presentation/widget/donut_carousel_item.dart';

/// The manually swiped donut carousel — purely user-driven, matching the
/// Figma prototype (no autoplay, and no wraparound: Strawberry Bliss is a
/// hard start, Pistachio Perfection is a hard end).
///
/// Drives every card's scale/opacity/parallax and its plate's fly-in/out
/// straight off the shared [controller]'s live scroll position, so the
/// whole thing tracks the user's finger 1:1 during a drag.
class DonutCarousel extends StatelessWidget {
  const DonutCarousel({
    super.key,
    required this.controller,
    required this.flavors,
    required this.centerDonutSize,
    required this.plateTravelDistance,
    required this.onSearchTap,
  });

  final PageController controller;
  final List<DonutFlavor> flavors;
  final double centerDonutSize;
  final double plateTravelDistance;
  final ValueChanged<DonutFlavor> onSearchTap;

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: controller,
      itemCount: flavors.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final flavor = flavors[index];
        return AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final page = controller.hasClients
                ? (controller.page ?? controller.initialPage.toDouble())
                : controller.initialPage.toDouble();
            final delta = (index - page).clamp(-1.0, 1.0);
            return DonutCarouselItem(
              flavor: flavor,
              delta: delta,
              centerDonutSize: centerDonutSize,
              plateTravelDistance: plateTravelDistance,
              onSearchTap: () => onSearchTap(flavor),
            );
          },
        );
      },
    );
  }
}
