import 'package:flutter/material.dart';

import '../logic/grid_playable.dart';
import 'grid_cell_widget.dart';

/// Renders the problem grid (`controller.columns` sütun x several satır)
/// driven by [controller]. Works for any [GridPlayable] — Sayı Avı ve
/// Eşleştirme modu sabit 4x6 kullanır, Tırmanış modu ise bölüme göre
/// büyüyen 1x2..4x4 grid'ler döner.
///
/// Cell aspect ratio is computed from the available space (via
/// [LayoutBuilder]) instead of a fixed 1:1 ratio, so the grid always fills
/// its container exactly — no empty strip below the last row, no overflow.
/// The ratio is clamped to [_minAspectRatio]/[_maxAspectRatio] so low-row
/// grids (e.g. Tırmanış'ın 1x2 turları) don't stretch into absurdly tall
/// cells; when clamping shortens the grid, it's centered instead of
/// top-aligned (bkz. CLAUDE.md Bölüm 3b).
class GridWidget extends StatelessWidget {
  final GridPlayable controller;

  const GridWidget({super.key, required this.controller});

  static const _padding = EdgeInsets.all(12);
  static const _spacing = 10.0;
  static const _minAspectRatio = 0.5;
  static const _maxAspectRatio = 1.8;

  @override
  Widget build(BuildContext context) {
    final itemCount = controller.cells.length;
    final columns = controller.columns;
    final rows = (itemCount / columns).ceil();

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth =
            constraints.maxWidth - _padding.horizontal - _spacing * (columns - 1);
        final availableHeight =
            constraints.maxHeight - _padding.vertical - _spacing * (rows - 1);
        final cellWidth = availableWidth / columns;
        final cellHeight = availableHeight / rows;
        final aspectRatio = (cellWidth / cellHeight)
            .clamp(_minAspectRatio, _maxAspectRatio)
            .toDouble();

        return Center(
          child: GridView.builder(
            padding: _padding,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: itemCount,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: _spacing,
              crossAxisSpacing: _spacing,
              childAspectRatio: aspectRatio,
            ),
            itemBuilder: (context, index) {
              final cell = controller.cells[index];
              return GridCellWidget(
                key: ValueKey(cell.problem.expression),
                cell: cell,
                onTap: () => controller.selectCell(index),
              );
            },
          ),
        );
      },
    );
  }
}
