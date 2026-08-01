import 'package:flutter/material.dart';

import '../logic/game_constants.dart';
import '../logic/grid_playable.dart';
import 'grid_cell_widget.dart';

/// Renders the 4x4 problem grid driven by [controller]. Works for both
/// Sayı Avı and Eşleştirme modu since both controllers implement
/// [GridPlayable].
class GridWidget extends StatelessWidget {
  final GridPlayable controller;

  const GridWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: gridSize,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
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
  }
}
