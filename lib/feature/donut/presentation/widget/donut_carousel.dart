import 'dart:math' as math;

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
/// The ceramic plate isn't a single element sliding up and down — that
/// reads as a bounce, not a wheel. The Figma reference actually shows two
/// plates on opposite sides of one big vertical wheel (see
/// [_OrbitingPlate]): at rest they sit perfectly stacked, front one fully
/// visible and centered, back one directly behind it and invisible. As you
/// swipe, the wheel turns half a revolution per page: the front plate
/// rises up and away while, at the very same moment, the back plate rises
/// up from below on the *other* side — one going up as the other comes up
/// from under, which is what makes it read as circular rather than a
/// single object bouncing. A full page later the back plate has become
/// the new front (dead center again), and the cycle repeats with the
/// plates' roles swapped. Side items in the [PageView] carry no plate of
/// their own at all (see [DonutCarouselItem]): off-center they're bare
/// donuts riding their own, much shallower arc.
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

  double _currentPage() {
    return controller.hasClients
        ? (controller.page ?? controller.initialPage.toDouble())
        : controller.initialPage.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final plateSize = centerDonutSize * 1.16;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Two plates riding opposite sides of one big wheel — see
        // [_OrbitingPlate] for why it takes two, not one.
        IgnorePointer(
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              // Half a revolution (pi) per page: at every settled page
              // this is an even/odd multiple of pi, which is exactly when
              // one plate sits at phase 0 (front, dead center) and the
              // other at phase pi (back, hidden) — see _OrbitingPlate.
              final wheelAngle = math.pi * _currentPage();
              final orbitRadius = plateSize * 0.85;

              // Paint back-to-front: whichever plate is nearer (larger
              // cos(theta)) must be drawn last so it occludes the far one,
              // exactly like it sitting stacked in front at rest.
              final thetas = <double>[wheelAngle, wheelAngle + math.pi]
                ..sort((a, b) => math.cos(a).compareTo(math.cos(b)));

              return Stack(
                alignment: Alignment.center,
                children: [
                  for (final theta in thetas)
                    _OrbitingPlate(
                      theta: theta,
                      orbitRadius: orbitRadius,
                      plateSize: plateSize,
                      dpr: dpr,
                    ),
                ],
              );
            },
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
                return DonutCarouselItem(
                  flavor: flavor,
                  index: index,
                  pageOffset: _currentPage(),
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

/// One plate riding a fixed point on the big vertical wheel described on
/// [DonutCarousel]: [theta] is that wheel's current angle plus this
/// plate's own phase offset (0 or pi — see [DonutCarousel.build]), so two
/// instances of this widget, 180 degrees out of phase, are what reproduce
/// "one plate rises as the other rises from under it on the far side"
/// rather than a single plate visibly bouncing in place.
///
/// Everything here is a function of the same [theta]: [depth] (`cos`) is
/// where the plate sits front-to-back on the wheel — 1 dead-center facing
/// the viewer, -1 directly behind the front plate and invisible — and
/// drives both size and opacity; the vertical position (`sin`) is what
/// actually swings it up out of view and back in from below; and the
/// `rotateX` tilt, driven by that exact same angle, is what makes it look
/// like a rigid disc turning on an axle rather than a flat cutout gliding
/// up and down.
class _OrbitingPlate extends StatelessWidget {
  const _OrbitingPlate({
    required this.theta,
    required this.orbitRadius,
    required this.plateSize,
    required this.dpr,
  });

  final double theta;
  final double orbitRadius;
  final double plateSize;
  final double dpr;

  static const _minScale = 0.35;

  @override
  Widget build(BuildContext context) {
    final depth = math.cos(theta);
    final depthUnit = ((depth + 1) / 2).clamp(0.0, 1.0);

    final translateY = -orbitRadius * math.sin(theta);
    final scale = _minScale + (1 - _minScale) * depthUnit;

    return Opacity(
      opacity: depthUnit,
      child: Transform.translate(
        offset: Offset(0, translateY),
        child: Transform.scale(
          scale: scale,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0025)
              ..rotateX(theta),
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
    );
  }
}
