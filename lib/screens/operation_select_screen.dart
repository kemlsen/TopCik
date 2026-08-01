import 'package:flutter/material.dart';

import '../models/difficulty_level.dart';
import '../models/game_mode.dart';
import '../services/audio_service.dart';
import '../services/score_service.dart';
import '../theme/app_colors.dart';
import 'game_screen.dart';
import 'match_game_screen.dart';

const _operationColors = {
  Operation.addition: AppColors.levelEasy,
  Operation.subtraction: AppColors.levelMedium,
  Operation.multiplication: AppColors.levelHard,
  Operation.division: AppColors.levelExpert,
};

/// Her oyuna girişte oyuncunun hangi işlem türlerini (toplama, çıkarma,
/// çarpma, bölme veya hepsi) istediğini seçtiği ekran. Seçilen işlemler
/// gridteki tüm hücreleri belirler (bkz. ProblemGenerator.generateGrid /
/// generateMatchGrid). Hem Sayı Avı hem Eşleştirme modu bu ekranı paylaşır.
class OperationSelectScreen extends StatefulWidget {
  final DifficultyLevel level;
  final GameMode mode;
  final AudioService audioService;
  final ScoreService scoreService;

  const OperationSelectScreen({
    super.key,
    required this.level,
    required this.mode,
    required this.audioService,
    required this.scoreService,
  });

  @override
  State<OperationSelectScreen> createState() => _OperationSelectScreenState();
}

class _OperationSelectScreenState extends State<OperationSelectScreen> {
  late Set<Operation> _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.level.operations.toSet();
  }

  bool get _allSelected => _selected.length == Operation.values.length;

  void _toggleAll(bool? value) {
    setState(() {
      _selected = value == true ? Operation.values.toSet() : <Operation>{};
    });
  }

  void _toggleOperation(Operation operation, bool? value) {
    setState(() {
      if (value == true) {
        _selected.add(operation);
      } else {
        _selected.remove(operation);
      }
    });
  }

  void _start() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => widget.mode == GameMode.hunt
            ? GameScreen(
                level: widget.level,
                operations: _selected,
                audioService: widget.audioService,
                scoreService: widget.scoreService,
              )
            : MatchGameScreen(
                level: widget.level,
                operations: _selected,
                audioService: widget.audioService,
                scoreService: widget.scoreService,
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          '${widget.mode.displayName} — İşlem Türü Seç',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _OperationTile(
                    label: 'Hepsi',
                    color: AppColors.primary,
                    checked: _allSelected,
                    onChanged: _toggleAll,
                  ),
                  const SizedBox(height: 12),
                  ...Operation.values.map(
                    (operation) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _OperationTile(
                        label: '${operation.symbol}  ${operation.displayName}',
                        color: _operationColors[operation]!,
                        checked: _selected.contains(operation),
                        onChanged: (value) =>
                            _toggleOperation(operation, value),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selected.isEmpty ? null : _start,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cta,
                    disabledBackgroundColor: AppColors.cta.withValues(
                      alpha: 0.4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Başla',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OperationTile extends StatelessWidget {
  final String label;
  final Color color;
  final bool checked;
  final ValueChanged<bool?> onChanged;

  const _OperationTile({
    required this.label,
    required this.color,
    required this.checked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(20),
      elevation: 3,
      child: CheckboxListTile(
        value: checked,
        onChanged: onChanged,
        controlAffinity: ListTileControlAffinity.leading,
        checkColor: color,
        activeColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          label,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
