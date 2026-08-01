import 'package:flutter/painting.dart' show Color;

import '../theme/app_colors.dart';

enum Operation { addition, subtraction, multiplication, division }

extension OperationInfo on Operation {
  String get displayName {
    switch (this) {
      case Operation.addition:
        return 'Toplama';
      case Operation.subtraction:
        return 'Çıkarma';
      case Operation.multiplication:
        return 'Çarpma';
      case Operation.division:
        return 'Bölme';
    }
  }

  String get symbol {
    switch (this) {
      case Operation.addition:
        return '+';
      case Operation.subtraction:
        return '−';
      case Operation.multiplication:
        return '×';
      case Operation.division:
        return '÷';
    }
  }
}

enum DifficultyLevel { easy, medium, hard, expert }

extension DifficultyLevelInfo on DifficultyLevel {
  String get displayName {
    switch (this) {
      case DifficultyLevel.easy:
        return 'Kolay';
      case DifficultyLevel.medium:
        return 'Orta';
      case DifficultyLevel.hard:
        return 'Zor';
      case DifficultyLevel.expert:
        return 'Uzman';
    }
  }

  String get ageRange {
    switch (this) {
      case DifficultyLevel.easy:
        return '6-7 yaş';
      case DifficultyLevel.medium:
        return '8-9 yaş';
      case DifficultyLevel.hard:
        return '10-11 yaş';
      case DifficultyLevel.expert:
        return '12+ yaş';
    }
  }

  List<Operation> get operations {
    switch (this) {
      case DifficultyLevel.easy:
        return [Operation.addition, Operation.subtraction];
      case DifficultyLevel.medium:
        return [
          Operation.addition,
          Operation.subtraction,
          Operation.multiplication,
        ];
      case DifficultyLevel.hard:
        return [
          Operation.addition,
          Operation.subtraction,
          Operation.multiplication,
          Operation.division,
        ];
      case DifficultyLevel.expert:
        return [
          Operation.addition,
          Operation.subtraction,
          Operation.multiplication,
          Operation.division,
        ];
    }
  }

  /// Brand rengi (seviye kartları, skor tablosu rozetleri vb. bu tek
  /// kaynaktan renklenir).
  Color get color {
    switch (this) {
      case DifficultyLevel.easy:
        return AppColors.levelEasy;
      case DifficultyLevel.medium:
        return AppColors.levelMedium;
      case DifficultyLevel.hard:
        return AppColors.levelHard;
      case DifficultyLevel.expert:
        return AppColors.levelExpert;
    }
  }

  /// Maximum operand size used when generating problems for this level.
  int get maxNumber {
    switch (this) {
      case DifficultyLevel.easy:
        return 10;
      case DifficultyLevel.medium:
        return 20;
      case DifficultyLevel.hard:
        return 50;
      case DifficultyLevel.expert:
        return 100;
    }
  }

  /// Whether two-step expressions like "(3 + 2) x 4" should be generated.
  bool get useTwoStepExpressions => this == DifficultyLevel.expert;

  /// Time given to clear the 4x4 grid, in seconds (Bölüm 7).
  int get timeLimitSeconds {
    switch (this) {
      case DifficultyLevel.easy:
        return 90;
      case DifficultyLevel.medium:
        return 80;
      case DifficultyLevel.hard:
        return 70;
      case DifficultyLevel.expert:
        return 60;
    }
  }
}
