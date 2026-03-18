import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';

class SalonOwnersScreen extends StatefulWidget {
  const SalonOwnersScreen({super.key});

  @override
  State<SalonOwnersScreen> createState() => _SalonOwnersScreenState();
}

class _SalonOwnersScreenState extends State<SalonOwnersScreen>
    with TickerProviderStateMixin {
  static const _bg = Color(0xFFFDF8F5);
  static const _textPrimary = Color(0xFF2D1B20);
  static const _textSecondary = Color(0xFF5A3A40);
  static const _accent = Color(0xFFB76E79);
  static const _border = Color(0xFFE8D5D0);

  final _formKey = GlobalKey<FormState>();
  final _ownerNameC = TextEditingController();
  final _salonNameC = TextEditingController();
  final _phoneC = TextEditingController();
  final _cityC = TextEditingController();
  final _requirementsC = TextEditingController();

  late final AnimationController _floatCtrl;
  late final AnimationController _entryCtrl;
  late final AnimationController _scissorCtrl;
  late final AnimationController _sparkleCtrl;
  late final AnimationController _chairCtrl;

  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    _scissorCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _sparkleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _chairCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ownerNameC.dispose();
    _salonNameC.dispose();
    _phoneC.dispose();
    _cityC.dispose();
    _requirementsC.dispose();
    _floatCtrl.dispose();
    _entryCtrl.dispose();
    _scissorCtrl.dispose();
    _sparkleCtrl.dispose();
    _chairCtrl.dispose();
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
      final topRef = db.collection('salon_owner_enquiries').doc();
      final userRef = db
          .collection('users')
          .doc(user.uid)
          .collection('salon_owner_enquiries')
          .doc(topRef.id);

      final payload = {
        'userId': user.uid,
        'userPhone': user.phoneNumber ?? '',
        'userName': auth.profile.name,
        'ownerName': _ownerNameC.text.trim(),
        'salonName': _salonNameC.text.trim(),
        'phone': _phoneC.text.trim(),
        'city': _cityC.text.trim(),
        'requirements': _requirementsC.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'source': 'Salon Owners Screen',
      };

      final batch = db.batch();
      batch.set(topRef, payload);
      batch.set(userRef, payload);
      await batch.commit();

      if (!mounted) return;
      _ownerNameC.clear();
      _salonNameC.clear();
      _phoneC.clear();
      _cityC.clear();
      _requirementsC.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enquiry sent! Our salon partner team will contact you. ✂️'),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit enquiry. Try again.')),
      );
    }

    if (mounted) setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final compact = w < 860;

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
          'Salon Owners',
          style: TextStyle(
            fontFamily: AppTheme.playfairFamily,
            color: _textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: FadeTransition(
        opacity: CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 26),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1080),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHero(compact),
                  const SizedBox(height: 18),
                  _buildSalonSceneBanner(compact),
                  const SizedBox(height: 18),
                  if (compact)
                    Column(
                      children: [
                        _buildFeatureRow(),
                        const SizedBox(height: 16),
                        _buildFormCard(),
                      ],
                    )
                  else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: _buildFeatureRow()),
                        const SizedBox(width: 16),
                        Expanded(flex: 2, child: _buildFormCard()),
                      ],
                    ),
                  const SizedBox(height: 16),
                  _buildMyEnquiries(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────── HERO ──

  Widget _buildHero(bool compact) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF5F5), Color(0xFFFBE9EC), Color(0xFFF7DEE5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: _border.withValues(alpha: 0.75)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE8B4B8).withValues(alpha: 0.17),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Floating sparkle background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _sparkleCtrl,
              builder: (_, __) => CustomPaint(
                painter: _SparkleBackgroundPainter(_sparkleCtrl.value),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(compact ? 22 : 30),
            child: compact ? _heroCompact() : _heroWide(),
          ),
        ],
      ),
    );
  }

  Widget _heroCompact() => Column(
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

  Widget _heroWide() => Row(
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
          // Animated salon character
          AnimatedBuilder(
            animation: Listenable.merge([_floatCtrl, _scissorCtrl]),
            builder: (_, __) {
              final f = math.sin(_floatCtrl.value * math.pi);
              return Transform.translate(
                offset: Offset(0, -6 * f),
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: CustomPaint(
                    painter: _SalonCharacterPainter(
                      scissorAngle: _scissorCtrl.value,
                      sparkleValue: _sparkleCtrl.value,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      );

  Widget _heroBadge() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _scissorCtrl,
              builder: (_, __) => Transform.rotate(
                angle: (_scissorCtrl.value - 0.5) * 0.4,
                child: const Icon(Icons.content_cut_rounded, color: _accent, size: 13),
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'SALON PARTNER PROGRAM',
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
        'Grow your salon with\npremium products, bulk pricing\nand partner support',
        style: TextStyle(
          fontFamily: AppTheme.playfairFamily,
          color: _textPrimary,
          fontSize: compact ? 28 : 40,
          fontWeight: FontWeight.w900,
          height: 1.1,
        ),
      );

  Widget _heroSubtitle({required bool compact}) => Text(
        'Get curated product bundles, staff training support, and priority dispatch for your salon business.',
        style: TextStyle(
          color: _textSecondary.withValues(alpha: 0.74),
          fontSize: compact ? 13 : 15,
          height: 1.55,
        ),
      );

  Widget _heroChips() => Wrap(
        spacing: 10,
        runSpacing: 10,
        children: const [
          _TickChip('✂️ Bulk Discount Tiers'),
          _TickChip('🚚 Fast Restock Support'),
          _TickChip('📚 Brand Training Assets'),
        ],
      );

  // ─────────────────────────────────── ANIMATED SALON SCENE BANNER ──

  Widget _buildSalonSceneBanner(bool compact) {
    return Container(
      width: double.infinity,
      height: compact ? 180 : 220,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF0F5), Color(0xFFF5E0E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: _border.withValues(alpha: 0.6)),
      ),
      child: AnimatedBuilder(
        animation: Listenable.merge(
            [_floatCtrl, _scissorCtrl, _sparkleCtrl, _chairCtrl]),
        builder: (_, __) => CustomPaint(
          painter: _SalonScenePainter(
            floatValue: _floatCtrl.value,
            scissorValue: _scissorCtrl.value,
            sparkleValue: _sparkleCtrl.value,
            chairValue: _chairCtrl.value,
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────── FEATURE CARDS ──

  Widget _buildFeatureRow() {
    return AnimatedBuilder(
      animation: _floatCtrl,
      builder: (context, _) {
        final wave = math.sin(_floatCtrl.value * math.pi * 2);
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _FeatureCard(
              icon: Icons.storefront_rounded,
              iconColor: const Color(0xFFB76E79),
              title: 'Wholesale Rates',
              subtitle: 'Special salon slabs and repeat-order offers.',
              shift: wave * 5,
            ),
            _FeatureCard(
              icon: Icons.local_shipping_outlined,
              iconColor: const Color(0xFF6B9EFF),
              title: 'Priority Delivery',
              subtitle: 'Quick dispatch for urgent client demand.',
              shift: -wave * 4,
            ),
            _FeatureCard(
              icon: Icons.support_agent_rounded,
              iconColor: const Color(0xFF9B7EC8),
              title: 'Dedicated Manager',
              subtitle: 'One contact for inventory and support.',
              shift: wave * 6,
            ),
            _FeatureCard(
              icon: Icons.workspace_premium_outlined,
              iconColor: const Color(0xFFD4AF37),
              title: 'Staff Training',
              subtitle: 'Upskill with brand techniques and product demos.',
              shift: -wave * 3,
            ),
          ],
        );
      },
    );
  }

  // ─────────────────────────────────────────────────── FORM CARD ──

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border.withValues(alpha: 0.78)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE8B4B8).withValues(alpha: 0.08),
            blurRadius: 20,
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
                    color: _accent.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AnimatedBuilder(
                    animation: _scissorCtrl,
                    builder: (_, __) => Transform.rotate(
                      angle: (_scissorCtrl.value - 0.5) * 0.5,
                      child: const Icon(Icons.content_cut_rounded,
                          color: _accent, size: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Salon Enquiry',
                        style: TextStyle(
                          fontFamily: AppTheme.playfairFamily,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: _textPrimary,
                        ),
                      ),
                      Text(
                        'Share your details for a partner package.',
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
            _SField(controller: _ownerNameC, label: 'Owner Name',
                icon: Icons.person_outline_rounded,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter owner name' : null),
            const SizedBox(height: 10),
            _SField(controller: _salonNameC, label: 'Salon Name',
                icon: Icons.storefront_outlined,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter salon name' : null),
            const SizedBox(height: 10),
            _SField(
              controller: _phoneC,
              label: 'Phone Number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) => (v == null || v.trim().length != 10)
                  ? 'Enter valid 10-digit number'
                  : null,
            ),
            const SizedBox(height: 10),
            _SField(controller: _cityC, label: 'City',
                icon: Icons.location_city_outlined,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter city' : null),
            const SizedBox(height: 10),
            _SField(
              controller: _requirementsC,
              label: 'Requirements (brands, volume, budget)',
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
                      borderRadius: BorderRadius.circular(14)),
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
                          Icon(Icons.handshake_outlined, size: 18),
                          SizedBox(width: 8),
                          Text('Enquiry Now',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w800)),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────── MY ENQUIRIES ──

  Widget _buildMyEnquiries() {
    final auth = context.watch<AuthProvider>();

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
            'Your Salon Enquiries',
            style: TextStyle(
              fontFamily: AppTheme.playfairFamily,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Track your recently submitted salon partnership requests.',
            style: TextStyle(
              color: _textSecondary.withValues(alpha: 0.68),
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          if (!auth.isLoggedIn || auth.user == null)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBF9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFFE8D5D0).withValues(alpha: 0.75)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_outline_rounded,
                      size: 18, color: Color(0xFF8B4A52)),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Login to view your salon enquiry history.',
                      style: TextStyle(
                          color: Color(0xFF5A3A40),
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/login'),
                    child: const Text('Login'),
                  ),
                ],
              ),
            )
          else
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(auth.user!.uid)
                  .collection('salon_owner_enquiries')
                  .orderBy('createdAt', descending: true)
                  .limit(10)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF5F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Could not load enquiry history. Please try again.',
                      style: TextStyle(
                          color: Color(0xFF8B4A52), fontWeight: FontWeight.w600),
                    ),
                  );
                }

                final docs = snapshot.data?.docs ?? const [];
                if (docs.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBF9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: const Color(0xFFE8D5D0).withValues(alpha: 0.75)),
                    ),
                    child: const Text(
                      'No enquiries yet. Submit the form above to get started.',
                      style: TextStyle(
                          color: Color(0xFF5A3A40),
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                  );
                }

                return Column(
                  children: docs
                      .map((d) => _buildEnquiryTile(d.data()))
                      .toList(growable: false),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEnquiryTile(Map<String, dynamic> data) {
    final salonName = (data['salonName'] as String?)?.trim();
    final city = (data['city'] as String?)?.trim();
    final status = (data['status'] as String?)?.trim();
    final createdAt = data['createdAt'];
    DateTime? dt;
    if (createdAt is Timestamp) dt = createdAt.toDate();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8D5D0).withValues(alpha: 0.75)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFB76E79).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.assignment_turned_in_outlined,
                size: 18, color: Color(0xFF8B4A52)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (salonName == null || salonName.isEmpty)
                      ? 'Salon Enquiry'
                      : salonName,
                  style: const TextStyle(
                      color: Color(0xFF2D1B20),
                      fontWeight: FontWeight.w800,
                      fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  '${city == null || city.isEmpty ? 'City not specified' : city} • ${dt == null ? 'Just now' : _formatDate(dt)}',
                  style: TextStyle(
                      color: const Color(0xFF5A3A40).withValues(alpha: 0.72),
                      fontSize: 12),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF7EE),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    (status == null || status.isEmpty) ? 'Received' : status,
                    style: const TextStyle(
                        color: Color(0xFF2F7A47),
                        fontSize: 11,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final d = date.toLocal();
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    final yy = d.year.toString();
    final hh = d.hour.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    return '$dd/$mm/$yy • $hh:$min';
  }
}

// ═══════════════════════════════════════════════════════
//  CUSTOM PAINTERS — SALON
// ═══════════════════════════════════════════════════════

/// Draws an animated salon stylist character with scissors,
/// a client in a chair, and product bottles.
class _SalonCharacterPainter extends CustomPainter {
  final double scissorAngle;
  final double sparkleValue;

  const _SalonCharacterPainter({
    required this.scissorAngle,
    required this.sparkleValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final scale = size.width / 200.0;

    _drawStylingSalon(canvas, cx, cy, scale);
    _drawScissors(canvas, cx + 50 * scale, cy - 30 * scale, scale);
    _drawProductBottles(canvas, cx - 70 * scale, cy + 20 * scale, scale);
    _drawSparkles(canvas, size);
  }

  void _drawStylingSalon(Canvas canvas, double cx, double cy, double scale) {
    final paint = Paint()..style = PaintingStyle.fill;

    // ── Salon chair base ──
    paint.color = const Color(0xFF8B4A52).withValues(alpha: 0.7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx - 28 * scale, cy + 55 * scale), width: 40 * scale, height: 8 * scale),
        const Radius.circular(4),
      ),
      paint,
    );
    // Chair pole
    paint.color = const Color(0xFF2D3A4A);
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx - 28 * scale, cy + 40 * scale), width: 6 * scale, height: 28 * scale),
      paint,
    );
    // Chair seat
    paint.color = const Color(0xFFE8506A);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx - 28 * scale, cy + 18 * scale), width: 44 * scale, height: 14 * scale),
        Radius.circular(6 * scale),
      ),
      paint,
    );
    // Chair back
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx - 44 * scale, cy - 2 * scale), width: 8 * scale, height: 28 * scale),
        Radius.circular(4 * scale),
      ),
      paint,
    );

    // ── Client in chair ──
    _drawPerson(canvas, cx - 28 * scale, cy - 14 * scale, scale,
        skinColor: const Color(0xFFFDD5A0),
        hairColor: const Color(0xFF3A1A1A),
        bodyColor: const Color(0xFFE8D5D0)); // styling cape

    // ── Stylist standing ──
    _drawPerson(canvas, cx + 20 * scale, cy - 20 * scale, scale,
        skinColor: const Color(0xFFF4C89A),
        hairColor: const Color(0xFF2D1B20),
        bodyColor: const Color(0xFF2D3A4A)); // dark uniform
  }

  void _drawPerson(Canvas canvas, double cx, double cy, double scale,
      {required Color skinColor,
      required Color hairColor,
      required Color bodyColor}) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Body
    paint.color = bodyColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy + 14 * scale), width: 24 * scale, height: 32 * scale),
        Radius.circular(8 * scale),
      ),
      paint,
    );

    // Head
    paint.color = skinColor;
    canvas.drawCircle(Offset(cx, cy - 4 * scale), 14 * scale, paint);

    // Hair
    paint.color = hairColor;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy - 13 * scale), width: 26 * scale, height: 10 * scale),
      paint,
    );

    // Eyes
    paint.color = const Color(0xFF2D1B20);
    canvas.drawCircle(Offset(cx - 4 * scale, cy - 5 * scale), 1.8 * scale, paint);
    canvas.drawCircle(Offset(cx + 4 * scale, cy - 5 * scale), 1.8 * scale, paint);

    // Smile
    final smilePaint = Paint()
      ..color = const Color(0xFFC0606A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 * scale
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(cx - 4 * scale, cy + 2 * scale)
      ..quadraticBezierTo(cx, cy + 6 * scale, cx + 4 * scale, cy + 2 * scale);
    canvas.drawPath(path, smilePaint);

    // Cheeks
    paint.color = const Color(0xFFF4A0A0).withValues(alpha: 0.35);
    canvas.drawCircle(Offset(cx - 8 * scale, cy - 2 * scale), 4 * scale, paint);
    canvas.drawCircle(Offset(cx + 8 * scale, cy - 2 * scale), 4 * scale, paint);
  }

  void _drawScissors(Canvas canvas, double x, double y, double scale) {
    final openAngle = (scissorAngle - 0.5) * 0.6;
    final paint = Paint()
      ..color = const Color(0xFF8B8B8B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 * scale
      ..strokeCap = StrokeCap.round;

    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(math.pi / 4);

    // Blade 1
    canvas.save();
    canvas.rotate(-openAngle);
    canvas.drawLine(Offset(0, 0), Offset(0, -24 * scale), paint);
    canvas.restore();

    // Blade 2
    canvas.save();
    canvas.rotate(openAngle);
    canvas.drawLine(Offset(0, 0), Offset(0, -24 * scale), paint);
    canvas.restore();

    // Handle rings
    paint.style = PaintingStyle.stroke;
    paint.color = const Color(0xFF7A7A7A);
    canvas.save();
    canvas.rotate(-openAngle);
    canvas.drawCircle(Offset(0, -30 * scale), 6 * scale, paint);
    canvas.restore();
    canvas.save();
    canvas.rotate(openAngle);
    canvas.drawCircle(Offset(0, -30 * scale), 6 * scale, paint);
    canvas.restore();

    canvas.restore();
  }

  void _drawProductBottles(Canvas canvas, double x, double y, double scale) {
    final bottleColors = [
      const Color(0xFFFFB6C1),
      const Color(0xFFB0D4FF),
      const Color(0xFFB5EAD7),
    ];
    for (int i = 0; i < 3; i++) {
      final bx = x + i * 16 * scale;
      _drawBottle(canvas, bx, y, scale, bottleColors[i]);
    }
  }

  void _drawBottle(Canvas canvas, double cx, double cy, double scale, Color color) {
    final paint = Paint()..style = PaintingStyle.fill;
    // Body
    paint.color = color.withValues(alpha: 0.8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy + 6 * scale), width: 12 * scale, height: 22 * scale),
        Radius.circular(4 * scale),
      ),
      paint,
    );
    // Cap
    paint.color = Colors.white.withValues(alpha: 0.8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy - 7 * scale), width: 8 * scale, height: 6 * scale),
        Radius.circular(2 * scale),
      ),
      paint,
    );
    // Shine
    paint.color = Colors.white.withValues(alpha: 0.35);
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx - 2 * scale, cy + 3 * scale), width: 3 * scale, height: 10 * scale),
      paint,
    );
  }

  void _drawSparkles(Canvas canvas, Size size) {
    final sparklePositions = [
      Offset(size.width * 0.85, size.height * 0.10),
      Offset(size.width * 0.10, size.height * 0.20),
      Offset(size.width * 0.80, size.height * 0.80),
    ];
    for (final pos in sparklePositions) {
      final alpha = 0.4 + 0.4 * math.sin(sparkleValue * math.pi * 2);
      _drawStar(canvas, pos, 8,
          const Color(0xFFD4AF37).withValues(alpha: alpha));
    }
  }

  void _drawStar(Canvas canvas, Offset center, double r, Color color) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final path = Path();
    for (int i = 0; i < 4; i++) {
      final angle = i * math.pi / 2 - math.pi / 4;
      final inner = angle + math.pi / 4;
      if (i == 0) {
        path.moveTo(
            center.dx + r * math.cos(angle), center.dy + r * math.sin(angle));
      } else {
        path.lineTo(
            center.dx + r * math.cos(angle), center.dy + r * math.sin(angle));
      }
      path.lineTo(
          center.dx + r * 0.35 * math.cos(inner),
          center.dy + r * 0.35 * math.sin(inner));
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SalonCharacterPainter old) =>
      old.scissorAngle != scissorAngle || old.sparkleValue != sparkleValue;
}

