import 'dart:math';

import 'package:flutter/material.dart';

/// Mor gradient ekranların (ana menü, sonuç ekranları) arka planında yavaşça
/// süzülen küçük +, −, ×, ÷ sembolleri. Saf dekoratif bir katman — dokunma
/// olaylarını yutmaması için [IgnorePointer] ile sarılı.
class FloatingSymbolsBackground extends StatefulWidget {
  final int symbolCount;

  const FloatingSymbolsBackground({super.key, this.symbolCount = 22});

  @override
  State<FloatingSymbolsBackground> createState() =>
      _FloatingSymbolsBackgroundState();
}

class _FloatingSymbolsBackgroundState extends State<FloatingSymbolsBackground>
    with SingleTickerProviderStateMixin {
  static const _glyphs = ['+', '−', '×', '÷'];

  late final AnimationController _controller;
  late final List<_FloatingSymbol> _symbols;

  @override
  void initState() {
    super.initState();
    // Sabit tohum: her açılışta aynı, göz için dengeli dağılım üretir.
    final random = Random(7);
    _symbols = List.generate(widget.symbolCount, (i) {
      return _FloatingSymbol(
        glyph: _glyphs[i % _glyphs.length],
        left: random.nextDouble(),
        top: random.nextDouble(),
        size: 20 + random.nextDouble() * 26,
        opacity: 0.08 + random.nextDouble() * 0.11,
        driftX: 12 + random.nextDouble() * 16,
        driftY: 16 + random.nextDouble() * 20,
        phase: random.nextDouble() * 2 * pi,
        speed: 0.5 + random.nextDouble() * 0.7,
        spin: (random.nextBool() ? 1 : -1) * (0.12 + random.nextDouble() * 0.2),
      );
    });
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 26),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ClipRect(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final t = _controller.value * 2 * pi;
                return Stack(
                  children: [
                    for (final s in _symbols)
                      Positioned(
                        left:
                            s.left * w + sin(t * s.speed + s.phase) * s.driftX,
                        top: s.top * h + cos(t * s.speed + s.phase) * s.driftY,
                        child: Transform.rotate(
                          angle: sin(t * s.speed * 0.6 + s.phase) * s.spin,
                          child: Text(
                            s.glyph,
                            style: TextStyle(
                              fontSize: s.size,
                              fontWeight: FontWeight.w800,
                              color: Colors.white.withValues(alpha: s.opacity),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _FloatingSymbol {
  final String glyph;
  final double left;
  final double top;
  final double size;
  final double opacity;
  final double driftX;
  final double driftY;
  final double phase;
  final double speed;
  final double spin;

  _FloatingSymbol({
    required this.glyph,
    required this.left,
    required this.top,
    required this.size,
    required this.opacity,
    required this.driftX,
    required this.driftY,
    required this.phase,
    required this.speed,
    required this.spin,
  });
}
