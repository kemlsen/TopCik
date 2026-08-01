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
    final isUrgent = widget.remainingSeconds <= 10 && widget.remainingSeconds > 0;
    final progress = widget.totalSeconds == 0
        ? 0.0
        : (widget.remainingSeconds / widget.totalSeconds).clamp(0.0, 1.0);
    final color = isUrgent ? AppColors.error : AppColors.primary;

    final content = SizedBox(
      width: 74,
      height: 74,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 7,
            backgroundColor: Colors.white54,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          Text(
            '${widget.remainingSeconds}',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isUrgent ? color : Colors.black87,
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