/// Full salon scene — 3 stylist characters, multi-chair setup, product shelf,
/// floating scissors, sparkles.
class _SalonScenePainter extends CustomPainter {
  final double floatValue;
  final double scissorValue;
  final double sparkleValue;
  final double chairValue;

  const _SalonScenePainter({
    required this.floatValue,
    required this.scissorValue,
    required this.sparkleValue,
    required this.chairValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawProductShelf(canvas, size);
    _drawSalonStations(canvas, size);
    _drawFloatingScissors(canvas, size);
    _drawSparkles(canvas, size);
    _drawMirrorReflections(canvas, size);
  }

  void _drawBackground(Canvas canvas, Size size) {
    // Floor line
    final paint = Paint()
      ..color = const Color(0xFFE8D5D0).withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(
        Offset(0, size.height * 0.80), Offset(size.width, size.height * 0.80), paint);

    // Checkered floor tiles pattern
    paint.style = PaintingStyle.fill;
    for (int col = 0; col < 8; col++) {
      if (col % 2 == 0) {
        paint.color = const Color(0xFFFFEFF2).withValues(alpha: 0.5);
        canvas.drawRect(
          Rect.fromLTWH(
            col * size.width / 8,
            size.height * 0.80,
            size.width / 8,
            size.height * 0.20,
          ),
          paint,
        );
      }
    }
  }

  void _drawProductShelf(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Shelf board
    paint.color = const Color(0xFFD4906A).withValues(alpha: 0.45);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.02, size.height * 0.12, size.width * 0.14, 6),
        const Radius.circular(3),
      ),
      paint,
    );

    // Bottles on shelf
    final colors = [
      const Color(0xFFFFB6C1),
      const Color(0xFFB0D4FF),
      const Color(0xFFB5EAD7),
      const Color(0xFFFFC8A2),
    ];
    for (int i = 0; i < 4; i++) {
      final bx = size.width * 0.04 + i * size.width * 0.035;
      final by = size.height * 0.04;
      paint.color = colors[i].withValues(alpha: 0.75);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(bx, by, 10, 20),
          const Radius.circular(3),
        ),
        paint,
      );
      // Cap
      paint.color = Colors.white.withValues(alpha: 0.7);
      canvas.drawRect(Rect.fromLTWH(bx + 2, by - 5, 6, 5), paint);
    }
  }

  void _drawSalonStations(Canvas canvas, Size size) {
    final float = math.sin(floatValue * math.pi);

    // 3 salon stations
    final stationXPositions = [
      size.width * 0.22,
      size.width * 0.50,
      size.width * 0.78,
    ];
    final clientHairColors = [
      const Color(0xFF3A1A1A),
      const Color(0xFF2D1B20),
      const Color(0xFF7A4A20),
    ];

    for (int i = 0; i < 3; i++) {
      final sx = stationXPositions[i];
      final stationFloat = float * (i == 1 ? -3 : 3) * (i == 2 ? -1 : 1);

      // Mirror
      _drawMirror(canvas, sx, size.height * 0.08);

      // Chair
      _drawChair(canvas, sx, size.height * 0.70 + stationFloat);

      // Client silhouette
      _drawClientSilhouette(canvas, sx, size.height * 0.62 + stationFloat, clientHairColors[i]);

      // Stylist
      _drawStylistSilhouette(canvas, sx + 22, size.height * 0.65 + stationFloat);
    }
  }

  void _drawMirror(Canvas canvas, double cx, double top) {
    final paint = Paint()..style = PaintingStyle.stroke;

    paint.color = const Color(0xFFD4AF37).withValues(alpha: 0.5);
    paint.strokeWidth = 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, top + 30), width: 40, height: 55),
        const Radius.circular(4),
      ),
      paint,
    );
    // Mirror glass
    paint.color = const Color(0xFFB0D4FF).withValues(alpha: 0.18);
    paint.style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, top + 30), width: 36, height: 51),
        const Radius.circular(3),
      ),
      paint,
    );
  }

  void _drawChair(Canvas canvas, double cx, double cy) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Base
    paint.color = const Color(0xFF8B4A52).withValues(alpha: 0.55);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy + 20), width: 32, height: 6),
        const Radius.circular(3),
      ),
      paint,
    );
    // Pole
    paint.color = const Color(0xFF2D3A4A).withValues(alpha: 0.6);
    canvas.drawRect(
        Rect.fromCenter(center: Offset(cx, cy + 12), width: 4, height: 18), paint);
    // Seat
    paint.color = const Color(0xFFE8506A).withValues(alpha: 0.6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy + 2), width: 34, height: 10),
        const Radius.circular(4),
      ),
      paint,
    );
    // Backrest
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx - 16, cy - 8), width: 6, height: 22),
        const Radius.circular(3),
      ),
      paint,
    );
  }

  void _drawClientSilhouette(Canvas canvas, double cx, double cy, Color hairColor) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Body (cape)
    paint.color = const Color(0xFFE8D5D0).withValues(alpha: 0.65);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy + 8), width: 26, height: 22),
        const Radius.circular(8),
      ),
      paint,
    );
    // Head
    paint.color = const Color(0xFFFDD5A0).withValues(alpha: 0.85);
    canvas.drawCircle(Offset(cx, cy - 6), 11, paint);
    // Hair
    paint.color = hairColor.withValues(alpha: 0.65);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy - 13), width: 20, height: 8), paint);
  }

  void _drawStylistSilhouette(Canvas canvas, double cx, double cy) {
    final paint = Paint()..style = PaintingStyle.fill;

    paint.color = const Color(0xFF2D3A4A).withValues(alpha: 0.55);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy + 10), width: 20, height: 28),
        const Radius.circular(6),
      ),
      paint,
    );
    paint.color = const Color(0xFFFDD5A0).withValues(alpha: 0.8);
    canvas.drawCircle(Offset(cx, cy - 4), 10, paint);
    paint.color = const Color(0xFF2D1B20).withValues(alpha: 0.6);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy - 11), width: 19, height: 7), paint);
  }

  void _drawFloatingScissors(Canvas canvas, Size size) {
    final openA = (scissorValue - 0.5) * 0.7;

    final positions = [
      Offset(size.width * 0.08, size.height * 0.30),
      Offset(size.width * 0.92, size.height * 0.25),
    ];

    for (final pos in positions) {
      _drawScissorPair(canvas, pos, openA, 16);
    }
  }

  void _drawScissorPair(Canvas canvas, Offset center, double openAngle, double size) {
    final paint = Paint()
      ..color = const Color(0xFF8B8B8B).withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(math.pi / 6);

    canvas.save();
    canvas.rotate(-openAngle);
    canvas.drawLine(Offset.zero, Offset(0, -size), paint);
    canvas.drawCircle(Offset(0, -size - 5), 5, paint..style = PaintingStyle.stroke);
    canvas.restore();

    canvas.save();
    canvas.rotate(openAngle);
    canvas.drawLine(Offset.zero, Offset(0, -size), paint..style = PaintingStyle.stroke);
    canvas.drawCircle(Offset(0, -size - 5), 5, paint);
    canvas.restore();

    canvas.restore();
  }

  void _drawSparkles(Canvas canvas, Size size) {
    final sparklePositions = [
      Offset(size.width * 0.35, size.height * 0.08),
      Offset(size.width * 0.65, size.height * 0.10),
      Offset(size.width * 0.15, size.height * 0.55),
      Offset(size.width * 0.85, size.height * 0.50),
    ];

    for (int i = 0; i < sparklePositions.length; i++) {
      final alpha = 0.3 + 0.4 * math.sin(sparkleValue * math.pi * 2 + i);
      final paint = Paint()
        ..color = const Color(0xFFD4AF37).withValues(alpha: alpha)
        ..style = PaintingStyle.fill;

      _drawFourStar(canvas, sparklePositions[i], 7, paint);
    }
  }

  void _drawFourStar(Canvas canvas, Offset center, double r, Paint paint) {
    final path = Path();
    for (int i = 0; i < 4; i++) {
      final a = i * math.pi / 2 - math.pi / 4;
      final b = a + math.pi / 4;
      if (i == 0) {
        path.moveTo(center.dx + r * math.cos(a), center.dy + r * math.sin(a));
      } else {
        path.lineTo(center.dx + r * math.cos(a), center.dy + r * math.sin(a));
      }
      path.lineTo(center.dx + r * 0.3 * math.cos(b), center.dy + r * 0.3 * math.sin(b));
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawMirrorReflections(Canvas canvas, Size size) {
    // Subtle horizontal line to simulate vanity counter
    final paint = Paint()
      ..color = const Color(0xFFD4906A).withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, size.height * 0.78, size.width, 4),
        const Radius.circular(2),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _SalonScenePainter old) =>
      old.floatValue != floatValue ||
      old.scissorValue != scissorValue ||
      old.sparkleValue != sparkleValue ||
      old.chairValue != chairValue;
}

