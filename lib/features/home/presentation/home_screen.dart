import 'dart:math' as math;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/logo_assets.dart';
import '../../cart/providers/cart_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final AnimationController _introController;
  late final AnimationController _floatController;
  late final AnimationController _shineController;

  final ScrollController _scrollController = ScrollController();

  bool _isScrolled = false;
  int _selectedCategory = 0;

  // Dynamic configuration - this would come from Firestore in production.
  final bool _seasonalBannerEnabled = true;
  final String _seasonalTitle = 'Spring Beauty Festival is Live';
  final Color _seasonalColor1 = const Color(0xFF3D6BFF);
  final Color _seasonalColor2 = const Color(0xFF34C8A3);

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
    if (scrolled != _isScrolled) {
      setState(() => _isScrolled = scrolled);
    }
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

  Widget _animatedSection({
    required int order,
    required Widget child,
    double translateY = 28,
  }) {
    final start = (order * 0.08).clamp(0.0, 0.75).toDouble();
    final end = math.min(start + 0.30, 1.0);

    final sectionAnimation = CurvedAnimation(
      parent: _introController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: sectionAnimation,
      builder: (context, _) {
        final value = sectionAnimation.value;
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * translateY),
            child: child,
          ),
        );
      },
    );
  }

  void _addToCart(_CatalogProduct product, {String? snackLabel}) {
    Provider.of<CartProvider>(
      context,
      listen: false,
    ).addItem(product.id, product.name, product.price, '');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
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
                '${snackLabel ?? product.name} added to cart',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF0D1B4B),
        action: SnackBarAction(
          label: 'CART',
          textColor: AppTheme.accentColor,
          onPressed: () => context.push('/cart'),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final contentWidth = math.min(screenWidth, 1240.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: _AnimatedBackdrop(animation: _floatController),
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
                          constraints: BoxConstraints(maxWidth: contentWidth),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _animatedSection(
                                order: 0,
                                child: _buildSearchPanel(context),
                              ),
                              _animatedSection(
                                order: 1,
                                child: _buildPromoStrip(context),
                              ),
                              _animatedSection(
                                order: 2,
                                child: _buildHeroSection(context),
                              ),
                              if (_seasonalBannerEnabled)
                                _animatedSection(
                                  order: 3,
                                  child: _buildSeasonalAnnouncement(),
                                ),
                              _animatedSection(
                                order: 4,
                                child: _buildQuickStats(context),
                              ),
                              _animatedSection(
                                order: 5,
                                child: _buildCategoryPills(context),
                              ),
                              _animatedSection(
                                order: 6,
                                child: _buildFlashSaleSection(context),
                              ),
                              _animatedSection(
                                order: 7,
                                child: _buildNewArrivalsSection(context),
                              ),
                              _animatedSection(
                                order: 8,
                                child: _buildBrandBanner(context),
                              ),
                              _animatedSection(
                                order: 9,
                                child: _buildAllProductsSection(context),
                              ),
                              _animatedSection(
                                order: 10,
                                child: _buildNewsletterSection(context),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                      _buildFooter(context, contentWidth),
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

  Widget _buildStickyNavBar(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 760;
    final ultraCompact = width < 390;
    final showOrders = !compact || width >= 430;
    final showAdmin = !compact || width >= 360;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 10,
            bottom: 10,
            left: 16,
            right: 16,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(
                  0xFF0B1A48,
                ).withValues(alpha: _isScrolled ? 0.90 : 0.98),
                const Color(
                  0xFF16327A,
                ).withValues(alpha: _isScrolled ? 0.86 : 0.94),
              ],
            ),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(
                  alpha: _isScrolled ? 0.14 : 0.06,
                ),
              ),
            ),
            boxShadow: _isScrolled
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.30),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : const [],
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1240),
              child: Row(
                children: [
                  SizedBox(
                    width: compact ? (ultraCompact ? 86 : 110) : null,
                    child: Image.memory(
                      LogoAssets.darkLogoBytes,
                      height: compact ? 30 : 38,
                      fit: BoxFit.contain,
                    ),
                  ),
                  if (!compact) ...[
                    const SizedBox(width: 14),
                    Text(
                      'Premium beauty and essentials',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (showOrders)
                    _NavActionButton(
                      icon: Icons.track_changes_outlined,
                      label: 'Orders',
                      compact: compact,
                      onTap: () {},
                    ),
                  if (showOrders) const SizedBox(width: 6),
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
                                        alpha: 0.45,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '${cart.itemCount}',
                                  style: const TextStyle(
                                    color: Color(0xFF0D1B4B),
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
                  if (showAdmin) const SizedBox(width: 6),
                  if (showAdmin)
                    Tooltip(
                      message: 'Admin Panel',
                      child: InkWell(
                        onTap: () => context.push('/admin'),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                          child: const Icon(
                            Icons.admin_panel_settings_outlined,
                            color: AppTheme.accentColor,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPromoStrip(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 720;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 48,
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1E58D9), Color(0xFF00B8A9)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return AnimatedBuilder(
                    animation: _shineController,
                    builder: (context, _) {
                      final x =
                          -120 +
                          (constraints.maxWidth + 240) * _shineController.value;
                      return Transform.translate(
                        offset: Offset(x, -14),
                        child: Transform.rotate(
                          angle: -0.32,
                          child: Container(
                            width: 92,
                            height: 80,
                            color: Colors.white.withValues(alpha: 0.18),
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
                        Icons.bolt_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          compact
                              ? 'Mega Week: up to 60% off best sellers'
                              : 'Mega Week Offer: up to 60% off across beauty, personal care, and home essentials',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (!compact)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Ends in 03:12:45',
                            style: TextStyle(
                              color: Colors.white,
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

  Widget _buildHeroSection(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final desktop = width >= 980;
    final tablet = width >= 700 && width < 980;
    final smallMobile = width < 430;
    final heroHeight = desktop
        ? 560.0
        : tablet
        ? 660.0
        : smallMobile
        ? 820.0
        : 780.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: Container(
        height: heroHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0C1F5E).withValues(alpha: 0.28),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/hero_banner.png',
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        const Color(0xFF071334).withValues(alpha: 0.92),
                        const Color(0xFF0E245C).withValues(alpha: 0.78),
                        const Color(0xFF142A66).withValues(alpha: 0.35),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) {
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
                              right: constraints.maxWidth * 0.08 + wave * 18,
                              top: 48 + sway * 10,
                              child: _GlowOrb(
                                size: constraints.maxWidth > 900 ? 210 : 140,
                                color: const Color(
                                  0xFF42E1C2,
                                ).withValues(alpha: 0.24),
                              ),
                            ),
                            Positioned(
                              left: constraints.maxWidth * 0.55 + sway * 16,
                              bottom: 52 + wave * 10,
                              child: _GlowOrb(
                                size: constraints.maxWidth > 900 ? 260 : 170,
                                color: const Color(
                                  0xFF4B7CFF,
                                ).withValues(alpha: 0.18),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(desktop ? 46 : 24),
                child: desktop
                    ? Row(
                        children: [
                          Expanded(child: _buildHeroCopy(desktop: true)),
                          const SizedBox(width: 24),
                          Expanded(child: _buildHeroDealStack(compact: false)),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeroCopy(
                            desktop: false,
                            smallMobile: smallMobile,
                          ),
                          const SizedBox(height: 18),
                          Align(
                            alignment: smallMobile
                                ? Alignment.center
                                : Alignment.centerRight,
                            child: _buildHeroDealStack(
                              compact: true,
                              dense: smallMobile,
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

  Widget _buildHeroCopy({required bool desktop, bool smallMobile = false}) {
    final titleSize = desktop
        ? 56.0
        : smallMobile
        ? 34.0
        : 42.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                color: AppTheme.accentColor,
                size: 16,
              ),
              SizedBox(width: 8),
              Text(
                'Curated for modern everyday living',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Text(
          'Where Style Meets Daily Essentials',
          style: TextStyle(
            color: Colors.white,
            fontSize: titleSize,
            height: 1.05,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.4,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Discover premium cosmetics, skincare, grooming, and home must-haves in one beautifully designed shopping experience.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: desktop
                ? 16
                : smallMobile
                ? 13
                : 14,
            height: 1.55,
          ),
        ),
        SizedBox(height: smallMobile ? 20 : 28),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ElevatedButton.icon(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0D1B4B),
                padding: EdgeInsets.symmetric(
                  horizontal: smallMobile ? 18 : 24,
                  vertical: smallMobile ? 14 : 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.shopping_bag_outlined),
              label: const Text(
                'Start Shopping',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(
                  color: Colors.white.withValues(alpha: 0.35),
                  width: 1.5,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: smallMobile ? 18 : 24,
                  vertical: smallMobile ? 14 : 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.local_offer_outlined),
              label: const Text(
                'View Live Deals',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        SizedBox(height: smallMobile ? 16 : 24),
        Wrap(
          spacing: smallMobile ? 10 : 18,
          runSpacing: 10,
          children: const [
            _HeroTrustBadge(
              icon: Icons.verified_outlined,
              label: '100% authentic products',
            ),
            _HeroTrustBadge(
              icon: Icons.local_shipping_outlined,
              label: 'Fast city-wide delivery',
            ),
            _HeroTrustBadge(icon: Icons.lock_outline, label: 'Secure checkout'),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroDealStack({required bool compact, bool dense = false}) {
    final cardWidth = compact ? (dense ? 148.0 : 170.0) : 220.0;
    final cardHeight = compact ? (dense ? 88.0 : 95.0) : 112.0;

    return SizedBox(
      height: compact ? (dense ? 246.0 : 278.0) : 342.0,
      child: AnimatedBuilder(
        animation: _floatController,
        builder: (context, _) {
          final lift = math.sin(_floatController.value * 2 * math.pi);
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                top: compact
                    ? (dense ? 72 + lift * 5 : 84 + lift * 5)
                    : 112 + lift * 7,
                child: _GlassDealCard(
                  width: cardWidth,
                  height: cardHeight,
                  icon: Icons.flash_on_rounded,
                  title: 'Flash Drop',
                  value: 'Up to 55% Off',
                ),
              ),
              Positioned(
                right: compact ? (dense ? 6 : 0) : 10,
                top: compact
                    ? (dense ? 20 - lift * 5 : 24 - lift * 6)
                    : 32 - lift * 8,
                child: _GlassDealCard(
                  width: cardWidth,
                  height: cardHeight,
                  icon: Icons.favorite_rounded,
                  title: 'Trending',
                  value: '12k Added Today',
                ),
              ),
              Positioned(
                right: compact ? (dense ? 24 : 36) : 28,
                bottom: compact
                    ? (dense ? 0 + lift * 4 : 2 + lift * 4)
                    : 14 + lift * 6,
                child: _GlassDealCard(
                  width: cardWidth,
                  height: cardHeight,
                  icon: Icons.star_rounded,
                  title: 'Top Rated',
                  value: '4.8 Avg Score',
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchPanel(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 760;
    final ultraCompact = width < 400;
    final desktop = width >= 980;
    final searchFieldHeight = desktop ? 64.0 : 54.0;

    const quickFilters = [
      'Longwear lipsticks',
      'Hydrating skincare',
      'Men grooming',
      'Home essentials',
      'Perfume deals',
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Container(
        padding: EdgeInsets.all(compact ? 14 : 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0D1B4B).withValues(alpha: 0.05),
              blurRadius: 36,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: searchFieldHeight,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F4)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0D1B4B).withValues(alpha: 0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 14),
                        const Icon(Icons.search_rounded, color: Color(0xFF7685B5)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: desktop
                                  ? 'Search products, brands, categories, offers...'
                                  : 'Search products...',
                              hintStyle: TextStyle(
                                color: const Color(0xFF8E9BC4),
                                fontSize: desktop ? 15 : 14,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: searchFieldHeight,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F6BFF),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(
                        horizontal: ultraCompact ? 16 : (compact ? 16 : 22),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: ultraCompact
                        ? const Icon(Icons.tune_rounded, size: 20)
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.tune_rounded, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                compact ? 'Filter' : 'Search & Filter',
                                style: TextStyle(
                                  fontSize: desktop ? 15 : 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: quickFilters
                  .map(
                    (label) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF3FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: Color(0xFF495A8F),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeasonalAnnouncement() {
    final compact = MediaQuery.sizeOf(context).width < 520;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(colors: [_seasonalColor1, _seasonalColor2]),
          boxShadow: [
            BoxShadow(
              color: _seasonalColor1.withValues(alpha: 0.25),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: compact
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.celebration_outlined,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _seasonalTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Shop Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  const Icon(Icons.celebration_outlined, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _seasonalTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Shop Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    final data = [
      const _MetricData(
        value: '50k+',
        label: 'Happy customers',
        icon: Icons.people_alt_outlined,
        color: Color(0xFF2F6BFF),
      ),
      const _MetricData(
        value: '8k+',
        label: 'Products in catalog',
        icon: Icons.inventory_2_outlined,
        color: Color(0xFFFF7A45),
      ),
      const _MetricData(
        value: '24h',
        label: 'Average dispatch',
        icon: Icons.local_shipping_outlined,
        color: Color(0xFF00A699),
      ),
      const _MetricData(
        value: '4.8/5',
        label: 'Customer rating',
        icon: Icons.star_outline_rounded,
        color: Color(0xFF8B5CF6),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 1100
              ? 4
              : constraints.maxWidth >= 700
              ? 2
              : 1;
          const spacing = 12.0;
          final cardWidth =
              (constraints.maxWidth - (columns - 1) * spacing) / columns;

          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: data
                .map(
                  (item) => SizedBox(
                    width: cardWidth,
                    child: _MetricCard(data: item, animation: _floatController),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }

  Widget _buildCategoryPills(BuildContext context) {
    final categories = [
      const _CategoryData('All', Icons.grid_view_rounded),
      const _CategoryData('Cosmetics', Icons.face_retouching_natural_outlined),
      const _CategoryData('Skincare', Icons.spa_outlined),
      const _CategoryData('Haircare', Icons.content_cut_rounded),
      const _CategoryData('Perfumes', Icons.water_drop_outlined),
      const _CategoryData('Home', Icons.home_outlined),
      const _CategoryData('Groceries', Icons.local_grocery_store_outlined),
      const _CategoryData('Fashion', Icons.checkroom_outlined),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            badge: 'Shop faster',
            title: 'Shop by Category',
            subtitle: 'Jump into curated shelves tailored to your routine.',
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (context, _) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final selected = i == _selectedCategory;
                final category = categories[i];
                return _CategoryPill(
                  label: category.name,
                  icon: category.icon,
                  selected: selected,
                  onTap: () => setState(() => _selectedCategory = i),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashSaleSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 34, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            badge: 'Limited window',
            title: 'Flash Sale',
            subtitle: 'High-demand picks with rapidly changing stock levels.',
            actionLabel: 'See All',
            onAction: () {},
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 350,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 6,
              separatorBuilder: (context, _) => const SizedBox(width: 14),
              itemBuilder: (context, i) {
                return SizedBox(
                  width: 250,
                  child: _FlashSaleCard(
                    index: i,
                    onAddToCart: (product) => _addToCart(
                      _CatalogProduct(
                        id: product.id,
                        name: product.name,
                        price: product.price,
                        rating: 4.6,
                        image: product.image,
                        backgroundColor: const Color(0xFFF5F8FF),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewArrivalsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 34, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            badge: 'Fresh this week',
            title: 'New Arrivals',
            subtitle: 'Recently launched products handpicked by the JGS team.',
            actionLabel: 'View All',
            onAction: () {},
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 350,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              separatorBuilder: (context, _) => const SizedBox(width: 14),
              itemBuilder: (context, i) {
                return SizedBox(
                  width: 250,
                  child: _ProductCard(
                    index: i + 5,
                    isNew: true,
                    onAddToCart: _addToCart,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

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
                    Color(0xFF0C1A4A),
                    Color(0xFF1B3378),
                    Color(0xFF2A4BA2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0D1B4B).withValues(alpha: 0.30),
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
                  final offsetX = -260 + 520 * _shineController.value;
                  return Transform.translate(
                    offset: Offset(offsetX, 0),
                    child: Container(
                      width: 180,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.white.withValues(alpha: 0),
                            Colors.white.withValues(alpha: 0.13),
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
                            'Best quality at affordable price',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Exclusive bundles with trusted brands, fast delivery, and genuine pricing every day.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accentColor,
                              foregroundColor: const Color(0xFF0D1B4B),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Explore Collection'),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Image.memory(LogoAssets.darkLogoBytes, height: 56),
                          const SizedBox(width: 22),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Best quality at affordable price',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.8,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Exclusive bundles with trusted brands, fast delivery, and genuine pricing every day.',
                                  style: TextStyle(
                                    color: Colors.white70,
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
                              backgroundColor: AppTheme.accentColor,
                              foregroundColor: const Color(0xFF0D1B4B),
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

  Widget _buildAllProductsSection(BuildContext context) {
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
            actionLabel: 'Browse All',
            onAction: () {},
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth >= 1140
                  ? 4
                  : constraints.maxWidth >= 820
                  ? 3
                  : constraints.maxWidth >= 480
                  ? 2
                  : 1;

              final aspectRatio = crossAxisCount == 1
                  ? 0.90
                  : crossAxisCount == 2
                  ? (constraints.maxWidth < 620 ? 0.55 : 0.62)
                  : 0.65;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 8,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: aspectRatio,
                ),
                itemBuilder: (context, i) {
                  return _ProductCard(index: i + 10, onAddToCart: _addToCart);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNewsletterSection(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 920;
    final tiny = width < 430;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 34, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF091739),
                      Color(0xFF142B74),
                      Color(0xFF1D4096),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Image.asset(
                'assets/images/hero_banner.png',
                fit: BoxFit.cover,
                opacity: const AlwaysStoppedAnimation(0.09),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      const Color(0xFF3CDDB2).withValues(alpha: 0.08),
                      Colors.transparent,
                      const Color(0xFF2E5BFF).withValues(alpha: 0.08),
                    ],
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
                    child: _GlowOrb(
                      size: compact ? 160 : 220,
                      color: const Color(0xFF44D7B6).withValues(alpha: 0.24),
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
                        _buildMembershipHeaderContent(
                          compact: true,
                          tiny: tiny,
                        ),
                        const SizedBox(height: 16),
                        _buildMembershipPanel(compact: true, tiny: tiny),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _buildMembershipHeaderContent(
                            compact: false,
                            tiny: false,
                          ),
                        ),
                        const SizedBox(width: 26),
                        Expanded(
                          flex: 2,
                          child: _buildMembershipPanel(
                            compact: false,
                            tiny: false,
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

  Widget _buildMembershipHeaderContent({
    required bool compact,
    required bool tiny,
  }) {
    final titleSize = compact ? (tiny ? 26.0 : 30.0) : 40.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.workspace_premium_outlined,
                color: AppTheme.accentColor,
                size: 16,
              ),
              SizedBox(width: 8),
              Text(
                'JGS MEMBERSHIP',
                style: TextStyle(
                  color: AppTheme.accentColor,
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
          'Join JGS Plus and shop smarter every week',
          style: TextStyle(
            color: Colors.white,
            fontSize: titleSize,
            fontWeight: FontWeight.w900,
            height: 1.08,
            letterSpacing: -0.9,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Unlock premium member pricing, early campaign access, and faster repeat checkout for your everyday essentials.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.82),
            fontSize: compact ? 14 : 15,
            height: 1.55,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildMembershipFeatureChip(
              icon: Icons.local_shipping_outlined,
              label: tiny ? 'Free shipping' : 'Free shipping perks',
            ),
            _buildMembershipFeatureChip(
              icon: Icons.flash_on_rounded,
              label: tiny ? 'Early access' : 'Early access to drops',
            ),
            _buildMembershipFeatureChip(
              icon: Icons.savings_outlined,
              label: tiny ? 'Bonus savings' : 'Bonus cashback vouchers',
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _MembershipMiniStat(value: '₹999', label: 'Avg monthly savings'),
            _MembershipMiniStat(value: '48h', label: 'Early access window'),
            _MembershipMiniStat(value: '2x', label: 'Reward points booster'),
          ],
        ),
      ],
    );
  }

  Widget _buildMembershipFeatureChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.accentColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembershipPanel({required bool compact, required bool tiny}) {
    return Container(
      padding: EdgeInsets.all(tiny ? 14 : 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
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
                  color: Colors.white.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.card_membership_rounded,
                  color: AppTheme.accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Membership Benefits',
                  style: TextStyle(
                    color: Colors.white,
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
                  color: AppTheme.accentColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'FREE',
                  style: TextStyle(
                    color: Color(0xFF0D1B4B),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const _MembershipBenefitRow(
            icon: Icons.check_circle_outline_rounded,
            label: 'Exclusive weekly member deals',
          ),
          const SizedBox(height: 8),
          const _MembershipBenefitRow(
            icon: Icons.check_circle_outline_rounded,
            label: 'Faster one-tap checkout flow',
          ),
          const SizedBox(height: 8),
          const _MembershipBenefitRow(
            icon: Icons.check_circle_outline_rounded,
            label: 'Priority support for orders and returns',
          ),
          const SizedBox(height: 14),
          compact
              ? Column(
                  children: [
                    _buildNewsletterInput(),
                    const SizedBox(height: 10),
                    _buildNewsletterButton(fullWidth: true),
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: _buildNewsletterInput()),
                    const SizedBox(width: 10),
                    _buildNewsletterButton(fullWidth: false),
                  ],
                ),
          const SizedBox(height: 8),
          Text(
            'No spam. One-click unsubscribe anytime.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.70),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsletterInput() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Enter your email address',
        hintStyle: const TextStyle(color: Color(0xFFB7C1E2)),
        prefixIcon: const Icon(
          Icons.mail_outline_rounded,
          color: Color(0xFFC5CEEA),
          size: 18,
        ),
        fillColor: Colors.white.withValues(alpha: 0.12),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppTheme.accentColor),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _buildNewsletterButton({required bool fullWidth}) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton.icon(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accentColor,
          foregroundColor: const Color(0xFF0D1B4B),
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

  Widget _buildFooter(BuildContext context, double contentWidth) {
    final compact = MediaQuery.sizeOf(context).width < 900;

    return Container(
      margin: const EdgeInsets.only(top: 34),
      padding: const EdgeInsets.fromLTRB(20, 46, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF081239), Color(0xFF101F58)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
                    Wrap(
                      spacing: 24,
                      runSpacing: 24,
                      children: const [
                        SizedBox(
                          width: 140,
                          child: _FooterColumn(
                            title: 'SHOP',
                            links: [
                              'Cosmetics',
                              'Skincare',
                              'Haircare',
                              'Fragrance',
                              'Deals',
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
                              'Shipping',
                              'FAQs',
                              'Contact Us',
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 140,
                          child: _FooterColumn(
                            title: 'CORPORATE',
                            links: [
                              'About JGS',
                              'Store Story',
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
                          'Cosmetics',
                          'Skincare',
                          'Haircare',
                          'Fragrance',
                          'Deals',
                        ],
                      ),
                    ),
                    const Expanded(
                      child: _FooterColumn(
                        title: 'HELP',
                        links: [
                          'Track Order',
                          'Returns',
                          'Shipping',
                          'FAQs',
                          'Contact Us',
                        ],
                      ),
                    ),
                    const Expanded(
                      child: _FooterColumn(
                        title: 'CORPORATE',
                        links: [
                          'About JGS',
                          'Store Story',
                          'Careers',
                          'Terms',
                          'Privacy',
                        ],
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 36),
              Divider(color: Colors.white.withValues(alpha: 0.1)),
              const SizedBox(height: 14),
              compact
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '© 2026 Jagdish General Store. All rights reserved.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.45),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.lock_outline_rounded,
                              color: Colors.white.withValues(alpha: 0.35),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Secure payments and COD available',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.45),
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
                              color: Colors.white.withValues(alpha: 0.45),
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Wrap(
                              spacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Icon(
                                  Icons.lock_outline_rounded,
                                  color: Colors.white.withValues(alpha: 0.35),
                                  size: 16,
                                ),
                                Text(
                                  'Secure payments and COD available',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.45),
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
        Image.memory(
          LogoAssets.darkLogoBytes,
          height: 44,
          color: Colors.white,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 18),
        const Text(
          'Jagdish General Store',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'A premium local commerce experience for cosmetics, skincare, and trusted daily essentials since 1995.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.68),
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
}

class _AnimatedBackdrop extends StatelessWidget {
  final Animation<double> animation;

  const _AnimatedBackdrop({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final phase = animation.value * math.pi * 2;
        final wave = math.sin(phase);
        final sway = math.cos(phase);

        return Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFF4F6FB), Color(0xFFEFF3FD)],
                ),
              ),
            ),
            Positioned(
              left: -90 + wave * 28,
              top: 90 + sway * 18,
              child: _GlowOrb(
                size: 240,
                color: const Color(0xFF2F6BFF).withValues(alpha: 0.12),
              ),
            ),
            Positioned(
              right: -120 + sway * 30,
              top: 240 + wave * 20,
              child: _GlowOrb(
                size: 300,
                color: const Color(0xFF00B8A9).withValues(alpha: 0.10),
              ),
            ),
            Positioned(
              left: 130 + sway * 18,
              bottom: -110 + wave * 24,
              child: _GlowOrb(
                size: 280,
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.08),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}

class _HeroTrustBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroTrustBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.accentColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MembershipMiniStat extends StatelessWidget {
  final String value;
  final String label;

  const _MembershipMiniStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.accentColor,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MembershipBenefitRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MembershipBenefitRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.accentColor, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.86),
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _GlassDealCard extends StatelessWidget {
  final double width;
  final double height;
  final IconData icon;
  final String title;
  final String value;

  const _GlassDealCard({
    required this.width,
    required this.height,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: width,
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.84),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
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
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 620;

        final titleBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEBF0FF),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: Color(0xFF3E5398),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF0D1B4B),
                fontSize: 30,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFF586A9A),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        );

        if (compact || actionLabel == null || onAction == null) {
          return titleBlock;
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: titleBlock),
            const SizedBox(width: 12),
            TextButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: Text(actionLabel!),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF0D1B4B),
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
  }
}

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
            color: _hovered
                ? widget.data.color.withValues(alpha: 0.35)
                : const Color(0xFFE2E8FA),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _hovered ? 0.10 : 0.04),
              blurRadius: _hovered ? 18 : 10,
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
                    (math.sin(widget.animation.value * math.pi * 2) + 1) * 0.06;
                return Transform.scale(
                  scale: pulse,
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: widget.data.color.withValues(alpha: 0.14),
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
                      color: Color(0xFF0D1B4B),
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.data.label,
                    style: const TextStyle(
                      color: Color(0xFF6072A6),
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

class _CategoryData {
  final String name;
  final IconData icon;

  const _CategoryData(this.name, this.icon);
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
                ? const Color(0xFF0D1B4B)
                : _hovered
                ? Colors.white
                : Colors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: widget.selected
                  ? const Color(0xFF0D1B4B)
                  : const Color(0xFFD8E0F3),
            ),
            boxShadow: [
              if (widget.selected || _hovered)
                BoxShadow(
                  color: const Color(
                    0xFF0D1B4B,
                  ).withValues(alpha: widget.selected ? 0.24 : 0.12),
                  blurRadius: widget.selected ? 14 : 10,
                  offset: const Offset(0, 6),
                ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 18,
                color: widget.selected
                    ? AppTheme.accentColor
                    : const Color(0xFF41588C),
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.selected
                      ? Colors.white
                      : const Color(0xFF223A70),
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
            color: _hovered
                ? Colors.white.withValues(alpha: 0.13)
                : Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: widget.compact
              ? Icon(widget.icon, color: Colors.white, size: 20)
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(widget.icon, color: Colors.white, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      widget.label,
                      style: const TextStyle(
                        color: Colors.white,
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

class _SaleProduct {
  final String id;
  final String name;
  final double price;
  final double originalPrice;
  final String discountTag;
  final String image;
  final double stock;

  const _SaleProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.originalPrice,
    required this.discountTag,
    required this.image,
    required this.stock,
  });
}

class _FlashSaleCard extends StatefulWidget {
  final int index;
  final ValueChanged<_SaleProduct> onAddToCart;

  const _FlashSaleCard({required this.index, required this.onAddToCart});

  @override
  State<_FlashSaleCard> createState() => _FlashSaleCardState();
}

class _FlashSaleCardState extends State<_FlashSaleCard> {
  bool _hovered = false;

  static const _products = [
    _SaleProduct(
      id: 'sale_foundation',
      name: 'Lakme Foundation',
      price: 499,
      originalPrice: 799,
      discountTag: '38%',
      image: 'assets/images/products/foundation.png',
      stock: 0.30,
    ),
    _SaleProduct(
      id: 'sale_facewash',
      name: 'Lotus Face Wash',
      price: 199,
      originalPrice: 299,
      discountTag: '33%',
      image: 'assets/images/products/facewash.png',
      stock: 0.80,
    ),
    _SaleProduct(
      id: 'sale_lipstick',
      name: 'Revlon Lipstick',
      price: 349,
      originalPrice: 549,
      discountTag: '36%',
      image: 'assets/images/products/lipstick.png',
      stock: 0.50,
    ),
    _SaleProduct(
      id: 'sale_serum',
      name: 'Biotique Serum',
      price: 279,
      originalPrice: 450,
      discountTag: '38%',
      image: 'assets/images/products/serum.png',
      stock: 0.20,
    ),
    _SaleProduct(
      id: 'sale_lotion',
      name: 'Nivea Body Lotion',
      price: 229,
      originalPrice: 375,
      discountTag: '39%',
      image: 'assets/images/products/foundation.png',
      stock: 0.90,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final product = _products[widget.index % _products.length];
    final lowStock = product.stock < 0.4;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.02 : 1,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _hovered
                  ? const Color(0xFFD2DCFA)
                  : const Color(0xFFE7ECFA),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _hovered ? 0.14 : 0.06),
                blurRadius: _hovered ? 28 : 14,
                offset: Offset(0, _hovered ? 12 : 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 158,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F9FF),
                        image: DecorationImage(
                          image: AssetImage(product.image),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(9),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.redAccent.withValues(alpha: 0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Text(
                          '${product.discountTag} OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF1C2C57),
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              '₹${product.price.toInt()}',
                              style: const TextStyle(
                                color: Color(0xFF0D1B4B),
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '₹${product.originalPrice.toInt()}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              lowStock ? 'Almost sold out' : 'In stock',
                              style: TextStyle(
                                color: lowStock ? Colors.red : Colors.green,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '${(product.stock * 100).toInt()}%',
                              style: const TextStyle(
                                color: Color(0xFF6C7DAE),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: product.stock,
                            minHeight: 6,
                            backgroundColor: const Color(0xFFEDF1FA),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              lowStock
                                  ? Colors.redAccent
                                  : const Color(0xFF0D1B4B),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () {},
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF25D366),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF25D366).withValues(alpha: 0.30),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: const FaIcon(
                                  FontAwesomeIcons.whatsapp,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            InkWell(
                              onTap: () => widget.onAddToCart(product),
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0D1B4B),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF0D1B4B).withValues(alpha: 0.30),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.add_shopping_cart_rounded,
                                  color: AppTheme.accentColor,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CatalogProduct {
  final String id;
  final String name;
  final double price;
  final double rating;
  final String image;
  final Color backgroundColor;

  const _CatalogProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.rating,
    required this.image,
    required this.backgroundColor,
  });
}

class _ProductCard extends StatefulWidget {
  final int index;
  final bool isNew;
  final ValueChanged<_CatalogProduct> onAddToCart;

  const _ProductCard({
    required this.index,
    required this.onAddToCart,
    this.isNew = false,
  });

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _hovered = false;
  bool _wishlisted = false;

  static const _products = [
    _CatalogProduct(
      id: 'catalog_cc_cream',
      name: 'Lakme CC Cream',
      price: 299,
      rating: 4.5,
      image: 'assets/images/products/foundation.png',
      backgroundColor: Color(0xFFFDF2F8),
    ),
    _CatalogProduct(
      id: 'catalog_shampoo',
      name: 'LOreal Shampoo',
      price: 349,
      rating: 4.2,
      image: 'assets/images/products/facewash.png',
      backgroundColor: Color(0xFFF0F9FF),
    ),
    _CatalogProduct(
      id: 'catalog_lipstick',
      name: 'Revlon Lipstick',
      price: 449,
      rating: 4.6,
      image: 'assets/images/products/lipstick.png',
      backgroundColor: Color(0xFFFAF5FF),
    ),
    _CatalogProduct(
      id: 'catalog_serum',
      name: 'Biotique Serum',
      price: 279,
      rating: 4.7,
      image: 'assets/images/products/serum.png',
      backgroundColor: Color(0xFFF5F3FF),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final product = _products[widget.index % _products.length];

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.015 : 1,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _hovered
                  ? const Color(0xFFD2DCFA)
                  : const Color(0xFFE7ECFA),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _hovered ? 0.14 : 0.06),
                blurRadius: _hovered ? 26 : 14,
                offset: Offset(0, _hovered ? 12 : 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 158,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: product.backgroundColor,
                        image: DecorationImage(
                          image: AssetImage(product.image),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    if (widget.isNew)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D1B4B),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'NEW',
                            style: TextStyle(
                              color: AppTheme.accentColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.9,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: InkWell(
                        onTap: () => setState(() => _wishlisted = !_wishlisted),
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _wishlisted
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 18,
                            color: _wishlisted
                                ? Colors.red
                                : const Color(0xFF8091BF),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF122656),
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: Colors.amber,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  product.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: Colors.amber,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '1.2k sold',
                            style: TextStyle(
                              color: Color(0xFF7888B5),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '₹${product.price.toInt()}',
                              style: const TextStyle(
                                color: Color(0xFF0D1B4B),
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              InkWell(
                                onTap: () {},
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF25D366),
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF25D366).withValues(alpha: 0.30),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: const FaIcon(
                                    FontAwesomeIcons.whatsapp,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              InkWell(
                                onTap: () => widget.onAddToCart(product),
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0D1B4B),
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF0D1B4B).withValues(alpha: 0.30),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.add_shopping_cart_rounded,
                                    color: AppTheme.accentColor,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
        color: Colors.white.withValues(alpha: 0.08),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Icon(icon, color: Colors.white70, size: 17),
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
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 16),
        ...links.map(
          (link) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              link,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
