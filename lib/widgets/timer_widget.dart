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

    final content = Container(
      width: 74,
      height: 74,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: badgeColor,
        boxShadow: [
          BoxShadow(
            color: badgeColor.withValues(alpha: 0.6),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(6),
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 6,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          Text(
            '${widget.remainingSeconds}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
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
