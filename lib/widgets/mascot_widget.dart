import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Bölüm 8 — "Karakter/Maskot": maskotun o an göstermesi gereken ruh hali.
/// [idle] sürekli döngüde oynar; [happy]/[sad] bir kerelik tepki animasyonu
/// tetikler (bkz. [MascotWidget]).
enum MascotMood { idle, happy, sad }

/// Bölüm 17 — Rütbe kıyafetleri: Günlük Hedefler ekranındaki rütbe merdiveni
/// (`DailyRank`), her basamağa karşılık gelen bir kıyafet giydirerek
/// maskotu ilerlemenin görsel bir kanıtı hâline getirir. Sıra `DailyRank`
/// enum'ıyla birebir eşleşir (bkz. `daily_goals_screen.dart`):
/// Sayı Çırağı → [none], Toplama Ustası → [cape] ("+" rozetli pelerin),
/// Çarpım Kahramanı → [hero] (maskeli pelerin), Bölme Büyücüsü → [wizard]
/// (sivri şapka), Matematik Dahisi → [genius] (taç + gözlük).
enum MascotOutfit { none, cape, hero, wizard, genius }

/// TopCik'in maskotu: Cik adında dost bir baykuş. Sürekli hafifçe zıplayıp
/// göz kırpar (idle), doğru cevapta sevinçle zıplayıp etrafına yıldız saçar
/// (happy), yanlış cevapta üzülüp sallanır (sad). Saf vektör şekillerden
/// çizilir — görsel asset gerektirmez. [outfit] verilirse (bkz. Bölüm 17),
/// rütbeye özgü bir aksesuar giydirir; [outfitColor] verilmezse aksesuar
/// makul bir varsayılan renk kullanır.
class MascotWidget extends StatefulWidget {
  const MascotWidget({
    super.key,
    this.mood = MascotMood.idle,
    this.size = 120,
    this.outfit = MascotOutfit.none,
    this.outfitColor,
  });

  final MascotMood mood;
  final double size;
  final MascotOutfit outfit;
  final Color? outfitColor;

  @override
  State<MascotWidget> createState() => _MascotWidgetState();
}

