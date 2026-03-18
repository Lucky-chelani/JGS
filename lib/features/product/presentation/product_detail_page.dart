import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../shared/models/product_model.dart';
import '../../../shared/models/review_model.dart';
import '../../cart/providers/cart_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/widgets/cart_toast.dart';

class ProductDetailPage extends StatefulWidget {
  final CatalogProduct product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  static const _bg = Color(0xFFFDF8F5);
  static const _textPrimary = Color(0xFF2D1B20);
  static const _textSecondary = Color(0xFF5A3A40);
  static const _border = Color(0xFFE8D5D0);
  static const _accent = Color(0xFFB76E79);
  static const _accentLight = Color(0xFFE8B4B8);

  bool _wishlisted = false;
  int _quantity = 1;
  int _selectedVariantIndex = 0;
  int _reviewRating = 5;
  bool _submittingReview = false;
  final TextEditingController _reviewController = TextEditingController();

  CatalogProduct get p => widget.product;

  ProductVariant? get _selectedVariant =>
      p.variants.isNotEmpty ? p.variants[_selectedVariantIndex] : null;

  double get _currentPrice => _selectedVariant?.sellingPrice ?? p.price;
  double? get _currentMrp => _selectedVariant?.mrp ?? p.originalPrice;
  bool get _hasDiscount => _currentMrp != null && _currentMrp! > _currentPrice;
  int get _discountPct =>
      _hasDiscount ? ((1 - _currentPrice / _currentMrp!) * 100).round() : 0;

  String _productUrl(String productId) {
    final path = '/#/product/${Uri.encodeComponent(productId)}';
    if (kIsWeb) {
      return '${Uri.base.origin}$path';
    }
    return 'https://jgs-store.web.app$path';
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _addToCart() {
    final cart = Provider.of<CartProvider>(context, listen: false);
    for (int i = 0; i < _quantity; i++) {
      cart.addItem(
        p.id,
        p.name,
        _currentPrice,
        p.image,
        variantLabel: _selectedVariant?.sizeLabel,
      );
    }
    showCartToast(context, p.name);
  }

  Future<void> _openWhatsApp() async {
    final productUrl = _productUrl(p.id);
    final message =
        'hey i want to enguiry about this product: ${p.name}\n$productUrl';
    final encodedMessage = Uri.encodeComponent(message);
    final whatsappUrl = 'https://wa.me/918770132554?text=$encodedMessage';

    try {
      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(
          Uri.parse(whatsappUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('WhatsApp is not installed on this device.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open WhatsApp. Please try again.'),
          ),
        );
      }
    }
  }

