import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final hasDiscount = p.originalPrice != null && p.originalPrice! > p.price;
    final discountPct = hasDiscount
        ? ((1 - p.price / p.originalPrice!) * 100).round()
        : 0;

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
                    Container(
                      height: 160,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5EDE8),
                        image: DecorationImage(
                          image: AssetImage(p.image),
                          fit: BoxFit.cover,
                        ),
                      ),
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
                        onTap: () => setState(() => _wishlisted = !_wishlisted),
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
                              '1.2k sold',
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
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '\u20B9${p.price.toInt()}',
                                    style: const TextStyle(
                                      color: Color(0xFF2D1B20),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  if (hasDiscount)
                                    Text(
                                      '\u20B9${p.originalPrice!.toInt()}',
                                      style: TextStyle(
                                        color: const Color(
                                          0xFF5A3A40,
                                        ).withValues(alpha: 0.45),
                                        fontSize: 12,
                                        decoration: TextDecoration.lineThrough,
                                        decorationColor: const Color(
                                          0xFF5A3A40,
                                        ).withValues(alpha: 0.45),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () {},
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
    );
  }
}