class _MascotWidgetState extends State<MascotWidget>
    with TickerProviderStateMixin {
  late final AnimationController _idleController;
  late final AnimationController _reactController;
  late MascotMood _reactingMood;

  @override
  void initState() {
    super.initState();
    _reactingMood = widget.mood;
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();
    _reactController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    if (widget.mood != MascotMood.idle) {
      _reactController.forward(from: 0);
    }
  }

  @override
  void didUpdateWidget(covariant MascotWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.mood != oldWidget.mood && widget.mood != MascotMood.idle) {
      _reactingMood = widget.mood;
      _reactController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _idleController.dispose();
    _reactController.dispose();
    super.dispose();
  }

  /// 0 (tam açık) .. 1 (tam kapalı) arası göz kırpma miktarı. Her idle
  /// döngüsünün sonuna doğru kısa bir göz kırpma sıkıştırılır, döngünün
  /// geri kalanında gözler tam açık kalır.
  double _blinkAmount(double idleValue) {
    const blinkStart = 0.86;
    const blinkEnd = 0.98;
    if (idleValue < blinkStart || idleValue > blinkEnd) return 0;
    final t = (idleValue - blinkStart) / (blinkEnd - blinkStart);
    return sin(t * pi).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size * 1.25,
      child: AnimatedBuilder(
        animation: Listenable.merge([_idleController, _reactController]),
        builder: (context, _) {
          final idleT = _idleController.value * 2 * pi;
          final bob = sin(idleT) * widget.size * 0.025;
          final wingFlap = sin(idleT) * 0.18;
          final blink = _blinkAmount(_idleController.value);

          // Yüz ifadesi her zaman güncel [widget.mood]'u yansıtır (sonuç
          // ekranlarında olduğu gibi kalıcı olabilir); [_reactController] ise
          // sadece o moda YENİ girildiğinde bir kerelik fiziksel tepkiyi
          // (zıplama/sallanma + kıvılcım) sürer, ifadeyi geri almaz.
          final mood = widget.mood;
          final reactT = _reactController.value;
          final bursting = reactT < 1.0 && mood == _reactingMood;

          var offsetX = 0.0;
          var offsetY = bob;
          var rotate = 0.0;

          if (bursting && mood == MascotMood.happy) {
            final hop = sin(pi * reactT.clamp(0.0, 1.0));
            offsetY -= widget.size * 0.28 * hop;
            rotate = sin(reactT * pi * 3) * 0.12 * (1 - reactT);
          } else if (bursting && mood == MascotMood.sad) {
            final decay = 1 - reactT;
            offsetX = sin(reactT * pi * 9) * widget.size * 0.05 * decay;
            rotate = sin(reactT * pi * 9) * 0.06 * decay;
          }

          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              if (bursting && mood == MascotMood.happy)
                _Sparkles(size: widget.size, progress: reactT),
              Transform.translate(
                offset: Offset(offsetX, offsetY),
                child: Transform.rotate(
                  angle: rotate,
                  child: _OwlBody(
                    size: widget.size,
                    mood: mood,
                    blink: blink,
                    wingFlap: wingFlap,
                    outfit: widget.outfit,
                    outfitColor: widget.outfitColor ?? _defaultOutfitColor(widget.outfit),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// [MascotWidget.outfitColor] verilmediğinde kullanılan varsayılanlar —
/// `DailyRank.color`'daki (bkz. `models/daily_goal.dart`) rütbe renkleriyle
/// aynı paletten, ama modelin widget katmanına bağımlı olmaması için burada
/// ayrıca tanımlanır.
Color _defaultOutfitColor(MascotOutfit outfit) {
  switch (outfit) {
    case MascotOutfit.none:
      return AppColors.cta;
    case MascotOutfit.cape:
      return AppColors.levelMedium;
    case MascotOutfit.hero:
      return AppColors.levelHard;
    case MascotOutfit.wizard:
      return AppColors.levelExpert;
    case MascotOutfit.genius:
      return AppColors.gold;
  }
}

class _OwlBody extends StatelessWidget {
  const _OwlBody({
    required this.size,
    required this.mood,
    required this.blink,
    required this.wingFlap,
    required this.outfit,
    required this.outfitColor,
  });

  final double size;
  final MascotMood mood;
  final double blink;
  final double wingFlap;
  final MascotOutfit outfit;
  final Color outfitColor;

  @override
  Widget build(BuildContext context) {
    final s = size;
    return SizedBox(
      width: s,
      height: s * 1.15,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Pelerin (Toplama Ustası / Çarpım Kahramanı / Bölme Büyücüsü) —
          // gövdenin arkasında kalması için en altta.
          if (outfit == MascotOutfit.cape ||
              outfit == MascotOutfit.hero ||
              outfit == MascotOutfit.wizard)
            Positioned(
              top: s * 0.3,
              child: _Cape(size: s * 0.92, color: outfitColor),
            ),
          // Ayaklar
          Positioned(
            bottom: 0,
            left: s * 0.28,
            child: _Foot(size: s * 0.14),
          ),
          Positioned(
            bottom: 0,
            right: s * 0.28,
            child: _Foot(size: s * 0.14),
          ),
          // Kanatlar
          Positioned(
            top: s * 0.42,
            left: -s * 0.04,
            child: Transform.rotate(
              angle: -0.5 + wingFlap,
              child: _Wing(size: s * 0.34),
            ),
          ),
          Positioned(
            top: s * 0.42,
            right: -s * 0.04,
            child: Transform.rotate(
              angle: 0.5 - wingFlap,
              child: Transform.flip(flipX: true, child: _Wing(size: s * 0.34)),
            ),
          ),
          // Gövde
          Container(
            width: s * 0.86,
            height: s * 1.02,
            margin: EdgeInsets.only(top: s * 0.1),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.cta, Color.lerp(AppColors.cta, Colors.black, 0.14)!],
              ),
              borderRadius: BorderRadius.circular(s * 0.5),
              border: Border.all(color: Colors.white, width: s * 0.02),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: s * 0.08,
                  offset: Offset(0, s * 0.03),
                ),
              ],
            ),
          ),
          // Karın lekesi
          Positioned(
            bottom: s * 0.08,
            child: Container(
              width: s * 0.42,
              height: s * 0.48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(s * 0.3),
              ),
            ),
          ),
          // Göğüs rozeti (Toplama Ustası: "+", Çarpım Kahramanı: "×")
          if (outfit == MascotOutfit.cape || outfit == MascotOutfit.hero)
            Positioned(
              bottom: s * 0.44,
              child: _ChestBadge(
                size: s * 0.2,
                symbol: outfit == MascotOutfit.hero ? '×' : '+',
                color: outfitColor,
              ),
            ),
          // Kulak tüyleri (büyücü şapkası/taç varken şapkanın altında kalır)
          Positioned(
            top: -s * 0.02,
            left: s * 0.2,
            child: Transform.rotate(
              angle: -0.35,
              child: _EarTuft(size: s * 0.16),
            ),
          ),
          Positioned(
            top: -s * 0.02,
            right: s * 0.2,
            child: Transform.rotate(
              angle: 0.35,
              child: _EarTuft(size: s * 0.16),
            ),
          ),
          // Yüz
          Positioned(
            top: s * 0.24,
            child: _Face(size: s, mood: mood, blink: blink, outfit: outfit),
          ),
          // Baş üstü aksesuar (Bölme Büyücüsü: şapka, Matematik Dahisi: taç)
          if (outfit == MascotOutfit.wizard)
            Positioned(
              top: -s * 0.34,
              child: _WizardHat(size: s * 0.5, color: outfitColor),
            ),
          if (outfit == MascotOutfit.genius)
            Positioned(top: -s * 0.14, child: _Crown(size: s * 0.44)),
        ],
      ),
    );
  }
}

