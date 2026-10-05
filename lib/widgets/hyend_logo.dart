import 'package:flutter/material.dart';
import 'package:hyend/theme/app_theme.dart';

/// HyEnd logo, loaded from assets/images/HyEnd.png.
/// Falls back to a built-in gold "H" mark if the asset can't be loaded.
class HyEndLogo extends StatelessWidget {
  final double size;
  const HyEndLogo({super.key, this.size = 96});

  static const String assetPath = 'assets/images/HyEnd.png';

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(size * 0.22);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withOpacity(0.28),
            blurRadius: size * 0.3,
            offset: Offset(0, size * 0.12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Image.asset(
          assetPath,
          width: size,
          height: size,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          errorBuilder: (_, __, ___) => _fallback(),
        ),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.goldSoft, AppColors.gold, Color(0xFF9C7A12)],
        ),
      ),
      child: Text(
        'H',
        style: TextStyle(
          fontSize: size * 0.55,
          fontWeight: FontWeight.w800,
          color: AppColors.navy,
          height: 1,
        ),
      ),
    );
  }
}
