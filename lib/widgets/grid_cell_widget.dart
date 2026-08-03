import 'dart:math';

import 'package:flutter/material.dart';

import '../models/grid_cell.dart';
import '../models/math_problem.dart';
import '../theme/app_colors.dart';

/// A single grid tile showing one math problem, with the correct/wrong
/// feedback animations described in Bölüm 8.
class GridCellWidget extends StatefulWidget {
  final GridCell cell;
  final VoidCallback onTap;

  const GridCellWidget({super.key, required this.cell, required this.onTap});

  @override
  State<GridCellWidget> createState() => _GridCellWidgetState();
}

class _GridCellWidgetState extends State<GridCellWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    if (widget.cell.state == CellState.wrong) {
      _shakeController.forward(from: 0);
    }
  }

  @override
  void didUpdateWidget(covariant GridCellWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cell.state == CellState.wrong &&
        oldWidget.cell.state != CellState.wrong) {
      _shakeController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  Color _idleColorFor(MathProblem problem) {
    final index =
        problem.expression.hashCode.abs() % AppColors.tilePalette.length;
    return AppColors.tilePalette[index];
  }

  @override
  Widget build(BuildContext context) {
    final cell = widget.cell;

    if (cell.state == CellState.empty) {
      return const SizedBox.shrink();
    }

    final isCorrect = cell.state == CellState.correct;
    final isWrong = cell.state == CellState.wrong;
    final isSelected = cell.state == CellState.selected;

    final backgroundColor = isCorrect
        ? AppColors.success
        : isWrong
            ? AppColors.error
            : isSelected
                ? AppColors.primary
                : _idleColorFor(cell.problem);

    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        final shakeOffset =
            isWrong ? sin(_shakeController.value * pi * 6) * 6 : 0.0;
        return Transform.translate(
          offset: Offset(shakeOffset, 0),
          child: child,
        );
      },
      child: GestureDetector(
        onTap: cell.state == CellState.idle || isSelected
            ? widget.onTap
            : null,
        child: AnimatedScale(
          scale: isCorrect
              ? 0.0
              : isSelected
                  ? 1.05
                  : 1.0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeIn,
          child: AnimatedOpacity(
            opacity: isCorrect ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 400),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(18),
                // İnce, yarı şeffaf beyaz kenarlık: hücrenin rengi mor
                // gradient arka planla yakın tonda olsa bile hücreyi
                // arka plandan ayırt edilir kılar (bkz. AppColors.tilePalette).
                border: isSelected
                    ? Border.all(color: Colors.white, width: 4)
                    : Border.all(
                        color: Colors.white.withValues(alpha: 0.32),
                        width: 1.5,
                      ),
                boxShadow: isCorrect
                    ? [
                        BoxShadow(
                          color: AppColors.successGlow.withValues(alpha: 0.9),
                          blurRadius: 22,
                          spreadRadius: 3,
                        ),
                      ]
                    : isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.7),
                              blurRadius: 18,
                              spreadRadius: 2,
                            ),
                          ]
                        : const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
              ),
              alignment: Alignment.center,
              padding: const EdgeInsets.all(4),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  cell.problem.expression,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
