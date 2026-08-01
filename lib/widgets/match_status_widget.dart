import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Eşleştirme modu için hedef sayı kutusunun karşılığı: kalan çift
/// sayısını gösteren büyük, dikkat çekici bir rozet.
class MatchStatusWidget extends StatelessWidget {
  final int matchedPairs;
  final int totalPairs;

  const MatchStatusWidget({
    super.key,
    required this.matchedPairs,
    required this.totalPairs,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = totalPairs - matchedPairs;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, animation) =>
          ScaleTransition(scale: animation, child: child),
      child: Container(
        key: ValueKey(remaining),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.levelExpert,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🧩 Eşleştir',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white70,
              ),
            ),
            Text(
              'Kalan çift: $remaining',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
