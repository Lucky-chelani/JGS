import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/product_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  SHARED PRODUCT CARD — used across home screen, category page, etc.
// ─────────────────────────────────────────────────────────────────────────────

class ProductCard extends StatefulWidget {
  final CatalogProduct product;
  final String? badge;
  final Color? badgeColor;
  final Color? badgeTextColor;
  final ValueChanged<CatalogProduct> onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    this.badge,
    this.badgeColor,
    this.badgeTextColor,
    required this.onAddToCart,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _hovered = false;
  bool _wishlisted = false;

  String _productUrl(String productId) {
    final path = '/#/product/${Uri.encodeComponent(productId)}';
    if (kIsWeb) {
      return '${Uri.base.origin}$path';
    }
    return 'https://jgs-store.web.app$path';
  }

  Future<void> _openWhatsAppForProduct(CatalogProduct product) async {
    final productUrl = _productUrl(product.id);
    final message =
        'hey i want to enguiry about this product: ${product.name}\n$productUrl';
    final encodedMessage = Uri.encodeComponent(message);
    final whatsappUrl = 'https://wa.me/918770132554?text=$encodedMessage';

    try {
      final uri = Uri.parse(whatsappUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('WhatsApp is not installed on this device.'),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open WhatsApp. Please try again.'),
        ),
      );
    }
  }

  String _soldLabel(String productId) {
    final seed = productId.hashCode.abs();
    final sold = 600 + (seed % 2400);
    if (sold >= 1000) {
      return '${(sold / 1000).toStringAsFixed(1)}k sold';
    }
    return '$sold sold';
  }

  Widget _buildProductImage(String image) {
    if (image.isEmpty) {
      return Container(color: const Color(0xFFF5EDE8));
    }

    if (image.startsWith('http')) {
      return Image.network(
        image,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.low,
        cacheWidth: 640,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            color: const Color(0xFFF5EDE8),
            alignment: Alignment.center,
            child: const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (context, _, __) => Container(
          color: const Color(0xFFF5EDE8),
          alignment: Alignment.center,
          child: const Icon(
            Icons.image_not_supported_outlined,
            color: Color(0xFFBFA8A1),
            size: 26,
          ),
        ),
      );
    }

    return Image.asset(
      image,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.low,
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final displayPrice = p.effectivePrice;
    final displayOriginal = p.effectiveOriginalPrice;
    final hasDiscount =
        displayOriginal != null && displayOriginal > displayPrice;
    final discountPct = hasDiscount
        ? ((1 - displayPrice / displayOriginal) * 100).round()
        : 0;

    return GestureDetector(
      onTap: () => context.push('/product', extra: p),
      child: MouseRegion(
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
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Color(
                  0xFFE8D5D0,
                ).withValues(alpha: _hovered ? 0.80 : 0.50),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(
                    0xFFE8B4B8,
                  ).withValues(alpha: _hovered ? 0.15 : 0.06),
                  blurRadius: _hovered ? 28 : 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Image area ──
                  Stack(
                    children: [
                      SizedBox(
                        height: 160,
                        width: double.infinity,
                        child: _buildProductImage(p.image),
                      ),
                      if (widget.badge != null)
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: widget.badgeColor ?? Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: (widget.badgeColor ?? Colors.white)
                                      .withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              widget.badge!,
                              style: TextStyle(
                                color:
                                    widget.badgeTextColor ??
                                    const Color(0xFF1A0E1E),
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ),
                      if (p.brand != null && p.brand!.trim().isNotEmpty)
                        Positioned(
                          left: 10,
                          bottom: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.88),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              p.brand!,
                              style: const TextStyle(
                                color: Color(0xFF2D1B20),
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      if (hasDiscount)
                        Positioned(
                          top: 10,
                          right: 48,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B6B),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$discountPct% OFF',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _wishlisted = !_wishlisted),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.85),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(
                                  0xFFE8D5D0,
                                ).withValues(alpha: 0.50),
                              ),
                            ),
                            child: Icon(
                              _wishlisted
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 16,
                              color: _wishlisted
                                  ? const Color(0xFFFF6B6B)
                                  : const Color(0xFF8B6B70),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // ── Info area ──
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF2D1B20),
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (p.subtitle != null) ...[
                            const SizedBox(height: 3),
                            Text(
                              p.subtitle!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: const Color(
                                  0xFF5A3A40,
                                ).withValues(alpha: 0.55),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      color: Colors.amber,
                                      size: 13,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      p.rating.toStringAsFixed(1),
                                      style: const TextStyle(
                                        color: Colors.amber,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _soldLabel(p.id),
                                style: TextStyle(
                                  color: const Color(
                                    0xFF5A3A40,
                                  ).withValues(alpha: 0.50),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          if (p.variants.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9EFF0),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFE8D5D0),
                                ),
                              ),
                              child: Text(
                                'Size: ${p.variants.first.sizeLabel}',
                                style: const TextStyle(
                                  color: Color(0xFF8B6B70),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '\u20B9${displayPrice.toInt()}',
                                      style: const TextStyle(
                                        color: Color(0xFF2D1B20),
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    if (hasDiscount)
                                      Text(
                                        '\u20B9${displayOriginal.toInt()}',
                                        style: TextStyle(
                                          color: const Color(
                                            0xFF5A3A40,
                                          ).withValues(alpha: 0.45),
                                          fontSize: 12,
                                          decoration:
                                              TextDecoration.lineThrough,
                                          decorationColor: const Color(
                                            0xFF5A3A40,
                                          ).withValues(alpha: 0.45),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () => _openWhatsAppForProduct(p),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(9),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF25D366),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF25D366,
                                        ).withValues(alpha: 0.30),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const FaIcon(
                                    FontAwesomeIcons.whatsapp,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () => widget.onAddToCart(p),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(9),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFE8B4B8,
                                    ).withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(
                                        0xFFE8B4B8,
                                      ).withValues(alpha: 0.30),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.add_shopping_cart_rounded,
                                    color: Color(0xFFE8B4B8),
                                    size: 18,
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
      ),
    );
  }
}