class _Face extends StatelessWidget {
  const _Face({
    required this.size,
    required this.mood,
    required this.blink,
    required this.outfit,
  });

  final double size;
  final MascotMood mood;
  final double blink;
  final MascotOutfit outfit;

  @override
  Widget build(BuildContext context) {
    final s = size;
    final browAngle = mood == MascotMood.sad
        ? 0.34
        : mood == MascotMood.happy
            ? -0.12
            : 0.0;
    final browOffsetY = mood == MascotMood.happy ? -s * 0.02 : 0.0;

    return SizedBox(
      width: s * 0.7,
      height: s * 0.42,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _Eye(size: s * 0.26, mood: mood, blink: blink),
              _Eye(size: s * 0.26, mood: mood, blink: blink, mirrored: true),
            ],
          ),
          Positioned(
            top: -s * 0.05 + browOffsetY,
            left: s * 0.02,
            child: Transform.rotate(
              angle: -browAngle,
              child: _Brow(size: s * 0.16),
            ),
          ),
          Positioned(
            top: -s * 0.05 + browOffsetY,
            right: s * 0.02,
            child: Transform.rotate(
              angle: browAngle,
              child: _Brow(size: s * 0.16),
            ),
          ),
          Positioned(top: s * 0.28, child: _Beak(size: s * 0.14)),
          Positioned(top: s * 0.4, child: _Mouth(size: s * 0.2, mood: mood)),
          // Çarpım Kahramanı: gözlerin üzerinden geçen kahraman maskesi.
          if (outfit == MascotOutfit.hero)
            Positioned(
              top: s * 0.02,
              child: _HeroMask(width: s * 0.62, height: s * 0.16),
            ),
          // Matematik Dahisi: yuvarlak gözlük.
          if (outfit == MascotOutfit.genius)
            Positioned(top: s * 0.03, child: _Glasses(size: s * 0.66)),
        ],
      ),
    );
  }
}

