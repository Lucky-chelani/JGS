import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen>
    with SingleTickerProviderStateMixin {
  static const _bg = Color(0xFFFDF8F5);
  static const _textPrimary = Color(0xFF2D1B20);
  static const _textSecondary = Color(0xFF5A3A40);
  static const _accent = Color(0xFFB76E79);
  static const _border = Color(0xFFE8D5D0);

  late final AnimationController _floatCtrl;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final compact = w < 720;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
          icon: const Icon(Icons.arrow_back_rounded, color: _textPrimary),
        ),
        title: Text(
          'About Us',
          style: TextStyle(
            fontFamily: AppTheme.playfairFamily,
            color: _textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero ──
                _buildHero(compact),
                const SizedBox(height: 24),

                // ── Our Story ──
                _buildSection(
                  icon: Icons.auto_stories_outlined,
                  title: 'Our Story',
                  body:
                      'Jagdish General Store was founded in 1972 in Chhindwara, Madhya Pradesh, with a simple belief: everyone deserves access to premium beauty and personal care products at honest prices. What started as a small neighbourhood shop has grown into one of Chhindwara\'s most trusted names in beauty retail.\n\nFor over five decades, we have served lakhs of families — from brides curating their wedding kits to salon professionals stocking their shelves. Our commitment has never wavered: genuine products, fair prices, and personalised service.',
                ),
                const SizedBox(height: 16),

                // ── Mission cards ──
                _buildValueCards(compact),
                const SizedBox(height: 24),

                // ── Why trust us ──
                _buildSection(
                  icon: Icons.verified_outlined,
                  title: 'Why Customers Trust JGS',
                  body:
                      'Every product on our platform is sourced directly from authorised brand distributors or manufacturers. We do not stock grey-market or counterfeit goods — ever. Our quality assurance team manually reviews each batch before listing.\n\nWe have maintained a 4.8★ average satisfaction rating across 50,000+ orders and counting.',
                ),
                const SizedBox(height: 16),

                // ── Stats row ──
                _buildStatsRow(compact),
                const SizedBox(height: 24),

                // ── Team ──
                _buildSection(
                  icon: Icons.people_outline_rounded,
                  title: 'Our Team',
                  body:
                      'Behind JGS is a passionate team of beauty enthusiasts, technologists, and logistics experts based in Chhindwara. Our customer delight team is available 7 days a week to help you find the right product, track your order, or resolve any concern — fast.',
                ),
                const SizedBox(height: 16),

                // ── Contact CTA ──
                _buildContactCard(),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────── HERO ──

  Widget _buildHero(bool compact) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF0F3), Color(0xFFF9E2EA), Color(0xFFF5D5E0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: _border.withValues(alpha: 0.75)),
        boxShadow: [
          BoxShadow(
            color: _accent.withValues(alpha: 0.12),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _floatCtrl,
              builder: (_, __) =>
                  CustomPaint(painter: _AboutHeroPainter(_floatCtrl.value)),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(compact ? 22 : 32),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'SINCE 1972 · Chhindwara, Madhya Pradesh',
                          style: TextStyle(
                            color: Color(0xFF8B4A52),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Bringing Beauty\nto Every Home',
                        style: TextStyle(
                          fontFamily: AppTheme.playfairFamily,
                          color: _textPrimary,
                          fontSize: compact ? 30 : 44,
                          fontWeight: FontWeight.w900,
                          height: 1.12,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Three decades of trust. 50,000+ happy customers. One mission — genuine beauty for all.',
                        style: TextStyle(
                          color: _textSecondary.withValues(alpha: 0.72),
                          fontSize: compact ? 13 : 15,
                          height: 1.55,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!compact) ...[
                  const SizedBox(width: 24),
                  AnimatedBuilder(
                    animation: _floatCtrl,
                    builder: (_, __) {
                      final f = math.sin(_floatCtrl.value * math.pi);
                      return Transform.translate(
                        offset: Offset(0, -7 * f),
                        child: SizedBox(
                          width: 150,
                          height: 150,
                          child: CustomPaint(
                            painter: _StoreIllustrationPainter(
                              _floatCtrl.value,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────── SECTION ──

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String body,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border.withValues(alpha: 0.75)),
        boxShadow: [
          BoxShadow(
            color: _accent.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: _accent, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontFamily: AppTheme.playfairFamily,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            body,
            style: TextStyle(
              color: _textSecondary.withValues(alpha: 0.80),
              fontSize: 14,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────── VALUE CARDS ──

  Widget _buildValueCards(bool compact) {
    return LayoutBuilder(
      builder: (context, box) {
        final cardW = compact ? box.maxWidth : (box.maxWidth - 24) / 3;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: cardW,
              child: _valueCard(
                emoji: '💎',
                title: 'Genuine Products',
                subtitle: 'Sourced directly from authorised distributors only.',
                color: const Color(0xFFB76E79),
              ),
            ),
            SizedBox(
              width: cardW,
              child: _valueCard(
                emoji: '💰',
                title: 'Best Prices',
                subtitle: 'Honest pricing on 5,000+ beauty SKUs.',
                color: const Color(0xFFD4AF37),
              ),
            ),
            SizedBox(
              width: cardW,
              child: _valueCard(
                emoji: '🚚',
                title: 'Fast Delivery',
                subtitle: 'Delivered across India in 2–5 business days.',
                color: const Color(0xFF6BA3FF),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _valueCard({
    required String emoji,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: _textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: _textSecondary.withValues(alpha: 0.70),
              fontSize: 12,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────── STATS ──

  Widget _buildStatsRow(bool compact) {
    final stats = [
      ('30+', 'Years of Trust'),
      ('50K+', 'Happy Customers'),
      ('5000+', 'Beauty Products'),
      ('4.8★', 'Avg. Rating'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF0F3), Color(0xFFF9E2EA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: stats
            .map(
              (s) => Column(
                children: [
                  Text(
                    s.$1,
                    style: TextStyle(
                      fontFamily: AppTheme.playfairFamily,
                      color: _accent,
                      fontSize: compact ? 22 : 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s.$2,
                    style: TextStyle(
                      color: _textSecondary.withValues(alpha: 0.75),
                      fontSize: compact ? 10 : 12,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  // ─────────────────── CONTACT CTA ──

  Widget _buildContactCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _accent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.mail_outline_rounded, color: Colors.white, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Get in touch',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'jagdishgeneralstores12@gmail.com\n+91 8770132554\n+91 9406707158',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════ PAINTERS ════════════════

class _AboutHeroPainter extends CustomPainter {
  final double t;
  const _AboutHeroPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final positions = [
      Offset(size.width * 0.85, size.height * 0.15),
      Offset(size.width * 0.92, size.height * 0.60),
      Offset(size.width * 0.75, size.height * 0.85),
    ];
    final sizes = [50.0, 35.0, 25.0];
    for (int i = 0; i < positions.length; i++) {
      final alpha = 0.05 + 0.03 * math.sin(t * math.pi * 2 + i);
      paint.color = const Color(0xFFB76E79).withValues(alpha: alpha);
      canvas.drawCircle(positions[i], sizes[i], paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AboutHeroPainter old) => old.t != t;
}

/// Cute store‑front illustration for the hero.
class _StoreIllustrationPainter extends CustomPainter {
  final double t;
  const _StoreIllustrationPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..style = PaintingStyle.fill;
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Store building
    p.color = const Color(0xFFFAEEF2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy + 10), width: 90, height: 80),
        const Radius.circular(10),
      ),
      p,
    );

    // Roof
    p.color = const Color(0xFFB76E79);
    final roof = Path()
      ..moveTo(cx - 50, cy - 30)
      ..lineTo(cx, cy - 65)
      ..lineTo(cx + 50, cy - 30)
      ..close();
    canvas.drawPath(roof, p);

    // Door
    p.color = const Color(0xFFD4906A).withValues(alpha: 0.7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy + 35), width: 22, height: 32),
        const Radius.circular(11),
      ),
      p,
    );

    // Windows
    p.color = const Color(0xFFB0D4FF).withValues(alpha: 0.75);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx - 25, cy + 5), width: 22, height: 18),
        const Radius.circular(4),
      ),
      p,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx + 25, cy + 5), width: 22, height: 18),
        const Radius.circular(4),
      ),
      p,
    );

    // Sign board
    p.color = const Color(0xFFD4AF37);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy - 52), width: 48, height: 16),
        const Radius.circular(4),
      ),
      p,
    );

    // Floating sparkles
    final sparkPaint = Paint()
      ..color = const Color(
        0xFFD4AF37,
      ).withValues(alpha: 0.5 + 0.3 * math.sin(t * math.pi * 2))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx + 52, cy - 40), 5, sparkPaint);
    canvas.drawCircle(Offset(cx - 52, cy - 35), 4, sparkPaint);
    canvas.drawCircle(Offset(cx + 48, cy + 15), 3, sparkPaint);
  }

  @override
  bool shouldRepaint(covariant _StoreIllustrationPainter old) => old.t != t;
}
