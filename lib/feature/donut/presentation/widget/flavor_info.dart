import 'package:flutter/material.dart';
import 'package:donut_spinning_app/feature/donut/presentation/model/donut_flavor.dart';

/// Flavor name + description, crossfading whenever the carousel settles on
/// a new page.
///
/// Title and description live inside a single [AnimatedSwitcher] as one
/// [Column] child, keyed on [activeIndex] — not two independent switchers —
/// so the whole outgoing block is torn down and the whole incoming block
/// fades in as one atomic unit. That, plus the short 250ms duration, is
/// what keeps an outgoing title from ever lingering behind an incoming
/// description (or vice versa) — the exact overlap seen when the two
/// pieces of text animated on separate, independently-timed switchers.
class FlavorInfo extends StatelessWidget {
  const FlavorInfo({
    super.key,
    required this.flavor,
    required this.activeIndex,
  });

  final DonutFlavor flavor;

  /// The settled carousel index this flavor belongs to. Keying the
  /// [AnimatedSwitcher]'s child on this (rather than on the flavor's own
  /// text) is what guarantees the outgoing title+description is fully
  /// disposed of before the incoming pair takes over.
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: ClipRect(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
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
          // Only the active title/description block ever occupies space —
          // the outgoing block paints behind it, at fading opacity, until
          // the switcher disposes of it at the end of the transition.
          layoutBuilder: (currentChild, previousChildren) => Stack(
            alignment: Alignment.center,
            children: [
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          ),
          child: Column(
            key: ValueKey<int>(activeIndex),
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                flavor.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                  height: 1.15,
                  letterSpacing: 0.1,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                flavor.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: flavor.accent.withValues(alpha: 0.75),
                  fontWeight: FontWeight.w400,
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