class _Eye extends StatelessWidget {
  const _Eye({
    required this.size,
    required this.mood,
    required this.blink,
    this.mirrored = false,
  });

  final double size;
  final MascotMood mood;
  final double blink;
  final bool mirrored;

  @override
  Widget build(BuildContext context) {
    final happy = mood == MascotMood.happy;
    final sad = mood == MascotMood.sad;
    // Mutluyken göz kısılır (yarım ay), üzgünken küçülür; ikisi de blink
    // ile aynı dikey sıkıştırma mekanizmasını paylaşır.
    final squint = happy ? 0.55 : (sad ? 0.35 : 0.0);
    final scaleY = (1 - blink).clamp(0.05, 1.0) * (1 - squint);

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Transform.scale(
        scaleY: scaleY,
        child: Container(
          width: size * (sad ? 0.34 : 0.4),
          height: size * (sad ? 0.34 : 0.4),
          decoration: const BoxDecoration(
            color: Color(0xFF2A2350),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _Brow extends StatelessWidget {
  const _Brow({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 0.22,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2350),
        borderRadius: BorderRadius.circular(size),
      ),
    );
  }
}

class _Beak extends StatelessWidget {
  const _Beak({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 0.8),
      painter: _TrianglePainter(color: AppColors.gold),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  _TrianglePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Mutlulukta gülümseme, üzgünlükte asık surat, aksi halde küçük bir "o".
class _Mouth extends StatelessWidget {
  const _Mouth({required this.size, required this.mood});

  final double size;
  final MascotMood mood;

  @override
  Widget build(BuildContext context) {
    if (mood == MascotMood.happy) {
      return ClipRRect(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(size * 0.5),
          bottomRight: Radius.circular(size * 0.5),
        ),
        child: Container(
          width: size,
          height: size * 0.4,
          color: const Color(0xFF2A2350),
        ),
      );
    }
    if (mood == MascotMood.sad) {
      return ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(size * 0.5),
          topRight: Radius.circular(size * 0.5),
        ),
        child: Container(
          width: size * 0.7,
          height: size * 0.32,
          margin: EdgeInsets.only(top: size * 0.2),
          color: const Color(0xFF2A2350),
        ),
      );
    }
    return Container(
      width: size * 0.22,
      height: size * 0.22,
      decoration: const BoxDecoration(
        color: Color(0xFF2A2350),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _Wing extends StatelessWidget {
  const _Wing({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 1.3,
      decoration: BoxDecoration(
        color: Color.lerp(AppColors.cta, Colors.black, 0.22),
        borderRadius: BorderRadius.circular(size),
        border: Border.all(color: Colors.white, width: size * 0.05),
      ),
    );
  }
}

class _Foot extends StatelessWidget {
  const _Foot({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 0.6,
      decoration: BoxDecoration(
        color: AppColors.gold,
        borderRadius: BorderRadius.circular(size),
      ),
    );
  }
}

class _EarTuft extends StatelessWidget {
  const _EarTuft({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size * 0.3,
      height: size,
      decoration: BoxDecoration(
        color: Color.lerp(AppColors.cta, Colors.black, 0.14),
        borderRadius: BorderRadius.circular(size),
      ),
    );
  }
}

/// Toplama Ustası / Çarpım Kahramanı / Bölme Büyücüsü pelerini — gövdenin
/// arkasından taşan, aşağı doğru genişleyen basit bir pelerin silüeti.
class _Cape extends StatelessWidget {
  const _Cape({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _CapeClipper(),
      child: Container(
        width: size,
        height: size,
        color: Color.lerp(color, Colors.black, 0.08),
      ),
    );
  }
}

class _CapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(size.width * 0.5, 0)
      ..lineTo(size.width * 0.98, size.height)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.82,
        size.width * 0.02,
        size.height,
      )
      ..close();
  }

  @override
  bool shouldReclip(covariant _CapeClipper oldClipper) => false;
}

/// Toplama Ustası ("+") ve Çarpım Kahramanı ("×") göğüs rozeti.
class _ChestBadge extends StatelessWidget {
  const _ChestBadge({
    required this.size,
    required this.symbol,
    required this.color,
  });

  final double size;
  final String symbol;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: size * 0.1),
      ),
      child: Text(
        symbol,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: size * 0.55,
          height: 1,
        ),
      ),
    );
  }
}

