import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';

class BrideToBeScreen extends StatefulWidget {
  const BrideToBeScreen({super.key});

  @override
  State<BrideToBeScreen> createState() => _BrideToBeScreenState();
}

class _BrideToBeScreenState extends State<BrideToBeScreen>
    with TickerProviderStateMixin {
  static const _bg = Color(0xFFFDF8F5);
  static const _textPrimary = Color(0xFF2D1B20);
  static const _textSecondary = Color(0xFF5A3A40);
  static const _accent = Color(0xFFB76E79);
  static const _border = Color(0xFFE8D5D0);

  final _formKey = GlobalKey<FormState>();
  final _nameC = TextEditingController();
  final _phoneC = TextEditingController();
  final _cityC = TextEditingController();
  final _notesC = TextEditingController();

  bool _sending = false;

  // Animation controllers
  late final AnimationController _floatCtrl;
  late final AnimationController _heartCtrl;
  late final AnimationController _petalCtrl;
  late final AnimationController _entryCtrl;
  late final AnimationController _doveCtrl;

  @override
  void initState() {
    super.initState();

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _heartCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _petalCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _doveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _nameC.dispose();
    _phoneC.dispose();
    _cityC.dispose();
    _notesC.dispose();
    _floatCtrl.dispose();
    _heartCtrl.dispose();
    _petalCtrl.dispose();
    _entryCtrl.dispose();
    _doveCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitEnquiry() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (!auth.isLoggedIn || auth.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login first to submit enquiry.')),
      );
      context.push('/login');
      return;
    }

    if (!_formKey.currentState!.validate()) return;
    setState(() => _sending = true);

    try {
      final user = auth.user!;
      final db = FirebaseFirestore.instance;
      final enquiryRef = db.collection('bridal_enquiries').doc();
      final userEnquiryRef = db
          .collection('users')
          .doc(user.uid)
          .collection('bridal_enquiries')
          .doc(enquiryRef.id);
      final payload = {
        'userId': user.uid,
        'userPhone': user.phoneNumber ?? '',
        'userName': auth.profile.name,
        'name': _nameC.text.trim(),
        'phone': _phoneC.text.trim(),
        'city': _cityC.text.trim(),
        'notes': _notesC.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'source': 'Bride To Be Screen',
      };

      final batch = db.batch();
      batch.set(enquiryRef, payload);
      batch.set(userEnquiryRef, payload);
      await batch.commit();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Enquiry submitted! Team JGS will contact you soon. 💕'),
        ),
      );
      _nameC.clear();
      _phoneC.clear();
      _cityC.clear();
      _notesC.clear();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to submit enquiry. Please try again.'),
        ),
      );
    }

    if (mounted) setState(() => _sending = false);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Just now';
    final d = date.toLocal();
    return '${d.day}/${d.month}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final compact = w < 820;
    final auth = context.watch<AuthProvider>();

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
          'Bride To Be',
          style: TextStyle(
            fontFamily: AppTheme.playfairFamily,
            color: _textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: FadeTransition(
        opacity: CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1040),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── HERO with animated wedding characters ──
                  _buildHero(compact),
                  const SizedBox(height: 18),

                  // ── Animated scene banner ──
                  _buildWeddingSceneBanner(compact),
                  const SizedBox(height: 18),

                  // ── Benefit cards ──
                  _buildBenefitRow(w),
                  const SizedBox(height: 20),

                  // ── Enquiry form ──
                  _buildEnquiryForm(auth),
                  const SizedBox(height: 16),

                  // ── Past enquiries ──
                  if (auth.isLoggedIn && auth.user != null)
                    _buildPastEnquiries(auth),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────── HERO ──

  Widget _buildHero(bool compact) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFF0F3),
            Color(0xFFFCE4EA),
            Color(0xFFF7D8E2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: _border.withValues(alpha: 0.75)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE8B4B8).withValues(alpha: 0.22),
            blurRadius: 32,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Falling petals background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _petalCtrl,
              builder: (_, __) => CustomPaint(
                painter: _FallingPetalPainter(_petalCtrl.value),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(compact ? 22 : 32),
            child: compact ? _heroCompact() : _heroWide(),
          ),
        ],
      ),
    );
  }

  Widget _heroCompact() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heroBadge(),
        const SizedBox(height: 14),
        _heroTitle(compact: true),
        const SizedBox(height: 10),
        _heroSubtitle(compact: true),
        const SizedBox(height: 16),
        _heroChips(),
      ],
    );
  }

  Widget _heroWide() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _heroBadge(),
              const SizedBox(height: 14),
              _heroTitle(compact: false),
              const SizedBox(height: 10),
              _heroSubtitle(compact: false),
              const SizedBox(height: 18),
              _heroChips(),
            ],
          ),
        ),
        const SizedBox(width: 24),
        // Animated wedding couple display
        AnimatedBuilder(
          animation: _floatCtrl,
          builder: (_, __) {
            final f = math.sin(_floatCtrl.value * math.pi);
            return Transform.translate(
              offset: Offset(0, -8 * f),
              child: SizedBox(
                width: 200,
                height: 200,
                child: CustomPaint(
                  painter: _WeddingCouplePainter(
                    heartBeat: _heartCtrl.value,
                    doveProgress: _doveCtrl.value,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _heroBadge() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _accent.withValues(alpha: 0.13),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _heartCtrl,
              builder: (_, __) => Transform.scale(
                scale: 0.85 + 0.2 * _heartCtrl.value,
                child: const Icon(Icons.favorite_rounded,
                    color: _accent, size: 13),
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'WEDDING BEAUTY CURATION',
              style: TextStyle(
                color: Color(0xFF8B4A52),
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      );

  Widget _heroTitle({required bool compact}) => Text(
        'Best quality bridal essentials\nat the most affordable price',
        style: TextStyle(
          fontFamily: AppTheme.playfairFamily,
          color: _textPrimary,
          fontSize: compact ? 28 : 42,
          fontWeight: FontWeight.w900,
          height: 1.13,
        ),
      );

  Widget _heroSubtitle({required bool compact}) => Text(
        'From pre-bridal skin prep to wedding day makeup must-haves, our team builds your complete kit based on your budget and skin type.',
        style: TextStyle(
          color: _textSecondary.withValues(alpha: 0.74),
          fontSize: compact ? 13 : 15,
          height: 1.55,
        ),
      );

  Widget _heroChips() => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: const [
          _AssuranceChip('💎 100% Genuine Products'),
          _AssuranceChip('💰 Budget Friendly Bridal Kits'),
          _AssuranceChip('✨ Personalized Recommendations'),
        ],
      );

  // ─────────────────────────────────── ANIMATED WEDDING SCENE BANNER ──

  Widget _buildWeddingSceneBanner(bool compact) {
    return Container(
      width: double.infinity,
      height: compact ? 180 : 220,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF5F7), Color(0xFFF9E8EE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: _border.withValues(alpha: 0.6)),
      ),
      child: AnimatedBuilder(
        animation: Listenable.merge([_floatCtrl, _heartCtrl, _doveCtrl, _petalCtrl]),
        builder: (_, __) => CustomPaint(
          painter: _WeddingScenePainter(
            floatValue: _floatCtrl.value,
            heartValue: _heartCtrl.value,
            doveValue: _doveCtrl.value,
            petalValue: _petalCtrl.value,
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────── BENEFIT CARDS ──

  Widget _buildBenefitRow(double w) {
    final wide = w >= 980;
    final mid = w >= 680;
    return LayoutBuilder(
      builder: (context, box) {
        final cardW = wide
            ? (box.maxWidth - 24) / 3
            : mid
                ? (box.maxWidth - 12) / 2
                : box.maxWidth;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: cardW,
              child: const _BenefitCard(
                icon: Icons.diamond_outlined,
                accentColor: Color(0xFFB76E79),
                title: 'Premium Quality',
                subtitle: 'Only genuine and trusted beauty brands',
              ),
            ),
            SizedBox(
              width: cardW,
              child: const _BenefitCard(
                icon: Icons.currency_rupee_rounded,
                accentColor: Color(0xFFD4AF37),
                title: 'Affordable Bundles',
                subtitle: 'Smart bridal combos tailored to your budget',
              ),
            ),
            SizedBox(
              width: cardW,
              child: const _BenefitCard(
                icon: Icons.spa_outlined,
                accentColor: Color(0xFF9B7EC8),
                title: 'Skin-Type Guided',
                subtitle: 'Product picks based on concern and routine',
              ),
            ),
          ],
        );
      },
    );
  }

  // ─────────────────────────────────────────────── ENQUIRY FORM ──

  Widget _buildEnquiryForm(AuthProvider auth) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border.withValues(alpha: 0.78)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE8B4B8).withValues(alpha: 0.10),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD1D9), Color(0xFFF7B8C0)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.favorite_rounded,
                      color: _accent, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bridal Enquiry',
                        style: TextStyle(
                          fontFamily: AppTheme.playfairFamily,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: _textPrimary,
                        ),
                      ),
                      Text(
                        'Tell us your wedding timeline and budget.',
                        style: TextStyle(
                          color: _textSecondary.withValues(alpha: 0.65),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Field(
              controller: _nameC,
              label: 'Full Name',
              icon: Icons.person_outline_rounded,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Enter your name' : null,
            ),
            const SizedBox(height: 12),
            _Field(
              controller: _phoneC,
              label: 'Phone Number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) => (v == null || v.trim().length != 10)
                  ? 'Enter valid 10-digit number'
                  : null,
            ),
            const SizedBox(height: 12),
            _Field(
              controller: _cityC,
              label: 'City',
              icon: Icons.location_city_outlined,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Enter city' : null,
            ),
            const SizedBox(height: 12),
            _Field(
              controller: _notesC,
              label: 'Requirements (wedding date, budget, skin type…)',
              icon: Icons.notes_rounded,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _sending ? null : _submitEnquiry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _sending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.favorite_border_rounded, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Submit Bridal Enquiry',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
              ),
            ),
            if (!auth.isLoggedIn) ...[
              const SizedBox(height: 10),
              Text(
                '🔒 Login required to submit and track your enquiry.',
                style: TextStyle(
                  color: _textSecondary.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────── PAST ENQUIRIES ──

  Widget _buildPastEnquiries(AuthProvider auth) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border.withValues(alpha: 0.78)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Bridal Enquiries',
            style: TextStyle(
              fontFamily: AppTheme.playfairFamily,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(auth.user!.uid)
                .collection('bridal_enquiries')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: LinearProgressIndicator(minHeight: 2),
                );
              }
              final docs = (snapshot.data?.docs ??
                      <QueryDocumentSnapshot<Map<String, dynamic>>>[])
                  .toList();
              docs.sort((a, b) {
                final aTime =
                    (a.data()['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ??
                        0;
                final bTime =
                    (b.data()['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ??
                        0;
                return bTime.compareTo(aTime);
              });

              if (docs.isEmpty) {
                return Text(
                  'No enquiries yet. Submit above and we will contact you shortly.',
                  style: TextStyle(
                    color: _textSecondary.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                );
              }

              return Column(
                children: docs.take(5).map((d) {
                  final data = d.data();
                  final city = (data['city'] as String? ?? '').trim();
                  final notes = (data['notes'] as String? ?? '').trim();
                  final created =
                      (data['createdAt'] as Timestamp?)?.toDate();
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7F6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: _border.withValues(alpha: 0.7)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.mark_email_read_outlined,
                            color: _accent, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                city.isEmpty ? 'Bridal Enquiry' : 'City: $city',
                                style: const TextStyle(
                                  color: _textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (notes.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  notes,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: _textSecondary.withValues(alpha: 0.75),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Text(
                          _formatDate(created),
                          style: TextStyle(
                            color: _textSecondary.withValues(alpha: 0.65),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  CUSTOM PAINTERS
// ═══════════════════════════════════════════════════════

/// Draws a cute cartoon bride + groom couple with animated heart and dove.
class _WeddingCouplePainter extends CustomPainter {
  final double heartBeat;
  final double doveProgress;
  const _WeddingCouplePainter({
    required this.heartBeat,
    required this.doveProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    _drawGroomAndBride(canvas, cx, cy, size);
    _drawFloatingHeart(canvas, cx, cy - size.height * 0.1);
    _drawDove(canvas, size, doveProgress);
    _drawFlowers(canvas, size);
  }

  void _drawGroomAndBride(
      Canvas canvas, double cx, double cy, Size size) {
    final scale = size.width / 220.0;

    // ── Groom (left) ──
    final groomX = cx - 48 * scale;
    _drawPerson(
      canvas: canvas,
      cx: groomX,
      cy: cy + 10 * scale,
      scale: scale,
      skinColor: const Color(0xFFFDD5A0),
      bodyColor: const Color(0xFF2D3A4A),   // dark suit
      hairColor: const Color(0xFF1A0E0E),
      isGroomSuit: true,
    );

    // ── Bride (right) ──
    final brideX = cx + 48 * scale;
    _drawPerson(
      canvas: canvas,
      cx: brideX,
      cy: cy + 10 * scale,
      scale: scale,
      skinColor: const Color(0xFFFDD5A0),
      bodyColor: const Color(0xFFF8E8EC),   // wedding gown colour
      hairColor: const Color(0xFF3A1A1A),
      isGroomSuit: false,
      isBride: true,
    );

    // ─ Hands joined ─
    final paint = Paint()
      ..color = const Color(0xFFFDD5A0)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
        Offset(cx, cy + 26 * scale), 7 * scale, paint);

    // Wedding rings
    final ringPaint = Paint()
      ..color = const Color(0xFFD4AF37)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 * scale;
    canvas.drawCircle(Offset(cx - 5 * scale, cy + 25 * scale), 4 * scale, ringPaint);
    canvas.drawCircle(Offset(cx + 5 * scale, cy + 25 * scale), 4 * scale, ringPaint);
  }

  void _drawPerson({
    required Canvas canvas,
    required double cx,
    required double cy,
    required double scale,
    required Color skinColor,
    required Color bodyColor,
    required Color hairColor,
    bool isGroomSuit = false,
    bool isBride = false,
  }) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Body / torso
    paint.color = bodyColor;
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, cy + 15 * scale),
        width: isBride ? 36 * scale : 30 * scale,
        height: isBride ? 50 * scale : 42 * scale,
      ),
      Radius.circular(isBride ? 18 * scale : 8 * scale),
    );
    canvas.drawRRect(bodyRect, paint);

    // Bride gown flare
    if (isBride) {
      final gonPath = Path();
      gonPath.moveTo(cx - 18 * scale, cy + 30 * scale);
      gonPath.lineTo(cx - 32 * scale, cy + 60 * scale);
      gonPath.lineTo(cx + 32 * scale, cy + 60 * scale);
      gonPath.lineTo(cx + 18 * scale, cy + 30 * scale);
      gonPath.close();
      paint.color = const Color(0xFFFAEEF2);
      canvas.drawPath(gonPath, paint);
      // Dress detail lines
      final detailPaint = Paint()
        ..color = const Color(0xFFE8D5D0)
        ..strokeWidth = 0.8 * scale
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(cx - 10 * scale, cy + 15 * scale),
          Offset(cx - 24 * scale, cy + 55 * scale), detailPaint);
      canvas.drawLine(Offset(cx + 10 * scale, cy + 15 * scale),
          Offset(cx + 24 * scale, cy + 55 * scale), detailPaint);
    }

    // Groom suit lapel
    if (isGroomSuit) {
      paint.color = Colors.white.withValues(alpha: 0.3);
      final lapel = Path();
      lapel.moveTo(cx - 4 * scale, cy - 5 * scale);
      lapel.lineTo(cx, cy + 10 * scale);
      lapel.lineTo(cx + 4 * scale, cy - 5 * scale);
      canvas.drawPath(lapel, paint);
      // Bow-tie
      paint.color = const Color(0xFFB76E79);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(cx, cy - 2 * scale),
          width: 10 * scale,
          height: 5 * scale,
        ),
        paint,
      );
    }

    // Head
    paint.color = skinColor;
    canvas.drawCircle(Offset(cx, cy - 20 * scale), 18 * scale, paint);

    // Hair
    paint.color = hairColor;
    final hairPath = Path();
    if (isBride) {
      // Bride updo with veil hint
      hairPath.addOval(Rect.fromCenter(
          center: Offset(cx, cy - 26 * scale),
          width: 32 * scale,
          height: 16 * scale));
      canvas.drawPath(hairPath, paint);
      // Veil
      paint.color = Colors.white.withValues(alpha: 0.7);
      final veil = Path()
        ..moveTo(cx - 2 * scale, cy - 34 * scale)
        ..lineTo(cx + 20 * scale, cy - 30 * scale)
        ..lineTo(cx + 15 * scale, cy + 5 * scale)
        ..lineTo(cx - 2 * scale, cy - 15 * scale)
        ..close();
      canvas.drawPath(veil, paint);
      // Tiara
      paint.color = const Color(0xFFD4AF37);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(cx, cy - 35 * scale),
          width: 22 * scale,
          height: 3 * scale,
        ),
        paint,
      );
      canvas.drawCircle(Offset(cx, cy - 37 * scale), 3 * scale, paint);
    } else {
      // Groom side-part hair
      hairPath.addOval(Rect.fromCenter(
          center: Offset(cx, cy - 30 * scale),
          width: 34 * scale,
          height: 12 * scale));
      canvas.drawPath(hairPath, paint);
    }

    // Eyes
    paint.color = const Color(0xFF2D1B20);
    canvas.drawCircle(Offset(cx - 5 * scale, cy - 20 * scale), 2.5 * scale, paint);
    canvas.drawCircle(Offset(cx + 5 * scale, cy - 20 * scale), 2.5 * scale, paint);
    // Eye shines
    paint.color = Colors.white;
    canvas.drawCircle(Offset(cx - 4 * scale, cy - 21 * scale), 1 * scale, paint);
    canvas.drawCircle(Offset(cx + 6 * scale, cy - 21 * scale), 1 * scale, paint);

    // Smile
    final smilePaint = Paint()
      ..color = const Color(0xFFC0606A)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.8 * scale;
    final smilePath = Path();
    smilePath.moveTo(cx - 5 * scale, cy - 12 * scale);
    smilePath.quadraticBezierTo(cx, cy - 8 * scale, cx + 5 * scale, cy - 12 * scale);
    canvas.drawPath(smilePath, smilePaint);

    // Rosy cheeks
    paint.color = const Color(0xFFF4A0A0).withValues(alpha: 0.4);
    canvas.drawCircle(Offset(cx - 10 * scale, cy - 17 * scale), 5 * scale, paint);
    canvas.drawCircle(Offset(cx + 10 * scale, cy - 17 * scale), 5 * scale, paint);
  }

  void _drawFloatingHeart(Canvas canvas, double cx, double cy) {
    final heartScale = 0.9 + 0.15 * heartBeat;
    final paint = Paint()
      ..color = const Color(0xFFE8506A)
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.scale(heartScale, heartScale);
    final path = _heartPath(24);
    canvas.drawPath(path, paint);
    // Heart highlight
    paint.color = Colors.white.withValues(alpha: 0.4);
    canvas.drawCircle(const Offset(-6, -8), 4, paint);
    canvas.restore();
  }

  Path _heartPath(double size) {
    final path = Path();
    path.moveTo(0, size * 0.35);
    path.cubicTo(-size, -size * 0.1, -size * 1.1, size * 0.9, 0, size * 1.3);
    path.cubicTo(size * 1.1, size * 0.9, size, -size * 0.1, 0, size * 0.35);
    path.close();
    return path;
  }

  void _drawDove(Canvas canvas, Size size, double progress) {
    final t = (progress * math.pi * 2);
    final dx = size.width * 0.15 + size.width * 0.7 * progress;
    final dy = size.height * 0.15 + math.sin(t) * size.height * 0.06;
    final wingFlap = math.sin(t * 4) * 0.3;

    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(dx, dy);

    // Body
    final bodyPath = Path()
      ..addOval(Rect.fromCenter(center: Offset.zero, width: 20, height: 12));
    canvas.drawPath(bodyPath, paint);

    // Wing 1 (top)
    paint.color = Colors.white.withValues(alpha: 0.9);
    final wing1 = Path();
    wing1.moveTo(0, 0);
    wing1.quadraticBezierTo(-14, -8 - wingFlap * 10, -4, 6);
    wing1.close();
    canvas.drawPath(wing1, paint);

    // Wing 2 (bottom)
    final wing2 = Path();
    wing2.moveTo(0, 0);
    wing2.quadraticBezierTo(-14, 8 + wingFlap * 10, -4, -6);
    wing2.close();
    canvas.drawPath(wing2, paint);

    // Head
    paint.color = Colors.white;
    canvas.drawCircle(const Offset(10, -3), 6, paint);
    // Eye
    paint.color = const Color(0xFF2D1B20);
    canvas.drawCircle(const Offset(13, -4.5), 1.5, paint);

    canvas.restore();
  }

  void _drawFlowers(Canvas canvas, Size size) {
    final positions = [
      Offset(size.width * 0.08, size.height * 0.85),
      Offset(size.width * 0.92, size.height * 0.80),
      Offset(size.width * 0.15, size.height * 0.10),
      Offset(size.width * 0.85, size.height * 0.12),
    ];
    for (final p in positions) {
      _drawFlower(canvas, p, 12);
    }
  }

  void _drawFlower(Canvas canvas, Offset center, double r) {
    final paint = Paint()..style = PaintingStyle.fill;
    // Petals
    paint.color = const Color(0xFFFFB6C1).withValues(alpha: 0.65);
    for (int i = 0; i < 5; i++) {
      final angle = i * math.pi * 2 / 5;
      canvas.drawCircle(
        Offset(center.dx + r * math.cos(angle), center.dy + r * math.sin(angle)),
        r * 0.55,
        paint,
      );
    }
    // Center
    paint.color = const Color(0xFFFFE44D);
    canvas.drawCircle(center, r * 0.4, paint);
  }

  @override
  bool shouldRepaint(covariant _WeddingCouplePainter old) =>
      old.heartBeat != heartBeat || old.doveProgress != doveProgress;
}

/// Full wedding scene — mandap arch, couple silhouette, hearts, petals, stars.
class _WeddingScenePainter extends CustomPainter {
  final double floatValue;
  final double heartValue;
  final double doveValue;
  final double petalValue;

  const _WeddingScenePainter({
    required this.floatValue,
    required this.heartValue,
    required this.doveValue,
    required this.petalValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height;

    _drawMandapArch(canvas, size);
    _drawCouple(canvas, size);
    _drawScatteredHearts(canvas, size);
    _drawStars(canvas, size);
    _drawGarland(canvas, cx, cy, size);
    _drawGroundFlowers(canvas, size);
  }

  void _drawMandapArch(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4AF37).withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final cx = size.width / 2;

    // Left pillar
    canvas.drawLine(
      Offset(cx - size.width * 0.28, size.height),
      Offset(cx - size.width * 0.28, size.height * 0.12),
      paint,
    );
    // Right pillar
    canvas.drawLine(
      Offset(cx + size.width * 0.28, size.height),
      Offset(cx + size.width * 0.28, size.height * 0.12),
      paint,
    );
    // Arched top
    final archPath = Path();
    archPath.moveTo(cx - size.width * 0.28, size.height * 0.12);
    archPath.quadraticBezierTo(cx, -size.height * 0.08, cx + size.width * 0.28, size.height * 0.12);
    paint.color = const Color(0xFFD4AF37).withValues(alpha: 0.7);
    paint.strokeWidth = 3;
    canvas.drawPath(archPath, paint);

    // Decorative top bulb
    paint.color = const Color(0xFFD4AF37).withValues(alpha: 0.6);
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, size.height * 0.03), 8, paint);

    // Side decorations
    _drawArchDecor(canvas, cx - size.width * 0.28, size.height * 0.12);
    _drawArchDecor(canvas, cx + size.width * 0.28, size.height * 0.12);
  }

  void _drawArchDecor(Canvas canvas, double x, double y) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFD4AF37).withValues(alpha: 0.5);
    canvas.drawCircle(Offset(x, y), 6, paint);
    paint.color = const Color(0xFFFFB6C1).withValues(alpha: 0.7);
    canvas.drawCircle(Offset(x, y + 12), 4, paint);
    canvas.drawCircle(Offset(x, y - 12), 4, paint);
  }

  void _drawCouple(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final baseY = size.height * 0.95;
    final scale = size.height / 220.0;
    final float = math.sin(floatValue * math.pi) * 3 * scale;

    _drawSimpleFigure(canvas, cx - 30 * scale, baseY + float, scale, isGroom: true);
    _drawSimpleFigure(canvas, cx + 30 * scale, baseY + float, scale, isGroom: false);

    // Joined hands
    final handPaint = Paint()
      ..color = const Color(0xFFFDD5A0)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, baseY - 12 * scale + float), 5 * scale, handPaint);
  }

  void _drawSimpleFigure(Canvas canvas, double x, double bottom, double scale, {required bool isGroom}) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Body
    paint.color = isGroom
        ? const Color(0xFF2D3A4A)
        : const Color(0xFFFAEEF2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(x, bottom - 22 * scale),
          width: isGroom ? 22 * scale : 26 * scale,
          height: 30 * scale,
        ),
        Radius.circular(isGroom ? 4 * scale : 13 * scale),
      ),
      paint,
    );

    // Head
    paint.color = const Color(0xFFFDD5A0);
    canvas.drawCircle(Offset(x, bottom - 48 * scale), 13 * scale, paint);

    // Hair
    paint.color = isGroom ? const Color(0xFF1A0E0E) : const Color(0xFF3A1A1A);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(x, bottom - 58 * scale),
        width: isGroom ? 24 * scale : 22 * scale,
        height: isGroom ? 10 * scale : 14 * scale,
      ),
      paint,
    );

    // Bride crown / groom hat accent
    if (!isGroom) {
      paint.color = const Color(0xFFD4AF37);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(x, bottom - 64 * scale),
          width: 16 * scale,
          height: 2 * scale,
        ),
        paint,
      );
    }

    // Eyes
    paint.color = const Color(0xFF2D1B20);
    canvas.drawCircle(Offset(x - 4 * scale, bottom - 48 * scale), 2 * scale, paint);
    canvas.drawCircle(Offset(x + 4 * scale, bottom - 48 * scale), 2 * scale, paint);
  }

  void _drawScatteredHearts(Canvas canvas, Size size) {
    final positions = [
      Offset(size.width * 0.10, size.height * 0.25),
      Offset(size.width * 0.85, size.height * 0.30),
      Offset(size.width * 0.20, size.height * 0.60),
      Offset(size.width * 0.78, size.height * 0.55),
      Offset(size.width * 0.50, size.height * 0.15),
    ];

    final sizes = [14.0, 10.0, 8.0, 12.0, 9.0];
    final opacities = [0.7, 0.55, 0.45, 0.65, 0.5];

    for (int i = 0; i < positions.length; i++) {
      final pulse = math.sin(heartValue * math.pi + i * 0.8);
      final s = sizes[i] * (1 + pulse * 0.12);
      _drawHeart(canvas, positions[i], s, opacities[i]);
    }
  }

  void _drawHeart(Canvas canvas, Offset center, double size, double opacity) {
    final paint = Paint()
      ..color = const Color(0xFFE8506A).withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(size / 24, size / 24);
    final path = Path()
      ..moveTo(0, 8)
      ..cubicTo(-24, -2, -26, 22, 0, 31)
      ..cubicTo(26, 22, 24, -2, 0, 8)
      ..close();
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  void _drawStars(Canvas canvas, Size size) {
    final starPos = [
      Offset(size.width * 0.05, size.height * 0.08),
      Offset(size.width * 0.95, size.height * 0.06),
      Offset(size.width * 0.30, size.height * 0.05),
      Offset(size.width * 0.70, size.height * 0.08),
    ];
    for (final pos in starPos) {
      _drawStar(canvas, pos, 6);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double r) {
    final paint = Paint()
      ..color = const Color(0xFFD4AF37).withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final outer = i * math.pi * 2 / 5 - math.pi / 2;
      final inner = outer + math.pi / 5;
      if (i == 0) {
        path.moveTo(center.dx + r * math.cos(outer), center.dy + r * math.sin(outer));
      } else {
        path.lineTo(center.dx + r * math.cos(outer), center.dy + r * math.sin(outer));
      }
      path.lineTo(center.dx + r * 0.4 * math.cos(inner), center.dy + r * 0.4 * math.sin(inner));
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawGarland(Canvas canvas, double cx, double cy, Size size) {
    final garlandPaint = Paint()
      ..color = const Color(0xFFFFB6C1).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    path.moveTo(cx - size.width * 0.28, size.height * 0.12);
    for (int i = 0; i <= 20; i++) {
      final t = i / 20.0;
      final x = (cx - size.width * 0.28) + (size.width * 0.56) * t;
      final y = size.height * 0.12 + math.sin(t * math.pi * 3) * 10;
      if (i == 0) path.moveTo(x, y);
      else path.lineTo(x, y);
    }
    canvas.drawPath(path, garlandPaint);
  }

  void _drawGroundFlowers(Canvas canvas, Size size) {
    final positions = [
      Offset(size.width * 0.04, size.height * 0.90),
      Offset(size.width * 0.15, size.height * 0.95),
      Offset(size.width * 0.85, size.height * 0.92),
      Offset(size.width * 0.96, size.height * 0.88),
    ];
    for (final p in positions) {
      _drawSmallFlower(canvas, p);
    }
  }

  void _drawSmallFlower(Canvas canvas, Offset center) {
    final paint = Paint()..style = PaintingStyle.fill;
    paint.color = const Color(0xFFFF8FAB).withValues(alpha: 0.6);
    for (int i = 0; i < 4; i++) {
      final angle = i * math.pi / 2;
      canvas.drawCircle(
        Offset(center.dx + 7 * math.cos(angle), center.dy + 7 * math.sin(angle)),
        5,
        paint,
      );
    }
    paint.color = const Color(0xFFFFE44D);
    canvas.drawCircle(center, 4, paint);
  }

  @override
  bool shouldRepaint(covariant _WeddingScenePainter old) =>
      old.floatValue != floatValue ||
      old.heartValue != heartValue ||
      old.doveValue != doveValue ||
      old.petalValue != petalValue;
}

/// Falling cherry blossom petals.
class _FallingPetalPainter extends CustomPainter {
  final double progress;
  static const _kCount = 18;
  static final _rng = math.Random(42);
  static final _seeds = List.generate(
    _kCount,
    (i) => (
      x: _rng.nextDouble(),
      startY: _rng.nextDouble(),
      size: _rng.nextDouble() * 6 + 4.0,
      speed: _rng.nextDouble() * 0.4 + 0.2,
      angle: _rng.nextDouble() * math.pi,
      drift: _rng.nextDouble() * 0.06 - 0.03,
    ),
  );

  const _FallingPetalPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    for (final s in _seeds) {
      final t = (s.startY + progress * s.speed) % 1.0;
      final x = s.x * size.width + math.sin(t * math.pi * 4) * 20;
      final y = t * (size.height + 30) - 15;
      final alpha = (1 - (t - 0.85).clamp(0.0, 0.15) / 0.15) * 0.3;

      paint.color = const Color(0xFFFFB6C1).withValues(alpha: alpha);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(s.angle + progress * math.pi * 2);
      _drawPetal(canvas, paint, s.size.toDouble());
      canvas.restore();
    }
  }

  void _drawPetal(Canvas canvas, Paint paint, double r) {
    final path = Path();
    path.moveTo(0, -r);
    path.quadraticBezierTo(r, 0, 0, r);
    path.quadraticBezierTo(-r, 0, 0, -r);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _FallingPetalPainter old) =>
      old.progress != progress;
}

// ═══════════════════════════════════════════════════════
//  REUSABLE WIDGETS
// ═══════════════════════════════════════════════════════

class _BenefitCard extends StatelessWidget {
  final IconData icon;
  final Color accentColor;
  final String title;
  final String subtitle;

  const _BenefitCard({
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8D5D0).withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF2D1B20),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: const Color(0xFF5A3A40).withValues(alpha: 0.68),
                    fontSize: 12,
                    height: 1.4,
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

class _AssuranceChip extends StatelessWidget {
  final String text;
  const _AssuranceChip(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8D5D0).withValues(alpha: 0.85)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: const Color(0xFF5A3A40).withValues(alpha: 0.86),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: const Color(0xFF5A3A40).withValues(alpha: 0.45)),
        filled: true,
        fillColor: const Color(0xFFFDF8F5),
        labelStyle: TextStyle(
          color: const Color(0xFF5A3A40).withValues(alpha: 0.7),
          fontSize: 13,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: const Color(0xFFE8D5D0).withValues(alpha: 0.85)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFB76E79), width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF6B6B)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 1.4),
        ),
      ),
    );
  }
}
