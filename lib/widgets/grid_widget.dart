import 'package:flutter/material.dart';

import '../logic/game_constants.dart';
import '../logic/grid_playable.dart';
import 'grid_cell_widget.dart';

/// Renders the problem grid ([gridColumns] sütun x several satır) driven by
/// [controller]. Works for both Sayı Avı and Eşleştirme modu since both
/// controllers implement [GridPlayable].
///
/// Cell aspect ratio is computed from the available space (via
/// [LayoutBuilder]) instead of a fixed 1:1 ratio, so the grid always fills
/// its container exactly — no empty strip below the last row, no overflow.
class GridWidget extends StatelessWidget {
  final GridPlayable controller;

  const GridWidget({super.key, required this.controller});

  static const _padding = EdgeInsets.all(12);
  static const _spacing = 10.0;

  @override
  Widget build(BuildContext context) {
    final rows = (gridSize / gridColumns).ceil();

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth =
            constraints.maxWidth - _padding.horizontal - _spacing * (gridColumns - 1);
        final availableHeight =
            constraints.maxHeight - _padding.vertical - _spacing * (rows - 1);
        final cellWidth = availableWidth / gridColumns;
        final cellHeight = availableHeight / rows;
        final aspectRatio = cellWidth / cellHeight;

        return GridView.builder(
          padding: _padding,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: gridSize,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridColumns,
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
        );
      },
    );
  }
}
