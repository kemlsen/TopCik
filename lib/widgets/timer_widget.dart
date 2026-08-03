import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Circular countdown timer. Turns red and blinks in the last 10 seconds
/// (Bölüm 7), without any harsh/scary effect.
class TimerWidget extends StatefulWidget {
  final int remainingSeconds;
  final int totalSeconds;

  const TimerWidget({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
  });

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _blinkController;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUrgent =
        widget.remainingSeconds <= 10 && widget.remainingSeconds > 0;
    final progress = widget.totalSeconds == 0
        ? 0.0
        : (widget.remainingSeconds / widget.totalSeconds).clamp(0.0, 1.0);
    final badgeColor = isUrgent ? AppColors.error : AppColors.cta;

    // Dolgulu yeşil/kırmızı rozet kaldırıldı: azalan daire artık tek başına
    // aciliyet rengini taşıyor (yeşil → kırmızı), rakamlar halkanın boş,
    // şeffaf merkezinde duruyor.
    final content = SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // CircularProgressIndicator boyutu verilmezse Flutter'ın 36px'lik
          // varsayılanına küçülüyor — SizedBox ile halkanın tüm alanı
          // kaplamasını sağlıyoruz.
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 6,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(badgeColor),
            ),
          ),
          // Sabit boyutlu kutu: metin hiçbir zaman halka çizgisine kadar
          // büyümüyor, "1:30" gibi uzun süreler de rahatça sığıyor.
          SizedBox(
            width: 48,
            height: 30,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '${widget.remainingSeconds}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (!isUrgent) return content;

    return AnimatedBuilder(
      animation: _blinkController,
      builder: (context, child) {
        return Opacity(
          opacity: 0.45 + 0.55 * _blinkController.value,
          child: child,
        );
      },
      child: content,
    );
  }
}