  Future<void> _submitReview() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (!auth.isLoggedIn || auth.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to submit your review.')),
      );
      context.push('/login');
      return;
    }

    final comment = _reviewController.text.trim();
    if (comment.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please write a review.')));
      return;
    }

    setState(() => _submittingReview = true);
    try {
      final review = ProductReview(
        id: '',
        productId: p.id,
        productName: p.name,
        userId: auth.user!.uid,
        userName: auth.profile.name.isNotEmpty
            ? auth.profile.name
            : (auth.user!.phoneNumber ?? 'User'),
        rating: _reviewRating,
        comment: comment,
      );

      final payload = review.toMap();
      payload['approved'] = false;
      payload['status'] = 'pending';

      await FirebaseFirestore.instance.collection('reviews').add(payload);

      if (!mounted) return;
      _reviewController.clear();
      setState(() => _reviewRating = 5);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thanks! Your review has been submitted.'),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not submit review. Try again.')),
      );
    }

    if (mounted) setState(() => _submittingReview = false);
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final screenW = MediaQuery.sizeOf(context).width;
    final isWide = screenW > 800;

    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          // ── App bar ──
          _buildAppBar(top),

          // ── Content ──
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: isWide ? _buildWideLayout() : _buildNarrowLayout(),
                ),
              ),
            ),
          ),

          // ── Bottom bar ──
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildAppBar(double top) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, top + 12, 20, 12),
      decoration: BoxDecoration(
        color: _bg,
        border: Border(
          bottom: BorderSide(color: _border.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.canPop() ? context.pop() : context.go('/'),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _textSecondary.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _border.withValues(alpha: 0.5)),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: _textPrimary,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Product Details',
              style: TextStyle(
                fontFamily: AppTheme.playfairFamily,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _wishlisted = !_wishlisted),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _textSecondary.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _border.withValues(alpha: 0.5)),
              ),
              child: Icon(
                _wishlisted ? Icons.favorite : Icons.favorite_border,
                color: _wishlisted
                    ? const Color(0xFFFF6B6B)
                    : const Color(0xFF8B6B70),
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => context.push('/cart'),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _textSecondary.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _border.withValues(alpha: 0.5)),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: _textPrimary,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Wide (desktop) layout: image left, info right ──
  Widget _buildWideLayout() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildImageSection()),
          const SizedBox(width: 40),
          Expanded(child: _buildInfoSection()),
        ],
      ),
    );
  }

  // ── Narrow (mobile) layout: stacked ──
  Widget _buildNarrowLayout() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageSection(),
          const SizedBox(height: 24),
          _buildInfoSection(),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5EDE8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _border.withValues(alpha: 0.5)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: p.image.isNotEmpty
                  ? (p.image.startsWith('http')
                        ? Image.network(
                            p.image,
                            fit: BoxFit.cover,
                            loadingBuilder: (_, child, progress) {
                              if (progress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: _accent,
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) => _imagePlaceholder(),
                          )
                        : Image.asset(p.image, fit: BoxFit.cover))
                  : _imagePlaceholder(),
            ),
            if (_hasDiscount)
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B6B),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$_discountPct% OFF',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFFF5EDE8),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 64,
          color: _accent.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Brand
        if (p.brand != null) ...[
          Text(
            p.brand!.toUpperCase(),
            style: TextStyle(
              color: _accent,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Name
        Text(
          p.name,
          style: TextStyle(
            fontFamily: AppTheme.playfairFamily,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
            height: 1.2,
          ),
        ),

        // Subtitle
        if (p.subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            p.subtitle!,
            style: TextStyle(
              color: _textSecondary.withValues(alpha: 0.6),
              fontSize: 15,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ],

        const SizedBox(height: 16),

        // Rating
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    p.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '1.2k ratings',
              style: TextStyle(
                color: _textSecondary.withValues(alpha: 0.5),
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '·',
              style: TextStyle(
                color: _textSecondary.withValues(alpha: 0.3),
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '1.2k sold',
              style: TextStyle(
                color: _textSecondary.withValues(alpha: 0.5),
                fontSize: 13,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Divider
        Container(height: 1, color: _border.withValues(alpha: 0.4)),

        const SizedBox(height: 20),

        // Price section
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\u20B9${_currentPrice.toInt()}',
              style: const TextStyle(
                color: _textPrimary,
                fontSize: 32,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (_hasDiscount) ...[
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '\u20B9${_currentMrp!.toInt()}',
                  style: TextStyle(
                    color: _textSecondary.withValues(alpha: 0.45),
                    fontSize: 18,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: _textSecondary.withValues(alpha: 0.45),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'Save \u20B9${(_currentMrp! - _currentPrice).toInt()}',
                  style: const TextStyle(
                    color: Color(0xFF4CAF50),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 6),
        Text(
          'Inclusive of all taxes',
          style: TextStyle(
            color: _textSecondary.withValues(alpha: 0.45),
            fontSize: 12,
          ),
        ),

        const SizedBox(height: 24),

        if (p.variants.isNotEmpty) ...[
          Text(
            'Select Size',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(p.variants.length, (index) {
              final v = p.variants[index];
              final selected = index == _selectedVariantIndex;
              return GestureDetector(
                onTap: () => setState(() => _selectedVariantIndex = index),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? _accent : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: selected ? _accent : _border),
                  ),
                  child: Text(
                    '${v.sizeLabel} · ₹${v.sellingPrice.toInt()}',
                    style: TextStyle(
                      color: selected ? Colors.white : _textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
        ],

        // Tags (category + concern)
        if (p.category != null || p.concern != null)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (p.category != null)
                _buildTag(p.category!, Icons.category_rounded),
              if (p.concern != null) _buildTag(p.concern!, Icons.spa_rounded),
            ],
          ),

        if (p.category != null || p.concern != null) const SizedBox(height: 24),

        // Description
        if (p.description != null) ...[
          Container(height: 1, color: _border.withValues(alpha: 0.4)),
          const SizedBox(height: 20),
          Text(
            'Description',
            style: TextStyle(
              fontFamily: AppTheme.playfairFamily,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            p.description!,
            style: TextStyle(
              color: _textSecondary.withValues(alpha: 0.7),
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
        ],

        Container(height: 1, color: _border.withValues(alpha: 0.4)),
        const SizedBox(height: 20),
        Text(
          'Customer Reviews',
          style: TextStyle(
            fontFamily: AppTheme.playfairFamily,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        _buildReviewComposer(),
        const SizedBox(height: 12),
        _buildReviewList(),
        const SizedBox(height: 24),

        // Quantity selector
        Row(
          children: [
            Text(
              'Quantity',
              style: TextStyle(
                color: _textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _qtyButton(Icons.remove_rounded, () {
                    if (_quantity > 1) setState(() => _quantity--);
                  }),
                  Container(
                    width: 44,
                    alignment: Alignment.center,
                    child: Text(
                      '$_quantity',
                      style: const TextStyle(
                        color: _textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  _qtyButton(Icons.add_rounded, () {
                    if (_quantity < 10) setState(() => _quantity++);
                  }),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 28),

        // Delivery info
        _buildInfoRow(
          Icons.local_shipping_outlined,
          'Free delivery on orders above \u20B9499',
        ),
        const SizedBox(height: 12),
        _buildInfoRow(Icons.refresh_rounded, '7-day easy returns'),
        const SizedBox(height: 12),
        _buildInfoRow(Icons.verified_outlined, '100% Authentic Products'),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTag(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: _accentLight.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _accentLight.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _accent),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: _accent,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        child: Icon(icon, size: 18, color: _textSecondary),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: _accent),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            color: _textSecondary.withValues(alpha: 0.7),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewComposer() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 4,
            children: List.generate(5, (i) {
              final value = i + 1;
              return IconButton(
                onPressed: () => setState(() => _reviewRating = value),
                icon: Icon(
                  value <= _reviewRating
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: Colors.amber,
                ),
                visualDensity: VisualDensity.compact,
                splashRadius: 20,
              );
            }),
          ),
          TextField(
            controller: _reviewController,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Share your experience with this product...',
              isDense: true,
              filled: true,
              fillColor: const Color(0xFFFDF8F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: _border.withValues(alpha: 0.8)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: _border.withValues(alpha: 0.8)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: _submittingReview ? null : _submitReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: Colors.white,
              ),
              child: Text(_submittingReview ? 'Posting...' : 'Post Review'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewList() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('reviews')
          .where('productId', isEqualTo: p.id)
          .limit(30)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LinearProgressIndicator(minHeight: 2);
        }
        if (snapshot.hasError) {
          return Text(
            'Unable to load reviews right now.',
            style: TextStyle(
              color: _textSecondary.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          );
        }

        final reviews = (snapshot.data?.docs ?? const [])
            .map((d) => ProductReview.fromMap(d.id, d.data()))
            .where((r) => r.comment.trim().isNotEmpty)
            .toList();
        final auth = Provider.of<AuthProvider>(context, listen: false);
        final reviewMap = <String, Map<String, dynamic>>{};
        for (final d in (snapshot.data?.docs ?? const [])) {
          reviewMap[d.id] = d.data();
        }
        final filtered = reviews.where((r) {
          final raw = reviewMap[r.id];
          final approved = raw?['approved'] == true;
          if (approved) return true;
          return auth.user != null && auth.user!.uid == r.userId;
        }).toList();
        filtered.sort((a, b) {
          final aTime = a.createdAt?.millisecondsSinceEpoch ?? 0;
          final bTime = b.createdAt?.millisecondsSinceEpoch ?? 0;
          return bTime.compareTo(aTime);
        });

        if (filtered.isEmpty) {
          return Text(
            'No reviews yet. Be the first to review this product.',
            style: TextStyle(
              color: _textSecondary.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          );
        }

        return Column(
          children: filtered.take(6).map((r) {
            final raw = reviewMap[r.id];
            final approved = raw?['approved'] == true;
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9F8),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _border.withValues(alpha: 0.75)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          r.userName,
                          style: const TextStyle(
                            color: _textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (!approved)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFFF9800,
                            ).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'Pending',
                            style: TextStyle(
                              color: Color(0xFFEF6C00),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ...List.generate(
                        5,
                        (i) => Icon(
                          i < r.rating
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          size: 14,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    r.comment,
                    style: TextStyle(
                      color: _textSecondary.withValues(alpha: 0.78),
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    final bottom = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 14, 20, bottom + 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _border.withValues(alpha: 0.5))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Row(
            children: [
              // WhatsApp button
                GestureDetector(
                  onTap: _openWhatsApp,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF25D366).withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: FaIcon(
                      FontAwesomeIcons.whatsapp,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Add to cart button
              Expanded(
                child: GestureDetector(
                  onTap: _addToCart,
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: _accent,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: _accent.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.add_shopping_cart_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Add to Bag  ·  \u20B9${(_currentPrice * _quantity).toInt()}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
