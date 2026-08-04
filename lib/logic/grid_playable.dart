import 'package:flutter/foundation.dart';

import '../models/grid_cell.dart';

/// Common surface [GridWidget] needs from a game controller, so the same
/// grid-rendering widget works for both Sayı Avı and Eşleştirme modu.
abstract class GridPlayable extends ChangeNotifier {
  List<GridCell> get cells;

  /// Number of columns the grid should render `cells` with (rows are
  /// derived as `(cells.length / columns).ceil()`). Lets [GridWidget]
  /// render grids of any size instead of assuming the fixed 4x6 layout.
  int get columns;

  void selectCell(int index);
}
