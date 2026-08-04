import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'floating_symbols_background.dart';

/// Mor gradient + (opsiyonel) yüzen sembol arka planı üzerine, klasik düz
/// renkli `AppBar` yerine gradient'e gömülü, gölgesiz "modern" bir başlık
/// satırı (geri tuşu + başlık) koyan ortak ekran sarmalayıcı. Ana Menü ve
/// Sonuç ekranlarıyla aynı görsel dili; Mod Seç, Seviye Seç, İşlem Türü
/// Seç, Skor Tablosu, Ayarlar ve Oyun ekranlarına da taşır.
class GradientScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final bool showFloatingSymbols;
  final Widget? trailing;

  /// Süre son 10 saniyeye düşünce oyuncuyu uyarmak için ekranı nabız gibi
  /// karartır (bkz. CLAUDE.md Bölüm 7). Dokunuşları engellememesi için
  /// `IgnorePointer` ile sarılıdır.
  final bool dimmed;

  const GradientScaffold({
    super.key,
    required this.title,
    required this.body,
    this.showFloatingSymbols = true,
    this.trailing,
    this.dimmed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradient),
        child: Stack(
          children: [
            if (showFloatingSymbols)
              const Positioned.fill(child: FloatingSymbolsBackground()),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 20, 8),
                    child: Row(
                      children: [
                        const _BackButton(),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        ?trailing,
                      ],
                    ),
                  ),
                  Expanded(child: body),
                ],
              ),
            ),
            _PulsingDimOverlay(active: dimmed),
          ],
        ),
      ),
    );
  }
}

/// Aktifken yavaş, nefes alır gibi (0.18 ↔ 0.5 opaklık) dalgalanan, kapalıyken
/// yumuşakça sıfıra sönen tam ekran karartma katmanı.
class _PulsingDimOverlay extends StatefulWidget {
  final bool active;

  const _PulsingDimOverlay({required this.active});

  @override
  State<_PulsingDimOverlay> createState() => _PulsingDimOverlayState();
}

class _PulsingDimOverlayState extends State<_PulsingDimOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    // Yavaş, "nefes alma" hissi veren bir döngü (tam çevrim ~3.2 sn):
    // çocuklar için ürkütücü/gergin hissettirecek hızlı yanıp sönme yerine
    // yumuşak, ease-in-out bir karartma dalgası.
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _pulse = CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: widget.active ? 1.0 : 0.0,
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (context, _) {
            final alpha = 0.18 + 0.32 * _pulse.value;
            return Container(color: Colors.black.withValues(alpha: alpha));
          },
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.16),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => Navigator.of(context).maybePop(),
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}
