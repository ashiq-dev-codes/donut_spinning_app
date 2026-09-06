import 'package:flutter/material.dart';
import 'package:donut_spinning_app/feature/donut/presentation/widget/swirl_logo.dart';

/// The spinning pinwheel mark + "dodonut" wordmark, tinted to the current
/// flavor's accent color.
class DodonutLogoHeader extends StatelessWidget {
  const DodonutLogoHeader({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwirlLogo(color: color, size: 34),
        const SizedBox(height: 8),
        Text(
          'dodonut',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 17,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