/// Sparkling floating background dots.
class _SparkleBackgroundPainter extends CustomPainter {
  final double progress;
  static const _count = 14;
  static final _rng = math.Random(99);
  static final _seeds = List.generate(
    _count,
    (i) => (
      x: _rng.nextDouble(),
      y: _rng.nextDouble(),
      size: _rng.nextDouble() * 4 + 2.0,
      phase: _rng.nextDouble() * math.pi * 2,
    ),
  );

  const _SparkleBackgroundPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final s in _seeds) {
      final alpha = 0.12 + 0.1 * math.sin(progress * math.pi * 2 + s.phase);
      paint.color = const Color(0xFFD4AF37).withValues(alpha: alpha);
      canvas.drawCircle(
          Offset(s.x * size.width, s.y * size.height), s.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparkleBackgroundPainter old) =>
      old.progress != progress;
}

// ═══════════════════════════════════════════════════════
//  REUSABLE WIDGETS
// ═══════════════════════════════════════════════════════

class _TickChip extends StatelessWidget {
  final String text;
  const _TickChip(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE8D5D0)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF5A3A40),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final double shift;

  const _FeatureCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.shift,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, shift),
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8D5D0).withValues(alpha: 0.75)),
          boxShadow: [
            BoxShadow(
              color: iconColor.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF2D1B20),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: const Color(0xFF5A3A40).withValues(alpha: 0.7),
                      fontSize: 11,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const _SField({
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
        prefixIcon: Icon(icon, size: 18,
            color: const Color(0xFF5A3A40).withValues(alpha: 0.45)),
        filled: true,
        fillColor: const Color(0xFFFDF8F5),
        labelStyle: TextStyle(
          color: const Color(0xFF5A3A40).withValues(alpha: 0.7),
          fontSize: 13,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: const Color(0xFFE8D5D0).withValues(alpha: 0.85)),
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
