import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// TopCik'in marka amblemi: oyunun kendi 4'lü grid + "sayı avı" fikrini
/// yansıtan, birbirinin üstüne hafifçe yaslanmış renkli sayı/işlem
/// kartlarından oluşan bir küme, üzerine yerleşen bir büyüteç rozetiyle
/// "doğru cevabı bulma" anını temsil eder. Statik bir marka işareti.
class MathLogoEmblem extends StatelessWidget {
  const MathLogoEmblem({super.key, this.size = 140});

  final double size;

  @override
  Widget build(BuildContext context) {
    final s = size;
    final tileSize = s * 0.42;

    return SizedBox(
      width: s,
      height: s,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: const Alignment(-0.62, -0.6),
            child: Transform.rotate(
              angle: -0.28,
              child: _Tile(
                size: tileSize,
                color: AppColors.levelMedium,
                label: '+',
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0.6, -0.4),
            child: Transform.rotate(
              angle: 0.22,
              child: _Tile(
                size: tileSize,
                color: AppColors.levelExpert,
                label: '×',
              ),
            ),
          ),
          Align(
            alignment: const Alignment(-0.55, 0.62),
            child: Transform.rotate(
              angle: -0.12,
              child: _Tile(
                size: tileSize,
                color: AppColors.levelHard,
                label: '7',
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0.55, 0.55),
            child: Transform.rotate(
              angle: 0.1,
              child: _Tile(
                size: tileSize * 1.08,
                color: AppColors.success,
                label: '12',
                glow: true,
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0.98, 0.9),
            child: _MagnifierBadge(size: s * 0.34),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.size,
    required this.color,
    required this.label,
    this.glow = false,
  });

  final double size;
  final Color color;
  final String label;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, Color.lerp(color, Colors.black, 0.18)!],
        ),
        borderRadius: BorderRadius.circular(size * 0.24),
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: [
          if (glow)
            BoxShadow(
              color: AppColors.successGlow.withValues(alpha: 0.7),
              blurRadius: 14,
              spreadRadius: 1,
            ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: size * 0.42,
          shadows: const [Shadow(color: Colors.black26, blurRadius: 3)],
        ),
      ),
    );
  }
}

class _MagnifierBadge extends StatelessWidget {
  const _MagnifierBadge({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final glassSize = size * 0.66;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Sap
          Positioned(
            right: size * 0.02,
            bottom: size * 0.02,
            child: Transform.rotate(
              angle: 0.78,
              child: Container(
                width: size * 0.16,
                height: size * 0.42,
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(size * 0.08),
                ),
              ),
            ),
          ),
          // Mercek
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: glassSize,
              height: glassSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.gold, Color(0xFFE8951C)],
                ),
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                '?',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: glassSize * 0.55,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
