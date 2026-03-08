import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Flutter equivalent of the HeroGeometric / shape-landing-hero React component.
///
/// Features:
/// - Animated floating elliptical shapes with blur + gradient (ElegantShape)
/// - Fade-up staggered text animations
/// - Dark gradient background (brand navy)
/// - Badge pill
/// - Gradient headline text
class HeroGeometric extends StatefulWidget {
  final String badge;
  final String title1;
  final String title2;
  final String subtitle;

  const HeroGeometric({
    super.key,
    this.badge = 'Jagdish General Stores',
    this.title1 = 'Best Quality At',
    this.title2 = 'Affordable Price',
    this.subtitle =
        'Your neighbourhood cosmetics & essentials store — premium brands, everyday prices.',
  });

  @override
  State<HeroGeometric> createState() => _HeroGeometricState();
}

class _HeroGeometricState extends State<HeroGeometric>
    with TickerProviderStateMixin {
  // Entry animation controller (shapes drop in)
  late final AnimationController _entryCtrl;
  // Float loop controller (shapes bob up-down)
  late final AnimationController _floatCtrl;
  // Text fade-up controller
  late final AnimationController _textCtrl;

  @override
  void initState() {
    super.initState();

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..forward();

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);

    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Start text animation after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _textCtrl.forward();
    });
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _floatCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 420,
      width: double.infinity,
      child: Stack(
        children: [
          // ── Dark background with subtle gradient overlay ──
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF080E24),
                  Color(0xFF0D1B4B),
                  Color(0xFF0A1433),
                ],
              ),
            ),
          ),

          // ── Subtle radial bloom overlay (like the blurred bg in React) ──
          Positioned.fill(
            child: CustomPaint(painter: _BloomPainter()),
          ),

          // ── Floating Shapes ──
          _ElegantShape(
            entryCtrl: _entryCtrl,
            floatCtrl: _floatCtrl,
            delay: 0.3,
            width: 520,
            height: 120,
            rotateDeg: 12,
            gradient: const LinearGradient(
              colors: [Color(0x264F46E5), Color(0x00000000)],
            ),
            top: 0.18,
            left: -0.05,
          ),
          _ElegantShape(
            entryCtrl: _entryCtrl,
            floatCtrl: _floatCtrl,
            delay: 0.5,
            width: 440,
            height: 100,
            rotateDeg: -15,
            gradient: const LinearGradient(
              colors: [Color(0x26F43F5E), Color(0x00000000)],
            ),
            top: 0.72,
            right: 0.0,
          ),
          _ElegantShape(
            entryCtrl: _entryCtrl,
            floatCtrl: _floatCtrl,
            delay: 0.4,
            width: 260,
            height: 72,
            rotateDeg: -8,
            gradient: const LinearGradient(
              colors: [Color(0x268B5CF6), Color(0x00000000)],
            ),
            bottom: 0.08,
            left: 0.07,
          ),
          _ElegantShape(
            entryCtrl: _entryCtrl,
            floatCtrl: _floatCtrl,
            delay: 0.6,
            width: 180,
            height: 55,
            rotateDeg: 20,
            gradient: const LinearGradient(
              colors: [Color(0x26FFD700), Color(0x00000000)],
            ),
            top: 0.08,
            right: 0.18,
          ),
          _ElegantShape(
            entryCtrl: _entryCtrl,
            floatCtrl: _floatCtrl,
            delay: 0.7,
            width: 130,
            height: 38,
            rotateDeg: -25,
            gradient: const LinearGradient(
              colors: [Color(0x2606B6D4), Color(0x00000000)],
            ),
            top: 0.04,
            left: 0.22,
          ),

          // ── Top/Bottom fade vignettes ──
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF080E24).withValues(alpha: 0.8),
                    Colors.transparent,
                    Colors.transparent,
                    const Color(0xFF080E24).withValues(alpha: 0.7),
                  ],
                  stops: const [0.0, 0.2, 0.75, 1.0],
                ),
              ),
            ),
          ),

          // ── Content ──
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Badge
                  _FadeUp(
                    controller: _textCtrl,
                    delay: 0.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                            width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF4D6D).withValues(alpha: 0.85),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.badge,
                            style: const TextStyle(
                              color: Color(0x99FFFFFF),
                              fontSize: 13,
                              letterSpacing: 0.8,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Title 1 — white gradient
                  _FadeUp(
                    controller: _textCtrl,
                    delay: 0.2,
                    child: ShaderMask(
                      shaderCallback: (rect) => const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.white, Color(0xCCFFFFFF)],
                      ).createShader(rect),
                      child: Text(
                        widget.title1,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -1.5,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Title 2 — indigo→white→rose gradient
                  _FadeUp(
                    controller: _textCtrl,
                    delay: 0.35,
                    child: ShaderMask(
                      shaderCallback: (rect) => const LinearGradient(
                        colors: [
                          Color(0xFFA5B4FC), // indigo-300
                          Color(0xFFFFD700), // gold
                          Color(0xFFFDA4AF), // rose-300
                        ],
                        stops: [0.0, 0.5, 1.0],
                      ).createShader(rect),
                      child: Text(
                        widget.title2,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -1.5,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Subtitle
                  _FadeUp(
                    controller: _textCtrl,
                    delay: 0.5,
                    child: Text(
                      widget.subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.4),
                        fontWeight: FontWeight.w300,
                        letterSpacing: 0.4,
                        height: 1.6,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // CTA buttons
                  _FadeUp(
                    controller: _textCtrl,
                    delay: 0.65,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _HeroCTA(
                          label: 'Shop Now',
                          isPrimary: true,
                          onTap: () {},
                        ),
                        const SizedBox(width: 12),
                        _HeroCTA(
                          label: 'View Offers',
                          isPrimary: false,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Elegant floating shape ────────────────────────────────────────────────────
class _ElegantShape extends StatelessWidget {
  final AnimationController entryCtrl;
  final AnimationController floatCtrl;
  final double delay;
  final double width;
  final double height;
  final double rotateDeg;
  final LinearGradient gradient;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;

  const _ElegantShape({
    required this.entryCtrl,
    required this.floatCtrl,
    required this.delay,
    required this.width,
    required this.height,
    required this.rotateDeg,
    required this.gradient,
    this.top,
    this.bottom,
    this.left,
    this.right,
  });

  @override
  Widget build(BuildContext context) {
    final delayedEntry = CurvedAnimation(
      parent: entryCtrl,
      curve: Interval(delay / 2.4, 1.0, curve: Curves.easeOutQuart),
    );

    return AnimatedBuilder(
      animation: Listenable.merge([delayedEntry, floatCtrl]),
      builder: (context, _) {
        final floatOffset = Tween(begin: 0.0, end: 15.0).evaluate(floatCtrl);
        final entryY = Tween(begin: -150.0, end: 0.0).evaluate(
          CurvedAnimation(parent: delayedEntry, curve: Curves.easeOutQuart),
        );
        final opacity = Tween(begin: 0.0, end: 1.0).evaluate(
          CurvedAnimation(
            parent: delayedEntry,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
          ),
        );
        final rotate = Tween(
          begin: (rotateDeg - 15) * math.pi / 180,
          end: rotateDeg * math.pi / 180,
        ).evaluate(CurvedAnimation(parent: delayedEntry, curve: Curves.easeOutQuart));

        return Positioned(
          top: top != null ? (top! * 420) + entryY + floatOffset : null,
          bottom: bottom != null ? (bottom! * 420) - floatOffset : null,
          left: left != null ? null : null,
          right: right,
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Transform.rotate(
              angle: rotate,
              child: Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(height / 2),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.04),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Fade-up text animation ─────────────────────────────────────────────────
class _FadeUp extends StatelessWidget {
  final AnimationController controller;
  final double delay; // 0-1 as fraction of controller duration
  final Widget child;

  const _FadeUp({
    required this.controller,
    required this.delay,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: controller,
      curve: Interval(delay, math.min(delay + 0.6, 1.0),
          curve: const Cubic(0.25, 0.4, 0.25, 1.0)),
    );

    return AnimatedBuilder(
      animation: curved,
      builder: (context, _) {
        final t = curved.value;
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 30),
            child: child,
          ),
        );
      },
    );
  }
}

// ─── CTA Button ─────────────────────────────────────────────────────────────
class _HeroCTA extends StatefulWidget {
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  const _HeroCTA(
      {required this.label, required this.isPrimary, required this.onTap});

  @override
  State<_HeroCTA> createState() => _HeroCTAState();
}

class _HeroCTAState extends State<_HeroCTA> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) { if (mounted) setState(() => _hovered = true); },
      onExit: (_) { if (mounted) setState(() => _hovered = false); },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            gradient: widget.isPrimary
                ? LinearGradient(
                    colors: _hovered
                        ? [const Color(0xFFFFD700), const Color(0xFFF59E0B)]
                        : [const Color(0xFFFFD700), const Color(0xFFFBBF24)],
                  )
                : null,
            color: widget.isPrimary ? null : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isPrimary
                  ? Colors.transparent
                  : Colors.white.withValues(alpha: 0.15),
            ),
            boxShadow: widget.isPrimary && _hovered
                ? [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    )
                  ]
                : [],
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: widget.isPrimary ? const Color(0xFF0D1B4B) : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Background bloom radial painter ────────────────────────────────────────
class _BloomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Left indigo bloom
    final p1 = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0x134F46E5),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.1, size.height * 0.3),
        radius: size.width * 0.5,
      ));
    canvas.drawCircle(
        Offset(size.width * 0.1, size.height * 0.3), size.width * 0.5, p1);

    // Right rose bloom
    final p2 = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0x13F43F5E),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.9, size.height * 0.7),
        radius: size.width * 0.45,
      ));
    canvas.drawCircle(
        Offset(size.width * 0.9, size.height * 0.7), size.width * 0.45, p2);
  }

  @override
  bool shouldRepaint(_BloomPainter old) => false;
}
