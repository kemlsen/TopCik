import 'package:flutter/material.dart';

import '../logic/game_constants.dart';
import '../theme/app_colors.dart';

/// Bölüm 6 — Can sistemi: kalan deneme hakkını kalp ikonlarıyla gösterir.
/// Hem Sayı Avı hem Eşleştirme modu tarafından kullanılır.
class LivesBadge extends StatelessWidget {
  final int livesRemaining;

  const LivesBadge({super.key, required this.livesRemaining});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(maxLives, (i) {
        final filled = i < livesRemaining;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Icon(
            filled ? Icons.favorite : Icons.favorite_border,
            color: AppColors.error,
            size: 26,
          ),
        );
      }),
    );
  }
}