/// Çarpım Kahramanı'nın gözlerinin üzerinden geçen kahraman maskesi.
class _HeroMask extends StatelessWidget {
  const _HeroMask({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2350),
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );
  }
}

/// Bölme Büyücüsü'nün sivri şapkası: geniş kenar + koni + tepede yıldız.
class _WizardHat extends StatelessWidget {
  const _WizardHat({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 1.2,
      height: size * 1.3,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            bottom: 0,
            child: Container(
              width: size * 1.2,
              height: size * 0.16,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(size),
              ),
            ),
          ),
          Positioned(
            bottom: size * 0.1,
            child: CustomPaint(
              size: Size(size * 0.8, size * 1.05),
              painter: _TrianglePainter(color: color),
            ),
          ),
          Positioned(
            top: -size * 0.04,
            child: Icon(
              Icons.star_rounded,
              color: AppColors.gold,
              size: size * 0.24,
            ),
          ),
        ],
      ),
    );
  }
}

/// Matematik Dahisi'nin tacı — üç sivri uçlu, ortasında küçük bir mücevher.
class _Crown extends StatelessWidget {
  const _Crown({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 0.68),
      painter: _CrownPainter(),
    );
  }
}

class _CrownPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.32)
      ..lineTo(size.width * 0.22, size.height * 0.58)
      ..lineTo(size.width * 0.5, 0)
      ..lineTo(size.width * 0.78, size.height * 0.58)
      ..lineTo(size.width, size.height * 0.32)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = AppColors.gold);
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.72),
      size.height * 0.13,
      Paint()..color = AppColors.error,
    );
  }

  @override
  bool shouldRepaint(covariant _CrownPainter oldDelegate) => false;
}

/// Matematik Dahisi'nin yuvarlak gözlüğü — köprüyle bağlı iki mercek.
class _Glasses extends StatelessWidget {
  const _Glasses({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final lens = size * 0.36;
    return SizedBox(
      width: size,
      height: lens,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 0.2,
            height: lens * 0.12,
            color: const Color(0xFF2A2350),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Lens(size: lens),
              _Lens(size: lens),
            ],
          ),
        ],
      ),
    );
  }
}

class _Lens extends StatelessWidget {
  const _Lens({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.18),
        border: Border.all(
          color: const Color(0xFF2A2350),
          width: size * 0.14,
        ),
      ),
    );
  }
}

/// Doğru cevapta maskotun etrafına saçılıp sönen küçük yıldızlar.
class _Sparkles extends StatelessWidget {
  const _Sparkles({required this.size, required this.progress});

  final double size;
  final double progress;

  static const _positions = [
    Alignment(-1.3, -0.9),
    Alignment(1.3, -0.9),
    Alignment(-1.4, 0.3),
    Alignment(1.4, 0.3),
    Alignment(0.0, -1.5),
  ];

  @override
  Widget build(BuildContext context) {
    final opacity = (1 - progress).clamp(0.0, 1.0);
    final travel = Curves.easeOut.transform(progress.clamp(0.0, 1.0));
    return SizedBox(
      width: size,
      height: size * 1.25,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < _positions.length; i++)
            Align(
              alignment: Alignment(
                _positions[i].x * travel,
                _positions[i].y * travel,
              ),
              child: Opacity(
                opacity: opacity,
                child: Transform.rotate(
                  angle: progress * pi * (i.isEven ? 1.5 : -1.5),
                  child: Icon(
                    Icons.star_rounded,
                    color: AppColors.gold,
                    size: size * 0.16,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
