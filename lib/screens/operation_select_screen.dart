import 'package:flutter/material.dart';

import '../models/difficulty_level.dart';
import '../models/game_mode.dart';
import '../services/app_messenger.dart';
import '../services/audio_service.dart';
import '../services/score_service.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_scaffold.dart';

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

  /// Seçimi kaydeder ve Ana Menü'ye döner — oyun buradan başlamaz. Oyuncu,
  /// bu mod + seviye + işlem türü kombinasyonuyla oynamak için Ana
  /// Menü'deki "Oyna" butonuna basar (bkz. `MainMenuScreen._quickPlay`).
  Future<void> _saveAndReturnToMenu() async {
    await widget.scoreService.setLastOperations(_selected);
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
    scaffoldMessengerKey.currentState?.showSnackBar(
      const SnackBar(content: Text('Hazır! Başlamak için "Oyna"ya dokun 🎮')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      title: '${widget.mode.displayName} — İşlem Türü Seç',
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              children: [
                _OperationTile(
                  label: 'Hepsi',
                  color: AppColors.cta,
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
                      onChanged: (value) => _toggleOperation(operation, value),
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
                onPressed: _selected.isEmpty ? null : _saveAndReturnToMenu,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  disabledBackgroundColor: Colors.white.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Kaydet',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
      ),
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
