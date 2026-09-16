import 'package:flutter/material.dart';
import 'package:donut_spinning_app/shared/path/app_images.dart';

/// Static content + palette for a single donut flavor shown in the carousel.
///
/// [glow], [edge], and [accent] were sampled directly from the Figma source
/// file (background frame fill = [edge]; the frame's own "glow" shape fill
/// = [glow]; the flavor name/description text color = [accent]). Figma only
/// exposes those two ends of the wash as distinct swatches — there's no
/// separate third color for our gradient's middle stop — so [mid] is a
/// straight blend between [edge] and [glow] rather than a sampled value.
class DonutFlavor {
  const DonutFlavor({
    required this.name,
    required this.description,
    required this.image,
    required this.glow,
    required this.mid,
    required this.edge,
    required this.accent,
  });

  final String name;
  final String description;
  final String image;

  /// Radial gradient stops, brightest (near the logo) to darkest (edges).
  final Color glow;
  final Color mid;
  final Color edge;

  /// Brand accent used for the logo mark, wordmark and description text.
  final Color accent;

  static const List<DonutFlavor> all = [
    DonutFlavor(
      name: 'Strawberry Bliss',
      description:
          'Dive into a cloud of soft dough glazed with vibrant strawberry '
          'icing, crowned with real strawberry pieces — a blissful symphony '
          'of sweetness and freshness in every bite.',
      image: AppImages.donut1,
      glow: Color(0xFFA71B1B),
      mid: Color(0xFF591515),
      edge: Color(0xFF1F0500),
      accent: Color(0xFFFF8B8B),
    ),
    DonutFlavor(
      name: 'Banana Dream',
      description:
          'Golden perfection meets tropical delight as our Banana Dream '
          'donut is coated in a rich banana glaze, adorned with banana chips '
          'for a crispy finish, delivering a dreamy fusion of flavors.',
      image: AppImages.donut2,
      glow: Color(0xFFFF9C01),
      mid: Color(0xFFBF6500),
      edge: Color(0xFF7F2E00),
      accent: Color(0xFFFFED50),
    ),
    DonutFlavor(
      name: 'Blueberry Burst',
      description:
          'Soft and pillowy, the Blueberry Burst donut is a heavenly '
          'creation with its blueberry glaze and plump blueberries on top, '
          'ensuring a burst of fruity goodness in each indulgent mouthful.',
      image: AppImages.donut3,
      glow: Color(0xFFEA4E9F),
      mid: Color(0xFF9B3E88),
      edge: Color(0xFF4B2D71),
      accent: Color(0xFFF4B0FF),
    ),
    DonutFlavor(
      name: 'Choco Delight',
      description:
          'Indulge in our Chocolate Decadence donut, where a luscious glaze '
          'complements its moist interior for an irresistibly rich treat, '
          'perfect for chocolate enthusiasts.',
      image: AppImages.donut4,
      glow: Color(0xFFAC5723),
      mid: Color(0xFF683217),
      edge: Color(0xFF230D0A),
      accent: Color(0xFFFFCEA0),
    ),
    DonutFlavor(
      name: 'Pistachio Perfection',
      description:
          'Enjoy our Pistachio Perfection donut, featuring a harmonious '
          'blend of nutty sweetness in its glaze and crushed pistachio '
          'topping, ensuring an elegant and flavorful experience.',
      image: AppImages.donut5,
      glow: Color(0xFF9EA550),
      mid: Color(0xFF60622E),
      edge: Color(0xFF211F0B),
      accent: Color(0xFFFAFFBD),
    ),
  ];
}
