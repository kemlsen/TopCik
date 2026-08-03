import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:mathgrid/logic/problem_generator.dart';
import 'package:mathgrid/models/difficulty_level.dart';

void main() {
  group('ProblemGenerator.generateMatchGrid', () {
    test('produces 24 unique expressions forming 12 answer-matched pairs',
        () {
      final generator = ProblemGenerator(random: Random(42));
      final problems = generator.generateMatchGrid(
        DifficultyLevel.medium,
        operations: {
          Operation.addition,
          Operation.subtraction,
          Operation.multiplication,
        },
      );

      expect(problems.length, 24);

      final expressions = problems.map((p) => p.expression).toSet();
      expect(expressions.length, 24, reason: 'no duplicate expressions');

      final answerCounts = <int, int>{};
      for (final p in problems) {
        answerCounts[p.answer] = (answerCounts[p.answer] ?? 0) + 1;
      }
      // Every answer must be shared by at least one other cell so every
      // tile has a valid partner to match with.
      for (final count in answerCounts.values) {
        expect(count >= 2, isTrue, reason: 'every answer needs a partner');
      }
    });

    test('handles a narrow single-operation pool without hanging (division, easy)',
        () {
      // Division-only at "Kolay" only has ~20 distinct single-step
      // expressions (divisor 2-5 x quotient 1-5), fewer than the 24-cell
      // grid needs — the generator's documented safety net fills the rest
      // with repeats rather than hanging, so full uniqueness isn't
      // guaranteed here (bkz. generateMatchGrid doc comment).
      final generator = ProblemGenerator(random: Random(7));
      final problems = generator.generateMatchGrid(
        DifficultyLevel.easy,
        operations: {Operation.division},
      );

      expect(problems.length, 24);
      for (final p in problems) {
        expect(p.answer, greaterThanOrEqualTo(0));
      }
    });

    test('handles single-operation multiplication pool at easy level', () {
      final generator = ProblemGenerator(random: Random(99));
      final problems = generator.generateMatchGrid(
        DifficultyLevel.easy,
        operations: {Operation.multiplication},
      );

      expect(problems.length, 24);
    });

    test('works across all difficulty levels with all operations', () {
      for (final level in DifficultyLevel.values) {
        final generator = ProblemGenerator(random: Random(level.index));
        final problems = generator.generateMatchGrid(
          level,
          operations: Operation.values.toSet(),
        );
        expect(problems.length, 24, reason: 'failed for $level');
        expect(
          problems.map((p) => p.expression).toSet().length,
          24,
          reason: 'duplicate expression for $level',
        );
      }
    });
  });
}
