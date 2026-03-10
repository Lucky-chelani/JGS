import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../../../shared/models/product_model.dart';
import '../../../shared/models/announcement_model.dart';
import '../providers/admin_provider.dart';

// ═════════════════════════════════════════════════════════════════════════════
//  ADMIN SCREEN — Main Shell
// ═════════════════════════════════════════════════════════════════════════════

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _tab = 0;

  static const _bg = Color(0xFFFDF8F5);
  static const _textSecondary = Color(0xFF5A3A40);
  static const _border = Color(0xFFE8D5D0);
  static const _accent = Color(0xFFB76E79);

  static const _tabs = [
    _TabDef(Icons.dashboard_rounded, 'Dashboard'),
    _TabDef(Icons.inventory_2_outlined, 'Products'),
    _TabDef(Icons.campaign_outlined, 'Announce'),
    _TabDef(Icons.shopping_bag_outlined, 'Orders'),
    _TabDef(Icons.sms_outlined, 'Alerts'),
  ];

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final compact = w < 720;
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          // ── Top bar ──
          Container(
            padding: EdgeInsets.fromLTRB(20, top + 10, 20, 10),
            decoration: BoxDecoration(
              color: const Color(0xFF2D1B20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white70,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  'JGS Admin',
                  style: TextStyle(
                    fontFamily: AppTheme.playfairFamily,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Admin',
                    style: TextStyle(
                      color: Color(0xFFE8B4B8),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Body ──
          Expanded(child: compact ? _buildCompactLayout() : _buildWideLayout()),
        ],
      ),
      bottomNavigationBar: compact
          ? Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: _border.withValues(alpha: 0.5)),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(_tabs.length, (i) {
                      final selected = _tab == i;
                      return GestureDetector(
                        onTap: () => setState(() => _tab = i),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _tabs[i].icon,
                              size: 22,
                              color: selected
                                  ? _accent
                                  : _textSecondary.withValues(alpha: 0.4),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _tabs[i].label,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: selected
                                    ? _accent
                                    : _textSecondary.withValues(alpha: 0.4),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildCompactLayout() {
    return IndexedStack(
      index: _tab,
      children: const [
        _DashboardTab(),
        _ProductsTab(),
        _AnnouncementsTab(),
        _OrdersTab(),
        _AlertsTab(),
      ],
    );
  }

  Widget _buildWideLayout() {
    return Row(
      children: [
        // Side rail
        Container(
          width: 200,
          color: Colors.white,
          child: Column(
            children: List.generate(_tabs.length, (i) {
              final selected = _tab == i;
              return GestureDetector(
                onTap: () => setState(() => _tab = i),
                child: Container(
                  margin: const EdgeInsets.fromLTRB(10, 6, 10, 0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? _accent.withValues(alpha: 0.08) : null,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _tabs[i].icon,
                        size: 20,
                        color: selected
                            ? _accent
                            : _textSecondary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _tabs[i].label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: selected
                              ? _accent
                              : _textSecondary.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        VerticalDivider(width: 1, color: _border.withValues(alpha: 0.5)),
        Expanded(
          child: IndexedStack(
            index: _tab,
            children: const [
              _DashboardTab(),
              _ProductsTab(),
              _AnnouncementsTab(),
              _OrdersTab(),
              _AlertsTab(),
            ],
          ),
        ),
      ],
    );
  }
}

class _TabDef {
  final IconData icon;
  final String label;
  const _TabDef(this.icon, this.label);
}

// ═════════════════════════════════════════════════════════════════════════════
//  1. DASHBOARD TAB
// ═════════════════════════════════════════════════════════════════════════════

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    final admin = Provider.of<AdminProvider>(context);
    final pending = admin.orders.where((o) => o.status == 'Pending').length;
    final confirmed = admin.orders.where((o) => o.status == 'Confirmed').length;
    final revenue = admin.orders.fold<double>(0, (sum, o) => sum + o.total);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard',
                style: TextStyle(
                  fontFamily: AppTheme.playfairFamily,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2D1B20),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Overview of your store',
                style: TextStyle(
                  color: const Color(0xFF5A3A40).withValues(alpha: 0.6),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _StatCard(
                    'Products',
                    '${admin.products.length}',
                    Icons.inventory_2_outlined,
                    const Color(0xFF4CAF50),
                  ),
                  _StatCard(
                    'Announcements',
                    '${admin.announcements.length}',
                    Icons.campaign_outlined,
                    const Color(0xFF2196F3),
                  ),
                  _StatCard(
                    'Total Orders',
                    '${admin.orders.length}',
                    Icons.shopping_bag_outlined,
                    const Color(0xFFFF9800),
                  ),
                  _StatCard(
                    'Pending',
                    '$pending',
                    Icons.hourglass_empty_rounded,
                    const Color(0xFFFF5722),
                  ),
                  _StatCard(
                    'Confirmed',
                    '$confirmed',
                    Icons.check_circle_outline,
                    const Color(0xFF9C27B0),
                  ),
                  _StatCard(
                    'Revenue',
                    '₹${revenue.toStringAsFixed(0)}',
                    Icons.currency_rupee_rounded,
                    const Color(0xFFB76E79),
                  ),
                  _StatCard(
                    'SMS Sent',
                    '${admin.sentAlerts.length}',
                    Icons.sms_outlined,
                    const Color(0xFF607D8B),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                'Recent Orders',
                style: TextStyle(
                  fontFamily: AppTheme.playfairFamily,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2D1B20),
                ),
              ),
              const SizedBox(height: 14),
              ...admin.orders
                  .take(5)
                  .map(
                    (o) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFE8D5D0).withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  o.id,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${o.customerName} · ${o.date}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: const Color(
                                      0xFF5A3A40,
                                    ).withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _StatusBadge(o.status),
                          const SizedBox(width: 12),
                          Text(
                            '₹${o.total.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
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
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 165,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE8D5D0).withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE8B4B8).withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppTheme.playfairFamily,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF2D1B20),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: const Color(0xFF5A3A40).withValues(alpha: 0.6),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge(this.status);

  Color get _color {
    switch (status) {
      case 'Delivered':
        return const Color(0xFF4CAF50);
      case 'Shipped':
        return const Color(0xFF2196F3);
      case 'Confirmed':
        return const Color(0xFF9C27B0);
      case 'Cancelled':
        return const Color(0xFFFF5722);
      default:
        return const Color(0xFFFF9800);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: _color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  2. PRODUCTS TAB
// ═════════════════════════════════════════════════════════════════════════════

class _ProductsTab extends StatelessWidget {
  const _ProductsTab();

  @override
  Widget build(BuildContext context) {
    final admin = Provider.of<AdminProvider>(context);
    final products = admin.products;

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Products (${products.length})',
                  style: TextStyle(
                    fontFamily: AppTheme.playfairFamily,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D1B20),
                  ),
                ),
              ),
              _AdminButton(
                icon: Icons.add_rounded,
                label: 'Add Product',
                onTap: () => _showProductDialog(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: products.isEmpty
              ? const Center(
                  child: Text('No products yet. Add your first product!'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  itemCount: products.length,
                  itemBuilder: (_, i) {
                    final p = products[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFE8D5D0).withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDF8F5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.shopping_bag_outlined,
                              color: Color(0xFFB76E79),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${p.brand ?? 'No brand'} · ${p.category ?? 'Uncategorized'} · ₹${p.price.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: const Color(
                                      0xFF5A3A40,
                                    ).withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            color: const Color(
                              0xFF5A3A40,
                            ).withValues(alpha: 0.5),
                            onPressed: () =>
                                _showProductDialog(context, product: p),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              size: 20,
                            ),
                            color: const Color(
                              0xFFFF5722,
                            ).withValues(alpha: 0.6),
                            onPressed: () {
                              admin.deleteProduct(p.id);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showProductDialog(BuildContext context, {CatalogProduct? product}) {
    final isEdit = product != null;
    final nameC = TextEditingController(text: product?.name ?? '');
    final priceC = TextEditingController(
      text: product?.price.toStringAsFixed(0) ?? '',
    );
    final origPriceC = TextEditingController(
      text: product?.originalPrice?.toStringAsFixed(0) ?? '',
    );
    final brandC = TextEditingController(text: product?.brand ?? '');
    final subtitleC = TextEditingController(text: product?.subtitle ?? '');
    String category = product?.category ?? 'Makeup';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: const Color(0xFFFDF8F5),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEdit ? 'Edit Product' : 'Add Product',
                    style: TextStyle(
                      fontFamily: AppTheme.playfairFamily,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2D1B20),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _DialogField(controller: nameC, label: 'Product Name'),
                  const SizedBox(height: 12),
                  _DialogField(controller: brandC, label: 'Brand'),
                  const SizedBox(height: 12),
                  _DialogField(
                    controller: subtitleC,
                    label: 'Subtitle / Description',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _DialogField(
                          controller: priceC,
                          label: 'Price (₹)',
                          isNumber: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DialogField(
                          controller: origPriceC,
                          label: 'MRP (₹)',
                          isNumber: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF5A3A40).withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        [
                              'Makeup',
                              'Skincare',
                              'Haircare',
                              'Fragrance',
                              'Bath & Body',
                            ]
                            .map(
                              (c) => GestureDetector(
                                onTap: () => setDialogState(() => category = c),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: category == c
                                        ? const Color(0xFFB76E79)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: category == c
                                          ? const Color(0xFFB76E79)
                                          : const Color(0xFFE8D5D0),
                                    ),
                                  ),
                                  child: Text(
                                    c,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: category == c
                                          ? Colors.white
                                          : const Color(0xFF5A3A40),
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE8D5D0)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Color(0xFF5A3A40)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (nameC.text.trim().isEmpty) return;
                            final admin = Provider.of<AdminProvider>(
                              ctx,
                              listen: false,
                            );
                            final newProduct = CatalogProduct(
                              id: isEdit
                                  ? product.id
                                  : 'prod_${DateTime.now().millisecondsSinceEpoch}',
                              name: nameC.text.trim(),
                              price: double.tryParse(priceC.text) ?? 0,
                              originalPrice: origPriceC.text.isNotEmpty
                                  ? double.tryParse(origPriceC.text)
                                  : null,
                              rating: product?.rating ?? 4.5,
                              image:
                                  product?.image ??
                                  'assets/images/products/foundation.png',
                              subtitle: subtitleC.text.trim().isEmpty
                                  ? null
                                  : subtitleC.text.trim(),
                              brand: brandC.text.trim().isEmpty
                                  ? null
                                  : brandC.text.trim(),
                              category: category,
                            );
                            if (isEdit) {
                              admin.updateProduct(product.id, newProduct);
                            } else {
                              admin.addProduct(newProduct);
                            }
                            Navigator.pop(ctx);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB76E79),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(isEdit ? 'Update' : 'Add Product'),
                        ),
                      ),
                    ],
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

// ═════════════════════════════════════════════════════════════════════════════
//  3. ANNOUNCEMENTS TAB
// ═════════════════════════════════════════════════════════════════════════════

class _AnnouncementsTab extends StatelessWidget {
  const _AnnouncementsTab();

  static const _tagOptions = [
    (
      'NEW ARRIVALS',
      Color(0xFF4CAF50),
      Icons.new_releases_outlined,
      'New Arrivals',
    ),
    (
      'EXCLUSIVE',
      Color(0xFFB76E79),
      Icons.auto_awesome_outlined,
      'New Arrivals',
    ),
    ('OFFER', Color(0xFFFF9800), Icons.local_offer_outlined, 'Offers'),
    ('UPDATE', Color(0xFF2196F3), Icons.local_shipping_outlined, 'Updates'),
    ('NEWS', Color(0xFF9C27B0), Icons.storefront_outlined, 'News'),
  ];

  @override
  Widget build(BuildContext context) {
    final admin = Provider.of<AdminProvider>(context);
    final items = admin.announcements;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Announcements (${items.length})',
                  style: TextStyle(
                    fontFamily: AppTheme.playfairFamily,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D1B20),
                  ),
                ),
              ),
              _AdminButton(
                icon: Icons.add_rounded,
                label: 'New Post',
                onTap: () => _showAnnouncementDialog(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: items.isEmpty
              ? const Center(child: Text('No announcements. Create one!'))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final a = items[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFE8D5D0).withValues(alpha: 0.5),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (a.imageUrl != null && a.imageUrl!.isNotEmpty)
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(13),
                              ),
                              child: Image.network(
                                a.imageUrl!,
                                height: 140,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return Container(
                                    height: 140,
                                    color: const Color(0xFFFDF8F5),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFFB76E79),
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (_, __, ___) => Container(
                                  height: 80,
                                  color: const Color(0xFFFDF8F5),
                                  child: const Center(
                                    child: Icon(
                                      Icons.image_outlined,
                                      color: Color(0xFFE8D5D0),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: a.tagColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    a.tag,
                                    style: TextStyle(
                                      color: a.tagColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    a.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 18,
                                  ),
                                  color: const Color(
                                    0xFF5A3A40,
                                  ).withValues(alpha: 0.5),
                                  onPressed: () => _showAnnouncementDialog(
                                    context,
                                    existing: a,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    size: 18,
                                  ),
                                  color: const Color(
                                    0xFFFF5722,
                                  ).withValues(alpha: 0.6),
                                  onPressed: () =>
                                      admin.deleteAnnouncement(a.id),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showAnnouncementDialog(BuildContext context, {Announcement? existing}) {
    final isEdit = existing != null;
    final titleC = TextEditingController(text: existing?.title ?? '');
    final subtitleC = TextEditingController(text: existing?.subtitle ?? '');
    final bodyC = TextEditingController(text: existing?.body ?? '');
    final imageC = TextEditingController(text: existing?.imageUrl ?? '');
    int tagIdx = 0;
    if (isEdit) {
      tagIdx = _tagOptions.indexWhere((t) => t.$1 == existing.tag);
      if (tagIdx < 0) tagIdx = 0;
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: const Color(0xFFFDF8F5),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEdit ? 'Edit Announcement' : 'New Announcement',
                    style: TextStyle(
                      fontFamily: AppTheme.playfairFamily,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2D1B20),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _DialogField(controller: titleC, label: 'Title'),
                  const SizedBox(height: 12),
                  _DialogField(controller: subtitleC, label: 'Subtitle'),
                  const SizedBox(height: 12),
                  _DialogField(
                    controller: bodyC,
                    label: 'Body / Details',
                    maxLines: 4,
                  ),
                  const SizedBox(height: 12),
                  _DialogField(
                    controller: imageC,
                    label: 'Image URL (optional)',
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Category / Tag',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF5A3A40).withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(_tagOptions.length, (i) {
                      final t = _tagOptions[i];
                      final selected = tagIdx == i;
                      return GestureDetector(
                        onTap: () => setDialogState(() => tagIdx = i),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? t.$2.withValues(alpha: 0.15)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: selected ? t.$2 : const Color(0xFFE8D5D0),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(t.$3, size: 16, color: t.$2),
                              const SizedBox(width: 6),
                              Text(
                                t.$1,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: selected
                                      ? t.$2
                                      : const Color(0xFF5A3A40),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE8D5D0)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Color(0xFF5A3A40)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (titleC.text.trim().isEmpty) return;
                            final admin = Provider.of<AdminProvider>(
                              ctx,
                              listen: false,
                            );
                            final tag = _tagOptions[tagIdx];
                            final now = DateTime.now();
                            final months = [
                              '',
                              'Jan',
                              'Feb',
                              'Mar',
                              'Apr',
                              'May',
                              'Jun',
                              'Jul',
                              'Aug',
                              'Sep',
                              'Oct',
                              'Nov',
                              'Dec',
                            ];
                            final dateStr =
                                '${months[now.month]} ${now.day}, ${now.year}';

                            final ann = Announcement(
                              id: isEdit
                                  ? existing.id
                                  : 'ann_${DateTime.now().millisecondsSinceEpoch}',
                              title: titleC.text.trim(),
                              subtitle: subtitleC.text.trim(),
                              body: bodyC.text.trim(),
                              date: isEdit ? existing.date : dateStr,
                              tag: tag.$1,
                              category: tag.$4,
                              tagColor: tag.$2,
                              icon: tag.$3,
                              imageUrl: imageC.text.trim().isEmpty
                                  ? null
                                  : imageC.text.trim(),
                            );
                            if (isEdit) {
                              admin.updateAnnouncement(existing.id, ann);
                            } else {
                              admin.addAnnouncement(ann);
                            }
                            Navigator.pop(ctx);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB76E79),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(isEdit ? 'Update' : 'Publish'),
                        ),
                      ),
                    ],
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

// ═════════════════════════════════════════════════════════════════════════════
//  4. ORDERS TAB
// ═════════════════════════════════════════════════════════════════════════════

class _OrdersTab extends StatelessWidget {
  const _OrdersTab();

  static const _statuses = [
    'Pending',
    'Confirmed',
    'Shipped',
    'Delivered',
    'Cancelled',
  ];

  @override
  Widget build(BuildContext context) {
    final admin = Provider.of<AdminProvider>(context);
    final orders = admin.orders;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Orders (${orders.length})',
                  style: TextStyle(
                    fontFamily: AppTheme.playfairFamily,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D1B20),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: orders.isEmpty
              ? const Center(child: Text('No orders yet.'))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  itemCount: orders.length,
                  itemBuilder: (_, i) {
                    final o = orders[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE8D5D0).withValues(alpha: 0.5),
                        ),
                      ),
                      child: Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          childrenPadding: const EdgeInsets.fromLTRB(
                            16,
                            0,
                            16,
                            16,
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      o.id,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${o.customerName} · ₹${o.total.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: const Color(
                                          0xFF5A3A40,
                                        ).withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _StatusBadge(o.status),
                            ],
                          ),
                          children: [
                            // Customer info
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFDF8F5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _InfoRow(
                                    Icons.person_outline,
                                    o.customerName,
                                  ),
                                  _InfoRow(
                                    Icons.phone_outlined,
                                    '+91 ${o.phone}',
                                  ),
                                  _InfoRow(
                                    Icons.location_on_outlined,
                                    '${o.address}, ${o.city} - ${o.pincode}',
                                  ),
                                  _InfoRow(
                                    Icons.calendar_today_outlined,
                                    o.date,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Items
                            ...o.items.map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${item.name} × ${item.qty}',
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                    Text(
                                      '₹${(item.price * item.qty).toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Status update
                            Row(
                              children: [
                                const Text(
                                  'Update Status:',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: _statuses.map((s) {
                                        final active = o.status == s;
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            right: 6,
                                          ),
                                          child: GestureDetector(
                                            onTap: () => admin
                                                .updateOrderStatus(o.id, s),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 5,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: active
                                                    ? const Color(0xFFB76E79)
                                                    : Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: active
                                                      ? const Color(0xFFB76E79)
                                                      : const Color(0xFFE8D5D0),
                                                ),
                                              ),
                                              child: Text(
                                                s,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: active
                                                      ? Colors.white
                                                      : const Color(0xFF5A3A40),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: const Color(0xFF5A3A40).withValues(alpha: 0.5),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: const Color(0xFF5A3A40).withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  5. SMS / ALERTS TAB
// ═════════════════════════════════════════════════════════════════════════════

class _AlertsTab extends StatelessWidget {
  const _AlertsTab();

  @override
  Widget build(BuildContext context) {
    final admin = Provider.of<AdminProvider>(context);
    final alerts = admin.sentAlerts;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'SMS & Alerts (${alerts.length})',
                  style: TextStyle(
                    fontFamily: AppTheme.playfairFamily,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D1B20),
                  ),
                ),
              ),
              _AdminButton(
                icon: Icons.send_rounded,
                label: 'Send Alert',
                onTap: () => _showAlertDialog(context),
              ),
            ],
          ),
        ),
        // Quick action chips
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _QuickChip(
                '📢 New Arrival Alert',
                () => _showAlertDialog(
                  context,
                  prefillTitle: 'New Arrivals!',
                  prefillMsg:
                      'New beauty products just arrived at JGS! Visit us or browse online.',
                ),
              ),
              _QuickChip(
                '🎁 Offer Alert',
                () => _showAlertDialog(
                  context,
                  prefillTitle: 'Special Offer!',
                  prefillMsg:
                      'Exciting offers at JGS! Get up to 50% off on select products.',
                ),
              ),
              _QuickChip(
                '🚚 Delivery Update',
                () => _showAlertDialog(
                  context,
                  prefillTitle: 'Delivery Update',
                  prefillMsg:
                      'Your order has been shipped and will arrive soon!',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: alerts.isEmpty
              ? const Center(child: Text('No alerts sent yet.'))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  itemCount: alerts.length,
                  itemBuilder: (_, i) {
                    final a = alerts[i];
                    final typeColor = a.type == 'Promotional'
                        ? const Color(0xFFFF9800)
                        : a.type == 'Offer'
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFF2196F3);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFE8D5D0).withValues(alpha: 0.5),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.sms_outlined,
                                size: 18,
                                color: typeColor,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  a.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: typeColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  a.type,
                                  style: TextStyle(
                                    color: typeColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            a.message,
                            style: TextStyle(
                              fontSize: 13,
                              color: const Color(
                                0xFF5A3A40,
                              ).withValues(alpha: 0.7),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.person_outline,
                                size: 14,
                                color: const Color(
                                  0xFF5A3A40,
                                ).withValues(alpha: 0.4),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                a.sentTo,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: const Color(
                                    0xFF5A3A40,
                                  ).withValues(alpha: 0.5),
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: const Color(
                                  0xFF5A3A40,
                                ).withValues(alpha: 0.4),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                a.sentAt,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: const Color(
                                    0xFF5A3A40,
                                  ).withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showAlertDialog(
    BuildContext context, {
    String? prefillTitle,
    String? prefillMsg,
  }) {
    final titleC = TextEditingController(text: prefillTitle ?? '');
    final msgC = TextEditingController(text: prefillMsg ?? '');
    String sendTo = 'All Customers';
    String type = 'Promotional';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: const Color(0xFFFDF8F5),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Send SMS / Alert',
                    style: TextStyle(
                      fontFamily: AppTheme.playfairFamily,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2D1B20),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _DialogField(controller: titleC, label: 'Alert Title'),
                  const SizedBox(height: 12),
                  _DialogField(controller: msgC, label: 'Message', maxLines: 4),
                  const SizedBox(height: 12),
                  Text(
                    'Send To',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF5A3A40).withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        ['All Customers', 'Recent Buyers', 'Custom Number']
                            .map(
                              (s) => GestureDetector(
                                onTap: () => setDialogState(() => sendTo = s),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: sendTo == s
                                        ? const Color(0xFFB76E79)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: sendTo == s
                                          ? const Color(0xFFB76E79)
                                          : const Color(0xFFE8D5D0),
                                    ),
                                  ),
                                  child: Text(
                                    s,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: sendTo == s
                                          ? Colors.white
                                          : const Color(0xFF5A3A40),
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Type',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF5A3A40).withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: ['Promotional', 'Transactional', 'Offer'].map((
                      t,
                    ) {
                      return GestureDetector(
                        onTap: () => setDialogState(() => type = t),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: type == t
                                ? const Color(0xFFB76E79)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: type == t
                                  ? const Color(0xFFB76E79)
                                  : const Color(0xFFE8D5D0),
                            ),
                          ),
                          child: Text(
                            t,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: type == t
                                  ? Colors.white
                                  : const Color(0xFF5A3A40),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE8D5D0)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Color(0xFF5A3A40)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (titleC.text.trim().isEmpty ||
                                msgC.text.trim().isEmpty)
                              return;
                            final admin = Provider.of<AdminProvider>(
                              ctx,
                              listen: false,
                            );
                            final now = DateTime.now();
                            final months = [
                              '',
                              'Jan',
                              'Feb',
                              'Mar',
                              'Apr',
                              'May',
                              'Jun',
                              'Jul',
                              'Aug',
                              'Sep',
                              'Oct',
                              'Nov',
                              'Dec',
                            ];
                            final h = now.hour > 12 ? now.hour - 12 : now.hour;
                            final ampm = now.hour >= 12 ? 'PM' : 'AM';
                            final timeStr =
                                '${months[now.month]} ${now.day}, ${now.year} - $h:${now.minute.toString().padLeft(2, '0')} $ampm';
                            admin.sendAlert(
                              SmsAlert(
                                id: 'sms_${DateTime.now().millisecondsSinceEpoch}',
                                title: titleC.text.trim(),
                                message: msgC.text.trim(),
                                sentTo: sendTo,
                                sentAt: timeStr,
                                type: type,
                              ),
                            );
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context)
                              ..clearSnackBars()
                              ..showSnackBar(
                                SnackBar(
                                  duration: const Duration(seconds: 3),
                                  content: Text('Alert sent to $sendTo'),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: const Color(0xFF2D1B20),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB76E79),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          icon: const Icon(Icons.send_rounded, size: 18),
                          label: const Text('Send'),
                        ),
                      ),
                    ],
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

class _QuickChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _QuickChip(this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFFE8D5D0).withValues(alpha: 0.6),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF5A3A40),
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  SHARED WIDGETS
// ═════════════════════════════════════════════════════════════════════════════

class _AdminButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AdminButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFB76E79),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;
  final bool isNumber;

  const _DialogField({
    required this.controller,
    required this.label,
    this.maxLines = 1,
    this.isNumber = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      inputFormatters: isNumber
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
      style: const TextStyle(
        color: Color(0xFF2D1B20),
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: const Color(0xFF5A3A40).withValues(alpha: 0.5),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: const Color(0xFFE8D5D0).withValues(alpha: 0.6),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: const Color(0xFFE8D5D0).withValues(alpha: 0.6),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFB76E79), width: 1.5),
        ),
      ),
    );
  }
}
