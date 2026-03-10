import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/logo_assets.dart';
import '../../../shared/models/product_model.dart';
import '../../../shared/widgets/product_card.dart';
import '../../cart/providers/cart_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HOME SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // ── Animation controllers ──────────────────────────────────────────────
  late final AnimationController _introController;
  late final AnimationController _floatController;
  late final AnimationController _shineController;

  final ScrollController _scrollController = ScrollController();

  bool _isScrolled = false;
  int _selectedCategory = 0;

  // ── Lifecycle ──────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..forward();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat(reverse: true);

    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final scrolled =
        _scrollController.hasClients && _scrollController.offset > 10;
    if (scrolled != _isScrolled) setState(() => _isScrolled = scrolled);
  }

  @override
  void dispose() {
    _introController.dispose();
    _floatController.dispose();
    _shineController.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  // ── Staggered entrance animation helper ────────────────────────────────

  Widget _animatedSection({required int order, required Widget child}) {
    final start = (order * 0.07).clamp(0.0, 0.75).toDouble();
    final end = math.min(start + 0.28, 1.0);
    final anim = CurvedAnimation(
      parent: _introController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return AnimatedBuilder(
      animation: anim,
      builder: (context, _) => Opacity(
        opacity: anim.value,
        child: Transform.translate(
          offset: Offset(0, (1 - anim.value) * 26),
          child: child,
        ),
      ),
    );
  }

  // ── Cart shortcut ──────────────────────────────────────────────────────

  void _addToCart(CatalogProduct p) {
    Provider.of<CartProvider>(
      context,
      listen: false,
    ).addItem(p.id, p.name, p.price, '');
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 3),
          content: Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: AppTheme.accentColor,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${p.name} added to cart',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF2D1B20),
          action: SnackBarAction(
            label: 'VIEW CART',
            textColor: AppTheme.accentColor,
            onPressed: () => context.push('/cart'),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  BUILD
  // ═════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.sizeOf(context).width;
    final contentW = math.min(screenW, 1240.0);

    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F5),
      body: Stack(
        children: [
          const Positioned.fill(
            child: IgnorePointer(
              child: RepaintBoundary(child: _BeamBackground()),
            ),
          ),
          Column(
            children: [
              _buildStickyNavBar(context),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: contentW),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _animatedSection(
                                order: 0,
                                child: _buildPromoStrip(context),
                              ),
                              _animatedSection(
                                order: 1,
                                child: _buildHeroSection(context),
                              ),
                              _animatedSection(
                                order: 2,
                                child: _buildTrustMetrics(context),
                              ),
                              _animatedSection(
                                order: 3,
                                child: _buildFeaturedBrands(context),
                              ),
                              _animatedSection(
                                order: 4,
                                child: _buildCategorySection(context),
                              ),
                              _animatedSection(
                                order: 5,
                                child: _buildBestsellers(context),
                              ),
                              _animatedSection(
                                order: 6,
                                child: _buildShopByConcern(context),
                              ),
                              _animatedSection(
                                order: 7,
                                child: _buildNewArrivals(context),
                              ),
                              _animatedSection(
                                order: 8,
                                child: _buildBrandBanner(context),
                              ),
                              _animatedSection(
                                order: 9,
                                child: _buildPopularProducts(context),
                              ),
                              _animatedSection(
                                order: 10,
                                child: _buildCustomerReviews(context),
                              ),
                              _animatedSection(
                                order: 11,
                                child: _buildMembershipSection(context),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                      _buildFooter(context, contentW),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  1. STICKY NAV BAR
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildStickyNavBar(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final compact = w < 760;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 10,
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        color: const Color(
          0xFFFDF8F5,
        ).withValues(alpha: _isScrolled ? 0.98 : 0.92),
        border: Border(
          bottom: BorderSide(
            color: const Color(
              0xFFE8D5D0,
            ).withValues(alpha: _isScrolled ? 0.50 : 0.0),
          ),
        ),
        boxShadow: _isScrolled
            ? [
                BoxShadow(
                  color: const Color(0xFFE8B4B8).withValues(alpha: 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Row(
            children: [
              SizedBox(
                width: compact ? 96 : null,
                child: Image.asset(
                  'assets/jgs.png',
                  height: compact ? 60 : 40,
                  fit: BoxFit.contain,
                ),
              ),
              if (!compact) ...[
                const SizedBox(width: 22),
                Text(
                  'BEAUTY & CARE',
                  style: TextStyle(
                    color: const Color(0xFF8B6B70).withValues(alpha: 0.65),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                  ),
                ),
              ],
              const Spacer(),
              if (compact)
                _NavActionButton(
                  icon: Icons.search_rounded,
                  label: 'Search',
                  compact: true,
                  onTap: () {},
                ),
              if (compact) const SizedBox(width: 6),
              if (!compact || w >= 430)
                _NavActionButton(
                  icon: Icons.track_changes_outlined,
                  label: 'Orders',
                  compact: compact,
                  onTap: () => context.push('/orders'),
                ),
              if (!compact || w >= 430) const SizedBox(width: 6),
              _NavActionButton(
                icon: Icons.person_outline_rounded,
                label: 'Login',
                compact: compact,
                onTap: () => context.push('/login'),
              ),
              const SizedBox(width: 6),
              Consumer<CartProvider>(
                builder: (context, cart, _) {
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _NavActionButton(
                        icon: Icons.shopping_bag_outlined,
                        label: 'Cart',
                        compact: compact,
                        onTap: () => context.push('/cart'),
                      ),
                      if (cart.itemCount > 0)
                        Positioned(
                          right: -2,
                          top: -4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.accentColor,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.accentColor.withValues(
                                    alpha: 0.5,
                                  ),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              '${cart.itemCount}',
                              style: const TextStyle(
                                color: Color(0xFF1A0E1E),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              if (!compact || w >= 360) ...[
                const SizedBox(width: 6),
                _NavActionButton(
                  icon: Icons.campaign_outlined,
                  label: 'New',
                  compact: compact,
                  onTap: () => context.push('/announcements'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  2. PROMO STRIP
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildPromoStrip(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 720;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 46,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFB76E79).withValues(alpha: 0.25),
                      const Color(0xFFE8B4B8).withValues(alpha: 0.18),
                      const Color(0xFFB76E79).withValues(alpha: 0.25),
                    ],
                  ),
                  border: Border.all(
                    color: const Color(0xFFE8D5D0).withValues(alpha: 0.50),
                  ),
                ),
              ),
              LayoutBuilder(
                builder: (context, box) {
                  return AnimatedBuilder(
                    animation: _shineController,
                    builder: (context, _) {
                      final x =
                          -120 + (box.maxWidth + 240) * _shineController.value;
                      return Transform.translate(
                        offset: Offset(x, -14),
                        child: Transform.rotate(
                          angle: -0.32,
                          child: Container(
                            width: 120,
                            height: 80,
                            color: const Color(
                              0xFFE8B4B8,
                            ).withValues(alpha: 0.15),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        color: Color(0xFFB76E79),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          compact
                              ? 'Glow Week: up to 60% off bestsellers'
                              : 'Glow Week Sale: up to 60% off across skincare, makeup, and fragrances',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF2D1B20),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (!compact)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFB76E79,
                            ).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(
                                0xFFB76E79,
                              ).withValues(alpha: 0.18),
                            ),
                          ),
                          child: const Text(
                            'Ends in 03:12:45',
                            style: TextStyle(
                              color: Color(0xFF2D1B20),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  3. HERO SECTION — Light beauty aesthetic
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildHeroSection(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final desktop = w >= 980;
    final smallMobile = w < 430;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE8B4B8).withValues(alpha: 0.18),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            children: [
              // ── Soft cream-to-blush gradient ──
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFFF5F5),
                        Color(0xFFFCECED),
                        Color(0xFFF9E4E8),
                        Color(0xFFF5DDE1),
                      ],
                    ),
                  ),
                ),
              ),
              // ── Gentle floating orbs ──
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, box) {
                    return AnimatedBuilder(
                      animation: _floatController,
                      builder: (context, _) {
                        final wave = math.sin(
                          _floatController.value * math.pi * 2,
                        );
                        final sway = math.cos(
                          _floatController.value * math.pi * 2,
                        );
                        return Stack(
                          children: [
                            Positioned(
                              right: box.maxWidth * 0.02 + wave * 12,
                              top: 20 + sway * 8,
                              child: _glowOrb(
                                size: box.maxWidth > 900 ? 200 : 130,
                                color: const Color(
                                  0xFFE8B4B8,
                                ).withValues(alpha: 0.20),
                              ),
                            ),
                            Positioned(
                              left: box.maxWidth * 0.25 + sway * 10,
                              bottom: 30 + wave * 8,
                              child: _glowOrb(
                                size: box.maxWidth > 900 ? 220 : 140,
                                color: const Color(
                                  0xFFD4A0A6,
                                ).withValues(alpha: 0.14),
                              ),
                            ),
                            Positioned(
                              left: box.maxWidth * 0.65,
                              top: box.maxWidth > 900 ? 160 : 100,
                              child: _glowOrb(
                                size: 80,
                                color: const Color(
                                  0xFFB76E79,
                                ).withValues(alpha: 0.10),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              // ── Content ──
              Padding(
                padding: EdgeInsets.all(
                  desktop
                      ? 48
                      : smallMobile
                      ? 20
                      : 28,
                ),
                child: desktop
                    ? Row(
                        children: [
                          Expanded(child: _buildHeroCopy(desktop: true)),
                          const SizedBox(width: 40),
                          Expanded(child: _buildHeroVisual(compact: false)),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeroCopy(
                            desktop: false,
                            smallMobile: smallMobile,
                          ),
                          const SizedBox(height: 24),
                          _buildHeroVisual(compact: true, dense: smallMobile),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCopy({required bool desktop, bool smallMobile = false}) {
    final titleSize = desktop ? 52.0 : (smallMobile ? 32.0 : 38.0);
    final crossAlign = desktop
        ? CrossAxisAlignment.start
        : CrossAxisAlignment.center;
    final textAlign = desktop ? TextAlign.start : TextAlign.center;

    return Column(
      crossAxisAlignment: crossAlign,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // ── Pill badge ──
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFFB76E79).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFB76E79).withValues(alpha: 0.18),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFB76E79),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'YOUR BEAUTY DESTINATION',
                style: TextStyle(
                  color: Color(0xFF8B4A52),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        // ── Main headline ──
        RichText(
          textAlign: textAlign,
          text: TextSpan(
            style: TextStyle(
              color: const Color(0xFF2D1B20),
              fontSize: titleSize,
              height: 1.10,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.2,
            ),
            children: [
              const TextSpan(text: 'Discover Your\n'),
              WidgetSpan(
                child: ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) =>
                      const LinearGradient(
                        colors: [
                          Color(0xFFB76E79),
                          Color(0xFFD4919B),
                          Color(0xFFE8B4B8),
                        ],
                      ).createShader(
                        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                      ),
                  child: Text(
                    'Perfect Glow',
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.2,
                      height: 1.10,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // ── Subtext ──
        Text(
          'Premium beauty, skincare & wellness from top brands — curated for every skin type, delivered to your door.',
          textAlign: textAlign,
          style: TextStyle(
            color: const Color(0xFF5A3A40).withValues(alpha: 0.70),
            fontSize: desktop ? 16 : 14,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 26),
        // ── Action buttons ──
        Wrap(
          alignment: desktop ? WrapAlignment.start : WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB76E79),
                foregroundColor: Colors.white,
                elevation: 8,
                shadowColor: const Color(0xFFB76E79).withValues(alpha: 0.35),
                padding: EdgeInsets.symmetric(
                  horizontal: smallMobile ? 22 : 30,
                  vertical: smallMobile ? 16 : 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Shop Now',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: smallMobile ? 14 : 15,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF5A3A40),
                side: const BorderSide(color: Color(0xFFD4A0A6), width: 1.5),
                padding: EdgeInsets.symmetric(
                  horizontal: smallMobile ? 22 : 30,
                  vertical: smallMobile ? 16 : 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'View Offers',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: smallMobile ? 14 : 15,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 26),
        // ── Search bar ──
        _buildInlineSearch(desktop),
      ],
    );
  }

  Widget _buildInlineSearch(bool desktop) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE8B4B8).withValues(alpha: 0.30),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB76E79).withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(
            Icons.search_rounded,
            color: const Color(0xFF8B4A52).withValues(alpha: 0.45),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () => context.push(
                '/category',
                extra: <String, dynamic>{
                  'autoFocusSearch': true,
                  'title': 'Search',
                },
              ),
              child: Text(
                desktop
                    ? 'Search lipsticks, serums, sunscreens, fragrances...'
                    : 'Search beauty products...',
                style: TextStyle(
                  color: const Color(0xFF8B4A52).withValues(alpha: 0.38),
                  fontSize: 13,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => context.push(
              '/category',
              extra: <String, dynamic>{'title': 'All Products'},
            ),
            child: Container(
              margin: const EdgeInsets.only(right: 5),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFFB76E79).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.tune_rounded,
                color: const Color(0xFF8B4A52).withValues(alpha: 0.55),
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroVisual({required bool compact, bool dense = false}) {
    return SizedBox(
      height: compact ? (dense ? 200.0 : 230.0) : 300.0,
      child: AnimatedBuilder(
        animation: _floatController,
        builder: (context, _) {
          final lift = math.sin(_floatController.value * 2 * math.pi);
          return Stack(
            clipBehavior: Clip.none,
            children: [
              // ── Stat cards floating ──
              Positioned(
                left: 0,
                top: compact ? 60 + lift * 4 : 80 + lift * 6,
                child: _HeroStatChip(
                  icon: Icons.local_fire_department_rounded,
                  label: 'Bestseller',
                  value: 'Up to 55% Off',
                  color: const Color(0xFFEF5350),
                ),
              ),
              Positioned(
                right: compact ? 4 : 10,
                top: compact ? 10 - lift * 4 : 14 - lift * 6,
                child: _HeroStatChip(
                  icon: Icons.spa_rounded,
                  label: 'Skincare',
                  value: 'New Routines',
                  color: const Color(0xFF4ECDC4),
                ),
              ),
              Positioned(
                right: compact ? 18 : 24,
                bottom: compact ? 10 + lift * 3 : 20 + lift * 5,
                child: _HeroStatChip(
                  icon: Icons.star_rounded,
                  label: 'Top Rated',
                  value: '4.8 Avg Rating',
                  color: const Color(0xFFFFB400),
                ),
              ),
              // ── Central decorative orb ──
              if (!compact)
                Positioned(
                  left: 60,
                  top: 100,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFE8B4B8).withValues(alpha: 0.25),
                          const Color(0xFFE8B4B8).withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  4. TRUST METRICS
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildTrustMetrics(BuildContext context) {
    const data = [
      _MetricData(
        value: '50k+',
        label: 'Happy customers',
        icon: Icons.favorite_outline_rounded,
        color: Color(0xFFE8B4B8),
      ),
      _MetricData(
        value: '8k+',
        label: 'Beauty products',
        icon: Icons.spa_outlined,
        color: Color(0xFF4ECDC4),
      ),
      _MetricData(
        value: '100%',
        label: 'Genuine products',
        icon: Icons.verified_outlined,
        color: Color(0xFFFFB400),
      ),
      _MetricData(
        value: '24h',
        label: 'Fast dispatch',
        icon: Icons.local_shipping_outlined,
        color: Color(0xFF8B5CF6),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: LayoutBuilder(
        builder: (context, box) {
          final cols = box.maxWidth >= 1100
              ? 4
              : box.maxWidth >= 700
              ? 2
              : 2;
          const gap = 12.0;
          final cardW = (box.maxWidth - (cols - 1) * gap) / cols;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: data
                .map(
                  (d) => SizedBox(
                    width: cardW,
                    child: _MetricCard(data: d, animation: _floatController),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  5. FEATURED BRANDS
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildFeaturedBrands(BuildContext context) {
    const brands = [
      _BrandItem('Lakme', Icons.face_retouching_natural, Color(0xFFE8B4B8)),
      _BrandItem('LOreal', Icons.auto_awesome, Color(0xFF4ECDC4)),
      _BrandItem('Maybelline', Icons.brush_rounded, Color(0xFFFFB400)),
      _BrandItem('Biotique', Icons.eco_rounded, Color(0xFF66BB6A)),
      _BrandItem('Nivea', Icons.water_drop_rounded, Color(0xFF42A5F5)),
      _BrandItem('Dove', Icons.spa_rounded, Color(0xFFF48FB1)),
      _BrandItem('Revlon', Icons.palette_rounded, Color(0xFFCE93D8)),
      _BrandItem('Himalaya', Icons.landscape_rounded, Color(0xFF80CBC4)),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            badge: 'Trusted names',
            title: 'Featured Brands',
            subtitle: 'Shop from India\'s most loved beauty & care brands.',
            actionLabel: 'View All',
            onAction: () => context.push(
              '/category',
              extra: <String, dynamic>{'title': 'Featured Brands'},
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: brands.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (_, i) => _BrandCard(brand: brands[i]),
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  6. CATEGORIES
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildCategorySection(BuildContext context) {
    const categories = [
      _CategoryData('All', Icons.grid_view_rounded),
      _CategoryData('Makeup', Icons.brush_rounded),
      _CategoryData('Skincare', Icons.spa_outlined),
      _CategoryData('Haircare', Icons.content_cut_rounded),
      _CategoryData('Fragrance', Icons.water_drop_outlined),
      _CategoryData('Bath & Body', Icons.bathtub_outlined),
      _CategoryData('Nails', Icons.back_hand_outlined),
      _CategoryData('Tools', Icons.auto_fix_high_rounded),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            badge: 'Browse',
            title: 'Shop by Category',
            subtitle: 'Find exactly what your beauty routine needs.',
            actionLabel: 'View All',
            onAction: () => context.push(
              '/category',
              extra: <String, dynamic>{'title': 'All Products'},
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final cat = categories[i];
                return _CategoryPill(
                  label: cat.name,
                  icon: cat.icon,
                  selected: i == _selectedCategory,
                  onTap: () {
                    setState(() => _selectedCategory = i);
                    context.push(
                      '/category',
                      extra: <String, dynamic>{
                        'category': cat.name == 'All' ? null : cat.name,
                        'title': cat.name == 'All' ? 'All Products' : cat.name,
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  7. BESTSELLERS
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildBestsellers(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 34, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            badge: 'Customer favorites',
            title: 'Bestsellers',
            subtitle:
                'Our most-loved products with thousands of 5-star ratings.',
            actionLabel: 'See All',
            onAction: () => context.push(
              '/category',
              extra: <String, dynamic>{
                'title': 'Bestsellers',
                'sort': 'Popularity',
                'collection': 'bestseller',
              },
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 370,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 6,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (_, i) => SizedBox(
                width: 240,
                child: ProductCard(
                  product: CatalogProduct
                      .bestsellers[i % CatalogProduct.bestsellers.length],
                  badge: 'BESTSELLER',
                  badgeColor: const Color(0xFFE8B4B8),
                  onAddToCart: _addToCart,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  8. SHOP BY CONCERN
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildShopByConcern(BuildContext context) {
    const concerns = [
      _ConcernItem(
        'Acne & Blemishes',
        Icons.healing_rounded,
        Color(0xFFEF5350),
      ),
      _ConcernItem('Dry Skin', Icons.water_drop_outlined, Color(0xFF42A5F5)),
      _ConcernItem('Anti-Aging', Icons.auto_awesome, Color(0xFFAB47BC)),
      _ConcernItem(
        'Sun Protection',
        Icons.wb_sunny_outlined,
        Color(0xFFFFB400),
      ),
      _ConcernItem('Hair Fall', Icons.content_cut_rounded, Color(0xFF66BB6A)),
      _ConcernItem(
        'Dark Circles',
        Icons.remove_red_eye_outlined,
        Color(0xFF78909C),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 34, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            badge: 'Targeted solutions',
            title: 'Shop by Concern',
            subtitle:
                'Find products that address your specific skin & hair needs.',
            actionLabel: 'View All',
            onAction: () => context.push(
              '/category',
              extra: <String, dynamic>{'title': 'Shop by Concern'},
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, box) {
              final cols = box.maxWidth >= 800
                  ? 3
                  : box.maxWidth >= 480
                  ? 2
                  : 2;
              const gap = 12.0;
              final cardW = (box.maxWidth - (cols - 1) * gap) / cols;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: concerns
                    .map(
                      (c) => SizedBox(
                        width: cardW,
                        child: _ConcernCard(item: c),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  9. NEW ARRIVALS
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildNewArrivals(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 34, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            badge: 'Just launched',
            title: 'New Arrivals',
            subtitle: 'Fresh drops handpicked by the JGS beauty team.',
            actionLabel: 'View All',
            onAction: () => context.push(
              '/category',
              extra: <String, dynamic>{
                'title': 'New Arrivals',
                'sort': 'Newest',
                'collection': 'new_arrival',
              },
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 370,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (_, i) => SizedBox(
                width: 240,
                child: ProductCard(
                  product: CatalogProduct
                      .newArrivals[i % CatalogProduct.newArrivals.length],
                  badge: 'NEW',
                  badgeColor: Colors.white,
                  badgeTextColor: Colors.black,
                  onAddToCart: _addToCart,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  10. BRAND STORY BANNER
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildBrandBanner(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 760;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 34, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.all(compact ? 18 : 24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFFF5F0),
                    Color(0xFFFCECED),
                    Color(0xFFFFF5F0),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE8B4B8).withValues(alpha: 0.15),
                    blurRadius: 26,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
            ),
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _shineController,
                builder: (context, _) {
                  final ox = -260 + 520 * _shineController.value;
                  return Transform.translate(
                    offset: Offset(ox, 0),
                    child: Container(
                      width: 180,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0),
                            const Color(0xFFE8B4B8).withValues(alpha: 0.15),
                            Colors.white.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.all(compact ? 18 : 24),
                child: compact
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.memory(LogoAssets.darkLogoBytes, height: 42),
                          const SizedBox(height: 12),
                          const Text(
                            'Beauty you can trust,\nprices you\'ll love',
                            style: TextStyle(
                              color: Color(0xFF2D1B20),
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '100% genuine products from authorized retailers. Every product verified, every brand trusted.',
                            style: TextStyle(
                              color: const Color(
                                0xFF5A3A40,
                              ).withValues(alpha: 0.72),
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE8B4B8),
                              foregroundColor: const Color(0xFF1A0E1E),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Explore Collection',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Image.memory(LogoAssets.darkLogoBytes, height: 56),
                          const SizedBox(width: 22),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Beauty you can trust, prices you\'ll love',
                                  style: TextStyle(
                                    color: Color(0xFF2D1B20),
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.8,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '100% genuine products from authorized retailers. Every product verified, every brand trusted.',
                                  style: TextStyle(
                                    color: const Color(
                                      0xFF5A3A40,
                                    ).withValues(alpha: 0.70),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE8B4B8),
                              foregroundColor: const Color(0xFF1A0E1E),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.arrow_forward_rounded),
                            label: const Text(
                              'Explore Collection',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  11. POPULAR PRODUCTS — grid
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildPopularProducts(BuildContext context) {
    final all = [...CatalogProduct.bestsellers, ...CatalogProduct.newArrivals];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 34, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            badge: 'Most loved',
            title: 'Popular Products',
            subtitle:
                'Top-performing picks based on ratings and repeat purchases.',
            actionLabel: 'View All',
            onAction: () => context.push(
              '/category',
              extra: <String, dynamic>{
                'title': 'Popular Products',
                'sort': 'Popularity',
                'collection': 'popular',
              },
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 370,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 8,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (_, i) => SizedBox(
                width: 240,
                child: ProductCard(
                  product: all[i % all.length],
                  onAddToCart: _addToCart,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  12. CUSTOMER REVIEWS
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildCustomerReviews(BuildContext context) {
    const reviews = [
      _ReviewData(
        name: 'Priya S.',
        rating: 5,
        text:
            'Amazing quality products! The sunscreen I ordered is genuine and the delivery was super fast. Best beauty store online.',
        product: 'Lakme Sunscreen SPF 50',
      ),
      _ReviewData(
        name: 'Ananya R.',
        rating: 5,
        text:
            'Love the range of skincare products. The prices are much better than other stores and everything arrived sealed.',
        product: 'Biotique Vitamin C Serum',
      ),
      _ReviewData(
        name: 'Meera K.',
        rating: 4,
        text:
            'Great experience shopping here. The product recommendations were spot on for my skin type. Will definitely order again!',
        product: 'LOreal Night Cream',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 34, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            badge: 'Real reviews',
            title: 'What Customers Say',
            subtitle: 'Genuine reviews from verified buyers across India.',
            actionLabel: 'View All',
            onAction: () => context.push(
              '/category',
              extra: <String, dynamic>{'title': 'Customer Reviews'},
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: reviews.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (_, i) =>
                  SizedBox(width: 320, child: _ReviewCard(review: reviews[i])),
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  13. MEMBERSHIP / NEWSLETTER
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildMembershipSection(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final compact = w < 920;
    final tiny = w < 430;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 34, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF5F0),
                  border: Border.all(
                    color: const Color(0xFFE8D5D0).withValues(alpha: 0.50),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _floatController,
                builder: (context, _) {
                  final wave = math.sin(_floatController.value * 2 * math.pi);
                  return Align(
                    alignment: Alignment(0.84, -0.70 + wave * 0.06),
                    child: _glowOrb(
                      size: compact ? 160 : 220,
                      color: const Color(0xFFE8B4B8).withValues(alpha: 0.08),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(compact ? 20 : 30),
              child: compact
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMembershipCopy(compact: true, tiny: tiny),
                        const SizedBox(height: 16),
                        _buildMembershipPanel(compact: true),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _buildMembershipCopy(
                            compact: false,
                            tiny: false,
                          ),
                        ),
                        const SizedBox(width: 26),
                        Expanded(
                          flex: 2,
                          child: _buildMembershipPanel(compact: false),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembershipCopy({required bool compact, required bool tiny}) {
    final titleSize = compact ? (tiny ? 26.0 : 30.0) : 38.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFFE8B4B8).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: const Color(0xFFE8B4B8).withValues(alpha: 0.25),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.workspace_premium_outlined,
                color: Color(0xFFE8B4B8),
                size: 16,
              ),
              SizedBox(width: 8),
              Text(
                'JGS BEAUTY CLUB',
                style: TextStyle(
                  color: Color(0xFFE8B4B8),
                  fontSize: 11,
                  letterSpacing: 0.7,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Join the Beauty Club for exclusive perks',
          style: TextStyle(
            color: const Color(0xFF2D1B20),
            fontSize: titleSize,
            fontWeight: FontWeight.w900,
            height: 1.08,
            letterSpacing: -0.9,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Unlock member-only pricing, early access to new launches, and personalized beauty recommendations.',
          style: TextStyle(
            color: const Color(0xFF5A3A40).withValues(alpha: 0.70),
            fontSize: compact ? 14 : 15,
            height: 1.55,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _featureChip(
              Icons.local_shipping_outlined,
              tiny ? 'Free shipping' : 'Free shipping on orders',
            ),
            _featureChip(
              Icons.auto_awesome,
              tiny ? 'Early access' : 'Early access to launches',
            ),
            _featureChip(
              Icons.savings_outlined,
              tiny ? 'Extra savings' : 'Member-only discounts',
            ),
          ],
        ),
      ],
    );
  }

  Widget _featureChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFE8B4B8).withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xFFE8D5D0).withValues(alpha: 0.40),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFFB76E79)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF2D1B20),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembershipPanel({required bool compact}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE8D5D0).withValues(alpha: 0.50),
        ),
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
                  color: const Color(0xFFE8B4B8).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.card_membership_rounded,
                  color: Color(0xFFE8B4B8),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Member Benefits',
                  style: TextStyle(
                    color: Color(0xFF2D1B20),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8B4B8),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'FREE',
                  style: TextStyle(
                    color: Color(0xFF1A0E1E),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _benefitRow('Exclusive weekly beauty deals'),
          const SizedBox(height: 8),
          _benefitRow('Personalized skincare tips'),
          const SizedBox(height: 8),
          _benefitRow('Priority support for orders'),
          const SizedBox(height: 14),
          compact
              ? Column(
                  children: [
                    _newsletterInput(),
                    const SizedBox(height: 10),
                    _newsletterButton(fullWidth: true),
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: _newsletterInput()),
                    const SizedBox(width: 10),
                    _newsletterButton(fullWidth: false),
                  ],
                ),
          const SizedBox(height: 8),
          Text(
            'No spam. One-click unsubscribe anytime.',
            style: TextStyle(
              color: const Color(0xFF5A3A40).withValues(alpha: 0.50),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _benefitRow(String label) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.check_circle_outline_rounded,
          color: Color(0xFFE8B4B8),
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: const Color(0xFF5A3A40).withValues(alpha: 0.75),
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  Widget _newsletterInput() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Enter your email',
        hintStyle: TextStyle(
          color: const Color(0xFF5A3A40).withValues(alpha: 0.35),
        ),
        prefixIcon: Icon(
          Icons.mail_outline_rounded,
          color: const Color(0xFF5A3A40).withValues(alpha: 0.40),
          size: 18,
        ),
        fillColor: const Color(0xFFF5EDE8).withValues(alpha: 0.60),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: const Color(0xFFE8D5D0).withValues(alpha: 0.50),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: const Color(0xFFE8D5D0).withValues(alpha: 0.50),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFE8B4B8)),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      style: const TextStyle(color: Color(0xFF2D1B20)),
    );
  }

  Widget _newsletterButton({required bool fullWidth}) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton.icon(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE8B4B8),
          foregroundColor: const Color(0xFF1A0E1E),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.send_rounded, size: 18),
        label: const Text(
          'Join Free',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  14. FOOTER
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildFooter(BuildContext context, double contentWidth) {
    final compact = MediaQuery.sizeOf(context).width < 900;

    return Container(
      margin: const EdgeInsets.only(top: 34),
      padding: const EdgeInsets.fromLTRB(20, 46, 20, 24),
      decoration: BoxDecoration(
        color: const Color(0xFFF5EDE8),
        border: Border(
          top: BorderSide(
            color: const Color(0xFFE8D5D0).withValues(alpha: 0.60),
          ),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: contentWidth),
          child: Column(
            children: [
              if (compact)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFooterBrand(),
                    const SizedBox(height: 24),
                    const Wrap(
                      spacing: 24,
                      runSpacing: 24,
                      children: [
                        SizedBox(
                          width: 140,
                          child: _FooterColumn(
                            title: 'SHOP',
                            links: [
                              'Makeup',
                              'Skincare',
                              'Haircare',
                              'Fragrances',
                              'Bath & Body',
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 140,
                          child: _FooterColumn(
                            title: 'HELP',
                            links: [
                              'Track Order',
                              'Returns',
                              'Shipping Info',
                              'FAQs',
                              'Contact Us',
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 140,
                          child: _FooterColumn(
                            title: 'COMPANY',
                            links: [
                              'About JGS',
                              'Our Story',
                              'Careers',
                              'Terms',
                              'Privacy',
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _buildFooterBrand()),
                    const SizedBox(width: 34),
                    const Expanded(
                      child: _FooterColumn(
                        title: 'SHOP',
                        links: [
                          'Makeup',
                          'Skincare',
                          'Haircare',
                          'Fragrances',
                          'Bath & Body',
                        ],
                      ),
                    ),
                    const Expanded(
                      child: _FooterColumn(
                        title: 'HELP',
                        links: [
                          'Track Order',
                          'Returns',
                          'Shipping Info',
                          'FAQs',
                          'Contact Us',
                        ],
                      ),
                    ),
                    const Expanded(
                      child: _FooterColumn(
                        title: 'COMPANY',
                        links: [
                          'About JGS',
                          'Our Story',
                          'Careers',
                          'Terms',
                          'Privacy',
                        ],
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 36),
              Divider(color: const Color(0xFFE8D5D0).withValues(alpha: 0.50)),
              const SizedBox(height: 14),
              // ── Admin link ──
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => context.push('/admin'),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Text(
                      'Admin Panel',
                      style: TextStyle(
                        color: const Color(0xFF5A3A40).withValues(alpha: 0.45),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        decorationColor: const Color(
                          0xFF5A3A40,
                        ).withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),
              ),
              compact
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '© 2026 Jagdish General Store. All rights reserved.',
                          style: TextStyle(
                            color: const Color(
                              0xFF5A3A40,
                            ).withValues(alpha: 0.55),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.verified_outlined,
                              color: const Color(
                                0xFF5A3A40,
                              ).withValues(alpha: 0.45),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '100% genuine products · Secure payments · COD available',
                                style: TextStyle(
                                  color: const Color(
                                    0xFF5A3A40,
                                  ).withValues(alpha: 0.55),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: Text(
                            '© 2026 Jagdish General Store. All rights reserved.',
                            style: TextStyle(
                              color: const Color(
                                0xFF5A3A40,
                              ).withValues(alpha: 0.55),
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Wrap(
                              spacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Icon(
                                  Icons.verified_outlined,
                                  color: const Color(
                                    0xFF5A3A40,
                                  ).withValues(alpha: 0.45),
                                  size: 16,
                                ),
                                Text(
                                  '100% genuine · Secure payments · COD available',
                                  style: TextStyle(
                                    color: const Color(
                                      0xFF5A3A40,
                                    ).withValues(alpha: 0.55),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterBrand() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.memory(LogoAssets.darkLogoBytes, height: 44, fit: BoxFit.contain),
        const SizedBox(height: 18),
        const Text(
          'Jagdish General Store',
          style: TextStyle(
            color: Color(0xFF2D1B20),
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Your premium destination for beauty, skincare, and personal care. Trusted by 50,000+ customers since 1995.',
          style: TextStyle(
            color: const Color(0xFF5A3A40).withValues(alpha: 0.65),
            fontSize: 14,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 16),
        const Row(
          children: [
            _SocialIcon(icon: Icons.facebook),
            SizedBox(width: 10),
            _SocialIcon(icon: Icons.camera_alt_outlined),
            SizedBox(width: 10),
            _SocialIcon(icon: Icons.chat_bubble_outline),
          ],
        ),
      ],
    );
  }

  Widget _glowOrb({required double size, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  DATA MODELS
// ═══════════════════════════════════════════════════════════════════════════

class _MetricData {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  const _MetricData({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });
}

class _CategoryData {
  final String name;
  final IconData icon;
  const _CategoryData(this.name, this.icon);
}

class _BrandItem {
  final String name;
  final IconData icon;
  final Color color;
  const _BrandItem(this.name, this.icon, this.color);
}

class _ConcernItem {
  final String name;
  final IconData icon;
  final Color color;
  const _ConcernItem(this.name, this.icon, this.color);
}

class _ReviewData {
  final String name;
  final int rating;
  final String text;
  final String product;
  const _ReviewData({
    required this.name,
    required this.rating,
    required this.text,
    required this.product,
  });
}

// ═══════════════════════════════════════════════════════════════════════════
//  AMBIENT BACKGROUND — Floating light beams
// ═══════════════════════════════════════════════════════════════════════════

class _BeamData {
  double x, y, width, height, opacity, speed, angle;
  _BeamData({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.opacity,
    required this.speed,
    required this.angle,
  });
}

class _BeamPainter extends CustomPainter {
  final List<_BeamData> beams;
  final double animationValue;
  _BeamPainter({required this.beams, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
    for (var b in beams) {
      final cy =
          (b.y + animationValue * b.speed * 150) % (size.height + b.height) -
          b.height;
      canvas.save();
      canvas.translate(b.x + b.width / 2, cy + b.height / 2);
      canvas.rotate(b.angle);
      final rect = Rect.fromLTWH(
        -b.width / 2,
        -b.height / 2,
        b.width,
        b.height,
      );
      paint.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFE8B4B8).withValues(alpha: 0),
          const Color(0xFFE8B4B8).withValues(alpha: b.opacity),
          const Color(0xFFE8B4B8).withValues(alpha: 0),
        ],
      ).createShader(rect);
      canvas.drawRect(rect, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _BeamPainter old) =>
      old.animationValue != animationValue;
}

class _BeamBackground extends StatefulWidget {
  const _BeamBackground();
  @override
  State<_BeamBackground> createState() => _BeamBackgroundState();
}

class _BeamBackgroundState extends State<_BeamBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  final List<_BeamData> _beams = [];
  final _rng = math.Random();

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    for (int i = 0; i < 6; i++) {
      _beams.add(
        _BeamData(
          x: _rng.nextDouble() * 2000 - 400,
          y: _rng.nextDouble() * 1200,
          width: _rng.nextDouble() * 100 + 40,
          height: _rng.nextDouble() * 700 + 400,
          opacity: _rng.nextDouble() * 0.08 + 0.02,
          speed: _rng.nextDouble() * 0.4 + 0.3,
          angle: 43 * math.pi / 180,
        ),
      );
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) => CustomPaint(
        painter: _BeamPainter(beams: _beams, animationValue: _ctrl.value),
        size: Size.infinite,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  REUSABLE WIDGET COMPONENTS
// ═══════════════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  final String badge;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  const _SectionHeader({
    required this.badge,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final compact = box.maxWidth < 620;
        final titleBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE8B4B8).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: const Color(0xFFE8B4B8).withValues(alpha: 0.20),
                ),
              ),
              child: Text(
                badge.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFFB76E79),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF2D1B20),
                fontSize: 30,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.0,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(
                color: const Color(0xFF5A3A40).withValues(alpha: 0.60),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        );
        if (actionLabel == null) return titleBlock;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: titleBlock),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: onAction,
              icon: Icon(Icons.arrow_forward_rounded, size: compact ? 16 : 18),
              label: Text(actionLabel!),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFB76E79),
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 8 : 12,
                  vertical: compact ? 6 : 8,
                ),
                textStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: compact ? 13 : 14,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _NavActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool compact;
  final VoidCallback onTap;
  const _NavActionButton({
    required this.icon,
    required this.label,
    required this.compact,
    required this.onTap,
  });
  @override
  State<_NavActionButton> createState() => _NavActionButtonState();
}

class _NavActionButtonState extends State<_NavActionButton> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(
            horizontal: widget.compact ? 10 : 12,
            vertical: widget.compact ? 8 : 9,
          ),
          decoration: BoxDecoration(
            color: const Color(
              0xFF5A3A40,
            ).withValues(alpha: _hovered ? 0.08 : 0.04),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFFE8D5D0).withValues(alpha: 0.50),
            ),
          ),
          child: widget.compact
              ? Icon(widget.icon, color: const Color(0xFF2D1B20), size: 20)
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(widget.icon, color: const Color(0xFF2D1B20), size: 18),
                    const SizedBox(width: 6),
                    Text(
                      widget.label,
                      style: const TextStyle(
                        color: Color(0xFF2D1B20),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatefulWidget {
  final _MetricData data;
  final Animation<double> animation;
  const _MetricCard({required this.data, required this.animation});
  @override
  State<_MetricCard> createState() => _MetricCardState();
}

class _MetricCardState extends State<_MetricCard> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Color(0xFFE8D5D0).withValues(alpha: _hovered ? 0.80 : 0.50),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE8B4B8).withValues(alpha: 0.08),
              blurRadius: _hovered ? 20 : 10,
              offset: Offset(0, _hovered ? 8 : 4),
            ),
          ],
        ),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: widget.animation,
              builder: (context, _) {
                final pulse =
                    0.95 +
                    (math.sin(widget.animation.value * math.pi * 2) + 1) * 0.05;
                return Transform.scale(
                  scale: pulse,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: widget.data.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.data.icon,
                      color: widget.data.color,
                      size: 22,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.data.value,
                    style: const TextStyle(
                      color: Color(0xFF2D1B20),
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.data.label,
                    style: TextStyle(
                      color: const Color(0xFF5A3A40).withValues(alpha: 0.60),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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

class _CategoryPill extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _CategoryPill({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  @override
  State<_CategoryPill> createState() => _CategoryPillState();
}

class _CategoryPillState extends State<_CategoryPill> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 230),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            color: widget.selected
                ? const Color(0xFFE8B4B8)
                : const Color(
                    0xFF5A3A40,
                  ).withValues(alpha: _hovered ? 0.06 : 0.02),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: widget.selected
                  ? const Color(0xFFE8B4B8)
                  : const Color(0xFFE8D5D0).withValues(alpha: 0.60),
            ),
            boxShadow: [
              if (widget.selected)
                BoxShadow(
                  color: const Color(0xFFE8B4B8).withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 18,
                color: widget.selected
                    ? const Color(0xFF1A0E1E)
                    : const Color(0xFF5A3A40),
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.selected
                      ? const Color(0xFF1A0E1E)
                      : const Color(0xFF2D1B20),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroStatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _HeroStatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: const Color(0xFF5A3A40).withValues(alpha: 0.60),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF2D1B20),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BrandCard extends StatefulWidget {
  final _BrandItem brand;
  const _BrandCard({required this.brand});
  @override
  State<_BrandCard> createState() => _BrandCardState();
}

class _BrandCardState extends State<_BrandCard> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => context.push(
          '/category',
          extra: <String, dynamic>{
            'title': widget.brand.name,
            'brand': widget.brand.name,
          },
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: 100,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: _hovered ? Colors.white : const Color(0xFFFDF8F5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Color(
                0xFFE8D5D0,
              ).withValues(alpha: _hovered ? 0.80 : 0.50),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: widget.brand.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.brand.icon,
                  color: widget.brand.color,
                  size: 22,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.brand.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF2D1B20).withValues(alpha: 0.8),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConcernCard extends StatefulWidget {
  final _ConcernItem item;
  const _ConcernCard({required this.item});
  @override
  State<_ConcernCard> createState() => _ConcernCardState();
}

class _ConcernCardState extends State<_ConcernCard> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => context.push(
          '/category',
          extra: <String, dynamic>{
            'title': widget.item.name,
            'concern': widget.item.name,
          },
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _hovered ? Colors.white : const Color(0xFFFDF8F5),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Color(
                0xFFE8D5D0,
              ).withValues(alpha: _hovered ? 0.80 : 0.50),
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: widget.item.color.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: widget.item.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.item.icon,
                  color: widget.item.color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.name,
                      style: const TextStyle(
                        color: Color(0xFF2D1B20),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Shop solutions',
                      style: TextStyle(
                        color: widget.item.color,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final _ReviewData review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE8D5D0).withValues(alpha: 0.50),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ...List.generate(
                5,
                (i) => Icon(
                  i < review.rating
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  color: Colors.amber,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                review.name,
                style: const TextStyle(
                  color: Color(0xFF2D1B20),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Text(
              review.text,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: const Color(0xFF5A3A40).withValues(alpha: 0.70),
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFF5EDE8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Purchased: ${review.product}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: const Color(0xFF5A3A40).withValues(alpha: 0.60),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterColumn extends StatelessWidget {
  final String title;
  final List<String> links;
  const _FooterColumn({required this.title, required this.links});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF2D1B20),
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 18),
        ...links.map(
          (l) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {},
              child: Text(
                l,
                style: TextStyle(
                  color: const Color(0xFF5A3A40).withValues(alpha: 0.60),
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  const _SocialIcon({required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFE8B4B8).withValues(alpha: 0.12),
        border: Border.all(
          color: const Color(0xFFE8D5D0).withValues(alpha: 0.50),
        ),
      ),
      child: Icon(icon, color: const Color(0xFFB76E79), size: 17),
    );
  }
}
