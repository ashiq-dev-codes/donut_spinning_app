import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:donut_spinning_app/shared/path/app_svg.dart';

/// The small pinwheel "dodonut" brand mark.
///
/// Pure algebra on the live [page] value, same as every other rotation in
/// this app (the donut, the plate): no clock, no [AnimationController] — the
/// spin tracks the scroll 1:1 and freezes the instant the drag stops, rather
/// than spinning on its own timer regardless of whether the user is
/// scrolling.
class SwirlLogo extends StatelessWidget {
  const SwirlLogo({
    super.key,
    required this.color,
    required this.page,
    this.size = 34,
  });

  final Color color;
  final ValueListenable<double> page;
  final double size;

  /// Radians of spin per page of scroll — a quarter turn. Slower than the
  /// donut's own half-turn rate ([DonutCarouselItem._donutSpinPerPage]):
  /// this mark is much smaller on screen, so the same angular speed reads
  /// as noticeably faster than it does on the donut. The mark's 8-fold
  /// rotational symmetry means any settled page reads as upright
  /// regardless of the exact multiple used here.
  static const _spinPerPage = math.pi / 2;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: page,
      builder: (context, value, child) {
        return Transform.rotate(angle: value * _spinPerPage, child: child);
      },
      child: SvgPicture.asset(
        AppSvgs.logo,
        width: size,
        height: size,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      ),
    );
  }
}
