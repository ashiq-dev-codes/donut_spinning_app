import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:donut_spinning_app/feature/donut/presentation/model/donut_flavor.dart';
import 'package:donut_spinning_app/feature/donut/presentation/widget/animated_flavor_background.dart';
import 'package:donut_spinning_app/feature/donut/presentation/widget/dodonut_logo_header.dart';
import 'package:donut_spinning_app/feature/donut/presentation/widget/donut_carousel.dart';
import 'package:donut_spinning_app/feature/donut/presentation/widget/flavor_info.dart';

class DonutScreen extends StatefulWidget {
  const DonutScreen({super.key});

  @override
  State<DonutScreen> createState() => _DonutScreenState();
}

class _DonutScreenState extends State<DonutScreen> {
  static const _viewportFraction = 0.55;

  final _flavors = DonutFlavor.all;
  late final PageController _pageController = PageController(
    viewportFraction: _viewportFraction,
  );
  late final ValueNotifier<double> _pageNotifier = ValueNotifier(
    _pageController.initialPage.toDouble(),
  );

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_handlePageUpdate);
  }

  void _handlePageUpdate() {
    final page =
        _pageController.page ?? _pageController.initialPage.toDouble();
    _pageNotifier.value = page;

    // Clamped, not wrapped — Strawberry Bliss and Pistachio Perfection are
    // a hard start/end, so an elastic overscroll shouldn't wrap the title.
    final settledIndex = page.round().clamp(0, _flavors.length - 1);
    if (settledIndex != _currentIndex) {
      setState(() => _currentIndex = settledIndex);
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_handlePageUpdate);
    _pageController.dispose();
    _pageNotifier.dispose();
    super.dispose();
  }

  void _showFlavorDetail(DonutFlavor flavor) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _FlavorDetailSheet(flavor: flavor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: AnimatedFlavorBackground(
          page: _pageNotifier,
          flavors: _flavors,
          builder: (context, palette) {
            return SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final centerDonutSize = (constraints.maxWidth * 0.58)
                      .clamp(200.0, 300.0);
                  return Column(
                    children: [
                      // Explicit top clearance in addition to the outer
                      // SafeArea, so the header clears notches/Dynamic
                      // Islands even on devices that report a very small
                      // top inset.
                      SafeArea(
                        top: true,
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: DodonutLogoHeader(color: palette.accent),
                        ),
                      ),
                      Expanded(
                        child: DonutCarousel(
                          controller: _pageController,
                          flavors: _flavors,
                          centerDonutSize: centerDonutSize,
                          onSearchTap: _showFlavorDetail,
                        ),
                      ),
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 440),
                          child: FlavorInfo(
                            flavor: _flavors[_currentIndex],
                            activeIndex: _currentIndex,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FlavorDetailSheet extends StatelessWidget {
  const _FlavorDetailSheet({required this.flavor});

  final DonutFlavor flavor;

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          decoration: BoxDecoration(
            color: flavor.mid,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: flavor.accent.withValues(alpha: 0.25),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Image.asset(
                flavor.image,
                width: 160,
                height: 160,
                cacheWidth: (160 * dpr).round(),
                filterQuality: FilterQuality.medium,
              ),
              const SizedBox(height: 16),
              Text(
                flavor.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                flavor.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: flavor.accent.withValues(alpha: 0.85),
                  fontSize: 14.5,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
