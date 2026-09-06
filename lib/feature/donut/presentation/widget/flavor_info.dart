import 'package:flutter/material.dart';
import 'package:donut_spinning_app/feature/donut/presentation/model/donut_flavor.dart';

/// Flavor name + description, crossfading and drifting upward whenever the
/// carousel settles on a new page — an approximation, in clean Flutter
/// terms, of the two-text overlap seen in the Figma recording.
class FlavorInfo extends StatelessWidget {
  const FlavorInfo({
    super.key,
    required this.flavor,
    required this.activeIndex,
  });

  final DonutFlavor flavor;

  /// The settled carousel index this flavor belongs to. Keying each
  /// [AnimatedSwitcher]'s child on this (rather than on the flavor's own
  /// text) is what guarantees the outgoing title/description is fully
  /// disposed of before the incoming one takes over — no two active
  /// widgets ever coexist mid-crossfade.
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRect(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 420),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                final slide = Tween<Offset>(
                  begin: const Offset(0, 0.35),
                  end: Offset.zero,
                ).animate(animation);
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(position: slide, child: child),
                );
              },
              child: Text(
                flavor.name,
                key: ValueKey(activeIndex),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                  height: 1.15,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          ClipRect(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 420),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                final slide = Tween<Offset>(
                  begin: const Offset(0, 0.35),
                  end: Offset.zero,
                ).animate(animation);
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(position: slide, child: child),
                );
              },
              child: Text(
                flavor.description,
                key: ValueKey(activeIndex),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: flavor.accent.withValues(alpha: 0.75),
                  fontWeight: FontWeight.w400,
                  fontSize: 14.5,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
