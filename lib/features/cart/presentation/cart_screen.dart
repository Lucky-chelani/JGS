import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _couponController = TextEditingController();
  String? _appliedCoupon;
  double _couponDiscount = 0;
  String? _couponError;

  static const _bg = Color(0xFFFDF8F5);
  static const _textPrimary = Color(0xFF2D1B20);
  static const _textSecondary = Color(0xFF5A3A40);
  static const _border = Color(0xFFE8D5D0);
  static const _accent = Color(0xFFB76E79);
  static const _accentLight = Color(0xFFE8B4B8);

  // Dummy coupons
  static const Map<String, double> _coupons = {
    'BEAUTY10': 10,
    'JGS20': 20,
    'FIRST50': 50,
  };

  void _applyCoupon() {
    final code = _couponController.text.trim().toUpperCase();
    if (code.isEmpty) return;
    final discount = _coupons[code];
    if (discount != null) {
      setState(() {
        _appliedCoupon = code;
        _couponDiscount = discount;
        _couponError = null;
      });
    } else {
      setState(() {
        _couponError = 'Invalid coupon code';
        _appliedCoupon = null;
        _couponDiscount = 0;
      });
    }
  }

  void _removeCoupon() {
    setState(() {
      _appliedCoupon = null;
      _couponDiscount = 0;
      _couponController.clear();
      _couponError = null;
    });
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: _bg,
      body: cart.items.isEmpty
          ? _buildEmptyCart(context, top)
          : _buildCartContent(context, cart, top),
    );
  }

  Widget _buildEmptyCart(BuildContext context, double top) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _accent.withValues(alpha: 0.08),
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 56,
                color: _accent.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Your bag is empty',
              style: TextStyle(
                fontFamily: AppTheme.playfairFamily,
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Looks like you haven\'t added\nanything to your bag yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _textSecondary.withValues(alpha: 0.6),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 220,
              height: 52,
              child: ElevatedButton(
                onPressed: () => context.go('/'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Start Shopping',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartContent(
    BuildContext context,
    CartProvider cart,
    double top,
  ) {
    final subtotal = cart.totalAmount;
    final discount = _couponDiscount;
    final total = (subtotal - discount).clamp(0, double.infinity);

    return Column(
      children: [
        // ── App bar ──
        Container(
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
                  'My Bag',
                  style: TextStyle(
                    fontFamily: AppTheme.playfairFamily,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  ),
                ),
              ),
              Text(
                '${cart.totalQuantity} items',
                style: TextStyle(
                  color: _textSecondary.withValues(alpha: 0.6),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        // ── Cart items ──
        Expanded(
          child: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cart item cards
                      ...cart.items.entries.map(
                        (entry) => _CartItemCard(
                          productId: entry.key,
                          item: entry.value,
                          cart: cart,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // ── Add more products ──
                      GestureDetector(
                        onTap: () => context.push(
                          '/category',
                          extra: <String, dynamic>{'title': 'All Products'},
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 20,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: _accent.withValues(alpha: 0.3),
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_rounded, size: 20, color: _accent),
                              const SizedBox(width: 8),
                              Text(
                                'Add More Products',
                                style: TextStyle(
                                  color: _accent,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Coupon section ──
                      Text(
                        'Apply Coupon',
                        style: TextStyle(
                          color: _textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_appliedCoupon != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 18,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF4CAF50,
                            ).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(
                                0xFF4CAF50,
                              ).withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.local_offer_rounded,
                                color: Color(0xFF4CAF50),
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _appliedCoupon!,
                                      style: const TextStyle(
                                        color: Color(0xFF4CAF50),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '₹${_couponDiscount.toStringAsFixed(0)} off applied',
                                      style: TextStyle(
                                        color: const Color(
                                          0xFF4CAF50,
                                        ).withValues(alpha: 0.7),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: _removeCoupon,
                                child: const Icon(
                                  Icons.close_rounded,
                                  color: Color(0xFF4CAF50),
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _couponError != null
                                  ? const Color(0xFFFF6B6B)
                                  : _border.withValues(alpha: 0.6),
                            ),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 16),
                              Icon(
                                Icons.local_offer_outlined,
                                size: 20,
                                color: _textSecondary.withValues(alpha: 0.4),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _couponController,
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  style: const TextStyle(
                                    color: _textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Enter coupon code',
                                    hintStyle: TextStyle(
                                      color: _textSecondary.withValues(
                                        alpha: 0.35,
                                      ),
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                  ),
                                  onChanged: (_) {
                                    if (_couponError != null) {
                                      setState(() => _couponError = null);
                                    }
                                  },
                                ),
                              ),
                              GestureDetector(
                                onTap: _applyCoupon,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _accent,
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(15),
                                      bottomRight: Radius.circular(15),
                                    ),
                                  ),
                                  child: const Text(
                                    'Apply',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      if (_couponError != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _couponError!,
                          style: const TextStyle(
                            color: Color(0xFFFF6B6B),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // ── Price Summary ──
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: _border.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildPriceRow(
                              'Subtotal',
                              '₹${subtotal.toStringAsFixed(2)}',
                            ),
                            const SizedBox(height: 12),
                            _buildPriceRow(
                              'Delivery',
                              'FREE',
                              valueColor: const Color(0xFF4CAF50),
                            ),
                            if (_couponDiscount > 0) ...[
                              const SizedBox(height: 12),
                              _buildPriceRow(
                                'Coupon ($_appliedCoupon)',
                                '-₹${discount.toStringAsFixed(2)}',
                                valueColor: const Color(0xFF4CAF50),
                              ),
                            ],
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Divider(
                                color: _border.withValues(alpha: 0.5),
                                height: 1,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total',
                                  style: TextStyle(
                                    fontFamily: AppTheme.playfairFamily,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: _textPrimary,
                                  ),
                                ),
                                Text(
                                  '₹${total.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontFamily: AppTheme.playfairFamily,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: _accent,
                                  ),
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
          ),
        ),

        // ── Bottom bar ──
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: _border.withValues(alpha: 0.5)),
            ),
            boxShadow: [
              BoxShadow(
                color: _accentLight.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total',
                            style: TextStyle(
                              color: _textSecondary.withValues(alpha: 0.6),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '₹${total.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontFamily: AppTheme.playfairFamily,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: _textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => context.push('/checkout'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 36),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Text(
                              'Checkout',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 20),
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
      ],
    );
  }

  Widget _buildPriceRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: _textSecondary.withValues(alpha: 0.7),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? _textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final String productId;
  final CartItem item;
  final CartProvider cart;

  const _CartItemCard({
    required this.productId,
    required this.item,
    required this.cart,
  });

  @override
  Widget build(BuildContext context) {
    const textPrimary = Color(0xFF2D1B20);
    const textSecondary = Color(0xFF5A3A40);
    const border = Color(0xFFE8D5D0);
    const accent = Color(0xFFB76E79);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE8B4B8).withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFFDF8F5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: border.withValues(alpha: 0.4)),
            ),
            child: item.imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: Image.network(
                      item.imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFB76E79),
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.shopping_bag_outlined,
                        size: 32,
                        color: accent.withValues(alpha: 0.4),
                      ),
                    ),
                  )
                : Icon(
                    Icons.shopping_bag_outlined,
                    size: 32,
                    color: accent.withValues(alpha: 0.4),
                  ),
          ),
          const SizedBox(width: 14),

          // Title + price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '₹${item.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: accent,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Quantity controls
          Column(
            children: [
              // Delete button
              GestureDetector(
                onTap: () => cart.removeItem(productId),
                child: Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                  color: textSecondary.withValues(alpha: 0.4),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF8F5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: border.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => cart.removeSingleItem(productId),
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.remove_rounded,
                          size: 18,
                          color: textSecondary,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          color: textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => cart.addItem(
                        productId,
                        item.title,
                        item.price,
                        item.imageUrl,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(Icons.add_rounded, size: 18, color: accent),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
