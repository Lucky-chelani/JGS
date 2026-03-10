import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  static const _bg = Color(0xFFFDF8F5);
  static const _textPrimary = Color(0xFF2D1B20);
  static const _textSecondary = Color(0xFF5A3A40);
  static const _border = Color(0xFFE8D5D0);
  static const _accent = Color(0xFFB76E79);

  // Dummy orders for display
  static final List<_Order> _orders = [
    _Order(
      id: 'JGS-10234',
      date: 'Mar 8, 2026',
      status: 'Delivered',
      statusColor: const Color(0xFF4CAF50),
      total: 1299.0,
      items: [
        _OrderItem('Lakme 9to5 Primer + Matte Lipstick', 1, 649.0),
        _OrderItem('Maybelline Fit Me Foundation', 1, 650.0),
      ],
    ),
    _Order(
      id: 'JGS-10198',
      date: 'Mar 3, 2026',
      status: 'Shipped',
      statusColor: const Color(0xFF2196F3),
      total: 875.0,
      items: [
        _OrderItem('L\'Oreal Paris Hyaluron Moisture Shampoo', 1, 475.0),
        _OrderItem('Nivea Soft Cream', 2, 400.0),
      ],
    ),
    _Order(
      id: 'JGS-10152',
      date: 'Feb 22, 2026',
      status: 'Delivered',
      statusColor: const Color(0xFF4CAF50),
      total: 2150.0,
      items: [
        _OrderItem('Biotique Bio Papaya Face Wash', 1, 250.0),
        _OrderItem('Forest Essentials Night Cream', 1, 1900.0),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: _bg,
      body: Column(
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
                  onTap: () =>
                      context.canPop() ? context.pop() : context.go('/'),
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
                    'My Orders',
                    style: TextStyle(
                      fontFamily: AppTheme.playfairFamily,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Orders list ──
          Expanded(
            child: _orders.isEmpty
                ? _buildEmptyState(context)
                : SingleChildScrollView(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                          child: Column(
                            children: _orders
                                .map((order) => _OrderCard(order: order))
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
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
              Icons.receipt_long_outlined,
              size: 56,
              color: _accent.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No orders yet',
            style: TextStyle(
              fontFamily: AppTheme.playfairFamily,
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your order history will appear here\nonce you make your first purchase',
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
    );
  }
}

// ── Models ──

class _Order {
  final String id;
  final String date;
  final String status;
  final Color statusColor;
  final double total;
  final List<_OrderItem> items;

  const _Order({
    required this.id,
    required this.date,
    required this.status,
    required this.statusColor,
    required this.total,
    required this.items,
  });
}

class _OrderItem {
  final String name;
  final int qty;
  final double price;

  const _OrderItem(this.name, this.qty, this.price);
}

// ── Order Card Widget ──

class _OrderCard extends StatelessWidget {
  final _Order order;

  const _OrderCard({required this.order});

  static const _textPrimary = Color(0xFF2D1B20);
  static const _textSecondary = Color(0xFF5A3A40);
  static const _border = Color(0xFFE8D5D0);
  static const _accent = Color(0xFFB76E79);
  static const _accentLight = Color(0xFFE8B4B8);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: _accentLight.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
            child: Row(
              children: [
                // Order icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.local_shipping_outlined,
                    color: _accent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.id,
                        style: const TextStyle(
                          color: _textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        order.date,
                        style: TextStyle(
                          color: _textSecondary.withValues(alpha: 0.5),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: order.statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.status,
                    style: TextStyle(
                      color: order.statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(color: _border.withValues(alpha: 0.4), height: 1),

          // Items
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 4),
            child: Column(
              children: order.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDF8F5),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _border.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          size: 18,
                          color: _accent.withValues(alpha: 0.4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: _textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Qty: ${item.qty}',
                              style: TextStyle(
                                color: _textSecondary.withValues(alpha: 0.5),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '₹${item.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: _textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          Divider(color: _border.withValues(alpha: 0.4), height: 1),

          // Footer
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: TextStyle(
                    color: _textSecondary.withValues(alpha: 0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '₹${order.total.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontFamily: AppTheme.playfairFamily,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _accent,
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
