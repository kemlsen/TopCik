import 'package:flutter/foundation.dart';

import '../models/grid_cell.dart';

/// Common surface [GridWidget] needs from a game controller, so the same
/// grid-rendering widget works for both Sayı Avı and Eşleştirme modu.
abstract class GridPlayable extends ChangeNotifier {
  List<GridCell> get cells;

  void selectCell(int index);
}
