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

  const GradientScaffold({
    super.key,
    required this.title,
    required this.body,
    this.showFloatingSymbols = true,
    this.trailing,
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
          ],
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
