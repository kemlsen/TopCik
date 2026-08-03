import 'dart:math';

import '../models/difficulty_level.dart';
import '../models/math_problem.dart';

/// Generates random math problems for a grid, respecting the rules from
/// Bölüm 5: no negative results, integer-only division, and no duplicate
/// expressions within the same grid.
class ProblemGenerator {
  final Random _random;

  ProblemGenerator({Random? random}) : _random = random ?? Random();

  /// Generates [count] problems with unique expressions for [level], using
  /// only the operation types in [operations] (Kullanıcının seçtiği işlem
  /// türleri — bkz. işlem türü seçim ekranı).
  /// Duplicate *answers* are allowed and expected (Bölüm 4 edge case).
  List<MathProblem> generateGrid(
    DifficultyLevel level, {
    required Set<Operation> operations,
    int count = 24,
  }) {
    final problems = <MathProblem>[];
    final seenExpressions = <String>{};
    var attempts = 0;
    final maxAttempts = count * 300;
    final operationList = operations.toList();

    while (problems.length < count && attempts < maxAttempts) {
      attempts++;
      final problem = _generateOne(level, operationList);
      if (seenExpressions.contains(problem.expression)) continue;
      seenExpressions.add(problem.expression);
      problems.add(problem);
    }

    return problems;
  }

  /// Generates a single replacement problem, avoiding any expression
  /// already present in [existingExpressions].
  MathProblem generateOne(
    DifficultyLevel level, {
    required Set<Operation> operations,
    Set<String> existingExpressions = const {},
  }) {
    final operationList = operations.toList();
    var attempts = 0;
    while (attempts < 300) {
      attempts++;
      final problem = _generateOne(level, operationList);
      if (!existingExpressions.contains(problem.expression)) {
        return problem;
      }
    }
    // Fallback: extremely unlikely, but guarantees termination.
    return _generateOne(level, operationList);
  }

  /// Generates a grid for Eşleştirme modu: [pairCount] pairs (24 cells for
  /// the default grid) where each pair is two *different* expressions
  /// sharing the same answer, so players match them by tapping both. Unlike
  /// [generateGrid], repeated answers across different pairs are fine (and
  /// even welcome — bkz. Bölüm 4 edge case): only the expression *text*
  /// must stay unique within the grid.
  ///
  /// Two-step expressions are intentionally skipped here (kept for Sayı
  /// Avı modu) since reverse-engineering a second expression for an
  /// arbitrary two-step answer would need much heavier machinery than this
  /// simpler matching game warrants.
  List<MathProblem> generateMatchGrid(
    DifficultyLevel level, {
    required Set<Operation> operations,
    int pairCount = 12,
  }) {
    final problems = <MathProblem>[];
    final usedExpressions = <String>{};
    final operationList = operations.toList();
    final targetCount = pairCount * 2;
    var attempts = 0;
    final maxAttempts = pairCount * 400;

    while (problems.length < targetCount && attempts < maxAttempts) {
      attempts++;
      final pair = _findUniquePair(operationList, level, usedExpressions);
      if (pair == null) continue;
      usedExpressions.add(pair.$1.expression);
      usedExpressions.add(pair.$2.expression);
      problems.add(pair.$1);
      problems.add(pair.$2);
    }

    // Safety net: guarantee a full grid even in pathological cases (e.g. a
    // single operation type with a tiny answer range) so the game never
    // launches with an unpaired cell. Still tries hard for a unique pair
    // first — duplicates are only accepted once the expression domain for
    // this level/operation combo is truly exhausted.
    while (problems.length < targetCount) {
      final pair = _findUniquePair(
        operationList,
        level,
        usedExpressions,
        attempts: 150,
      );
      if (pair != null) {
        usedExpressions.add(pair.$1.expression);
        usedExpressions.add(pair.$2.expression);
        problems.add(pair.$1);
        problems.add(pair.$2);
        continue;
      }

      final seedOp = operationList[_random.nextInt(operationList.length)];
      final seed = _generateSingleStep(seedOp, level);
      final partner = _forAnswer(seedOp, seed.answer, level) ?? seed;
      problems.add(seed);
      problems.add(partner);
    }

    problems.shuffle(_random);
    return problems;
  }

  /// Tries to find two different single-step expressions sharing an answer,
  /// neither of which is already in [usedExpressions]. Returns null if no
  /// such pair turns up within [attempts] tries (e.g. the answer domain for
  /// this level/operation combo is nearly or fully exhausted).
  (MathProblem, MathProblem)? _findUniquePair(
    List<Operation> operationList,
    DifficultyLevel level,
    Set<String> usedExpressions, {
    int attempts = 1,
  }) {
    for (var i = 0; i < attempts; i++) {
      final seedOp = operationList[_random.nextInt(operationList.length)];
      final seed = _generateSingleStep(seedOp, level);
      if (usedExpressions.contains(seed.expression)) continue;

      for (var j = 0; j < 40; j++) {
        final partnerOp = operationList[_random.nextInt(operationList.length)];
        final candidate = _forAnswer(partnerOp, seed.answer, level);
        if (candidate == null) continue;
        if (candidate.expression == seed.expression) continue;
        if (usedExpressions.contains(candidate.expression)) continue;
        return (seed, candidate);
      }
    }
    return null;
  }

