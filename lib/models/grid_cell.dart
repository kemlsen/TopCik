import 'math_problem.dart';

/// [selected] is only used by Eşleştirme modu: the first tile a player
/// taps while looking for its match.
enum CellState { idle, selected, correct, wrong, empty }

class GridCell {
  final MathProblem problem;
  CellState state;

  GridCell({required this.problem, this.state = CellState.idle});
}
