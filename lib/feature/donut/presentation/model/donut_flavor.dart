import 'package:flutter/material.dart';
import 'package:donut_spinning_app/shared/path/app_images.dart';

/// Static content + palette for a single donut flavor shown in the carousel.
///
/// Colors were sampled directly from the Figma prototype recording so the
/// glow/vignette and accent hues match each flavor's donut.
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
      glow: Color(0xFF6B1512),
      mid: Color(0xFF2A0A08),
      edge: Color(0xFF0D0403),
      accent: Color(0xFFFF7A7D),
    ),
    DonutFlavor(
      name: 'Banana Dream',
      description:
          'Golden perfection meets tropical delight as our Banana Dream '
          'donut is coated in a rich banana glaze, adorned with banana chips '
          'for a crispy finish, delivering a dreamy fusion of flavors.',
      image: AppImages.donut2,
      glow: Color(0xFFB35701),
      mid: Color(0xFF7D2F00),
      edge: Color(0xFF1C0D00),
      accent: Color(0xFFFFE14D),
    ),
    DonutFlavor(
      name: 'Blueberry Burst',
      description:
          'Soft and pillowy, the Blueberry Burst donut is a heavenly '
          'creation with its blueberry glaze and plump blueberries on top, '
          'ensuring a burst of fruity goodness in each indulgent mouthful.',
      image: AppImages.donut3,
      glow: Color(0xFF8C337A),
      mid: Color(0xFF4E2A69),
      edge: Color(0xFF1A0F24),
      accent: Color(0xFFEEA8FF),
    ),
    DonutFlavor(
      name: 'Choco Delight',
      description:
          'Indulge in our Chocolate Decadence donut, where a luscious glaze '
          'complements its moist interior for an irresistibly rich treat, '
          'perfect for chocolate enthusiasts.',
      image: AppImages.donut4,
      glow: Color(0xFF5A2A15),
      mid: Color(0xFF28120B),
      edge: Color(0xFF0F0805),
      accent: Color(0xFFFDC795),
    ),
    DonutFlavor(
      name: 'Pistachio Perfection',
      description:
          'Enjoy our Pistachio Perfection donut, featuring a harmonious '
          'blend of nutty sweetness in its glaze and crushed pistachio '
          'topping, ensuring an elegant and flavorful experience.',
      image: AppImages.donut5,
      glow: Color(0xFF535527),
      mid: Color(0xFF262511),
      edge: Color(0xFF0D0C05),
      accent: Color(0xFFF9FDB6),
    ),
  ];
}