  /// Builds a single-step expression for [operation] that evaluates to
  /// exactly [targetAnswer], or null when no valid expression exists for
  /// that answer (e.g. no divisor pair fits within the level's range).
  MathProblem? _forAnswer(
    Operation operation,
    int targetAnswer,
    DifficultyLevel level,
  ) {
    switch (operation) {
      case Operation.addition:
        if (targetAnswer < 2) return null;
        final a = _randomInt(1, targetAnswer - 1);
        final b = targetAnswer - a;
        return MathProblem(expression: '$a + $b', answer: targetAnswer);

      case Operation.subtraction:
        final b = _randomInt(1, level.maxNumber);
        final a = targetAnswer + b;
        return MathProblem(expression: '$a - $b', answer: targetAnswer);

      case Operation.multiplication:
        final maxFactor = _multiplicationMaxFactor(level);
        final divisors = [
          for (var d = 1; d <= maxFactor; d++)
            if (targetAnswer % d == 0) d,
        ];
        if (divisors.isEmpty) return null;
        final nonTrivial = divisors
            .where((d) => d != 1 && targetAnswer ~/ d != 1)
            .toList();
        final pool = nonTrivial.isNotEmpty ? nonTrivial : divisors;
        final d = pool[_random.nextInt(pool.length)];
        final other = targetAnswer ~/ d;
        return MathProblem(expression: '$d x $other', answer: targetAnswer);

      case Operation.division:
        if (targetAnswer < 1) return null;
        final maxFactor = _multiplicationMaxFactor(level);
        final divisor = _randomInt(2, maxFactor);
        final dividend = divisor * targetAnswer;
        return MathProblem(
          expression: '$dividend ÷ $divisor',
          answer: targetAnswer,
        );
    }
  }

  MathProblem _generateOne(DifficultyLevel level, List<Operation> operations) {
    // İki adımlı ifadeler (Bölüm 5) toplama/çıkarma/çarpmayı bir arada
    // kullanır, bu yüzden sadece kullanıcı tüm işlemleri seçtiyse üretilir.
    final allowTwoStep =
        level.useTwoStepExpressions &&
        operations.length == Operation.values.length;
    if (allowTwoStep && _random.nextBool()) {
      return _generateTwoStep();
    }
    final operation = operations[_random.nextInt(operations.length)];
    return _generateSingleStep(operation, level);
  }

  MathProblem _generateSingleStep(Operation operation, DifficultyLevel level) {
    switch (operation) {
      case Operation.addition:
        final a = _randomInt(1, level.maxNumber);
        final b = _randomInt(1, level.maxNumber);
        return MathProblem(expression: '$a + $b', answer: a + b);

      case Operation.subtraction:
        final a = _randomInt(2, level.maxNumber);
        final b = _randomInt(1, a); // b <= a, so result is never negative
        return MathProblem(expression: '$a - $b', answer: a - b);

      case Operation.multiplication:
        final maxFactor = _multiplicationMaxFactor(level);
        final a = _randomInt(1, maxFactor);
        final b = _randomInt(1, maxFactor);
        return MathProblem(expression: '$a x $b', answer: a * b);

      case Operation.division:
        final maxFactor = _multiplicationMaxFactor(level);
        final divisor = _randomInt(2, maxFactor);
        final quotient = _randomInt(1, maxFactor);
        final dividend = divisor * quotient; // guarantees no remainder
        return MathProblem(
          expression: '$dividend ÷ $divisor',
          answer: quotient,
        );
    }
  }

  int _multiplicationMaxFactor(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.easy:
        return 5;
      case DifficultyLevel.medium:
        return 10;
      case DifficultyLevel.hard:
      case DifficultyLevel.expert:
        return 12;
    }
  }

  MathProblem _generateTwoStep() {
    final pattern = _randomInt(1, 4);
    switch (pattern) {
      case 1: // (a + b) x c
        final a = _randomInt(1, 12);
        final b = _randomInt(1, 12);
        final c = _randomInt(2, 9);
        return MathProblem(expression: '($a + $b) x $c', answer: (a + b) * c);
      case 2: // (a - b) x c
        final a = _randomInt(2, 20);
        final b = _randomInt(1, a);
        final c = _randomInt(2, 9);
        return MathProblem(expression: '($a - $b) x $c', answer: (a - b) * c);
      case 3: // (a x b) + c
        final a = _randomInt(1, 9);
        final b = _randomInt(1, 9);
        final c = _randomInt(1, 20);
        return MathProblem(expression: '($a x $b) + $c', answer: (a * b) + c);
      default: // (a x b) - c, kept non-negative
        final a = _randomInt(1, 9);
        final b = _randomInt(1, 9);
        final product = a * b;
        final c = _randomInt(0, product);
        return MathProblem(expression: '($a x $b) - $c', answer: product - c);
    }
  }

  /// Inclusive random integer in [min, max].
  int _randomInt(int min, int max) {
    if (max <= min) return min;
    return min + _random.nextInt(max - min + 1);
  }
}
