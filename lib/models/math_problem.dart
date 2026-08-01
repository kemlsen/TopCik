class MathProblem {
  final String expression;
  final int answer;

  const MathProblem({required this.expression, required this.answer});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MathProblem &&
          expression == other.expression &&
          answer == other.answer);

  @override
  int get hashCode => Object.hash(expression, answer);

  @override
  String toString() => '$expression = $answer';
}
