import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../shared/models/product_model.dart';
import '../../../shared/widgets/product_card.dart';
import '../../../shared/widgets/cart_toast.dart';
import '../../cart/providers/cart_provider.dart';
import '../../admin/providers/admin_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  CATEGORY PAGE — unified product listing with filters
// ─────────────────────────────────────────────────────────────────────────────

class CategoryPage extends StatefulWidget {
  final String? initialCategory;
  final String? initialBrand;
  final String? initialConcern;
  final String? initialSort;
  final String? pageTitle;
  final String? initialCollection;
  final String? initialSearchQuery;
  final bool autoFocusSearch;

  const CategoryPage({
    super.key,
    this.initialCategory,
    this.initialBrand,
    this.initialConcern,
    this.initialSort,
    this.pageTitle,
    this.initialCollection,
    this.initialSearchQuery,
    this.autoFocusSearch = false,
  });

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late String? _selectedCategory;
  late String? _selectedBrand;
  late String? _selectedConcern;
  late String _selectedSort;
  late String? _selectedCollection;
  RangeValues _priceRange = const RangeValues(0, 1000);
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;
  String _searchQuery = '';

  static const _categories = [
    'All',
    'Makeup',
    'Skincare',
    'Haircare',
    'Fragrance',
    'Bath & Body',
    'Nails',
    'Tools',
  ];

  static const _brands = [
    'All',
    'Lakme',
    'LOreal',
    'Maybelline',
    'Biotique',
    'Nivea',
    'Dove',
    'Revlon',
    'Himalaya',
    'Minimalist',
    'Olay',
    'Indulekha',
    'Engage',
    'Lotus',
  ];

  static const _concerns = [
    'All',
    'Acne & Blemishes',
    'Dry Skin',
    'Anti-Aging',
    'Sun Protection',
    'Hair Fall',
    'Dark Circles',
  ];

  static const _sortOptions = [
    'Popularity',
    'Price: Low to High',
    'Price: High to Low',
    'Rating',
    'Newest',
  ];

  static const _collections = {
    'All': null,
    'Bestsellers': 'bestseller',
    'New Arrivals': 'new_arrival',
    'Popular': 'popular',
  };

  static const _categoryIcons = <String, IconData>{
    'All': Icons.grid_view_rounded,
    'Makeup': Icons.brush_rounded,
    'Skincare': Icons.spa_outlined,
    'Haircare': Icons.content_cut_rounded,
    'Fragrance': Icons.water_drop_outlined,
    'Bath & Body': Icons.bathtub_outlined,
    'Nails': Icons.back_hand_outlined,
    'Tools': Icons.auto_fix_high_rounded,
  };

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _selectedBrand = widget.initialBrand;
    _selectedConcern = widget.initialConcern;
    _selectedSort = widget.initialSort ?? 'Popularity';
    _selectedCollection = widget.initialCollection;
    _searchController = TextEditingController(
      text: widget.initialSearchQuery ?? '',
    );
    _searchQuery = widget.initialSearchQuery ?? '';
    _searchFocusNode = FocusNode();
    if (widget.autoFocusSearch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchFocusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  List<CatalogProduct> _filteredProducts(List<CatalogProduct> sourceProducts) {
    var products = sourceProducts;

    // Search query filter
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      products = products
          .where(
            (p) =>
                p.name.toLowerCase().contains(q) ||
                (p.brand?.toLowerCase().contains(q) ?? false) ||
                (p.subtitle?.toLowerCase().contains(q) ?? false) ||
                (p.category?.toLowerCase().contains(q) ?? false),
          )
          .toList();
    }

    // Filter by collection tag (bestseller / new_arrival / popular)
    if (_selectedCollection != null) {
      products = products
          .where((p) => p.tags.contains(_selectedCollection))
          .toList();
    }

    if (_selectedCategory != null && _selectedCategory != 'All') {
      products = products
          .where((p) => p.category == _selectedCategory)
          .toList();
    }
    if (_selectedBrand != null && _selectedBrand != 'All') {
      products = products.where((p) => p.brand == _selectedBrand).toList();
    }
    if (_selectedConcern != null && _selectedConcern != 'All') {
      products = products.where((p) => p.concern == _selectedConcern).toList();
    }
    products = products
        .where(
          (p) => p.price >= _priceRange.start && p.price <= _priceRange.end,
        )
        .toList();

    switch (_selectedSort) {
      case 'Price: Low to High':
        products.sort((a, b) => a.price.compareTo(b.price));
      case 'Price: High to Low':
        products.sort((a, b) => b.price.compareTo(a.price));
      case 'Rating':
        products.sort((a, b) => b.rating.compareTo(a.rating));
      case 'Newest':
        products = products.reversed.toList();
      default:
        break;
    }
    return products;
  }

  String get _title {
    if (widget.pageTitle != null) return widget.pageTitle!;
    if (_selectedBrand != null && _selectedBrand != 'All') {
      return _selectedBrand!;
    }
    if (_selectedConcern != null && _selectedConcern != 'All') {
      return _selectedConcern!;
    }
    if (_selectedCategory != null && _selectedCategory != 'All') {
      return _selectedCategory!;
    }
    return 'All Products';
  }

  void _addToCart(CatalogProduct p) {
    Provider.of<CartProvider>(context, listen: false).addItem(
      p.id,
      p.name,
      p.effectivePrice,
      p.image,
      variantLabel: p.variants.isNotEmpty ? p.variants.first.sizeLabel : null,
    );
    showCartToast(context, p.name);
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  BUILD
  // ═════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final allProducts = Provider.of<AdminProvider>(context).products;
    final source = allProducts.isNotEmpty ? allProducts : CatalogProduct.all;
    final products = _filteredProducts(source);
    final w = MediaQuery.sizeOf(context).width;
    final compact = w < 760;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F5),
      body: Column(
        children: [
          _buildAppBar(context, compact),
          _buildSearchBar(),
          // Active filter chips (only visible when filters are set)
          if (_hasActiveFilters) _buildActiveChips(),
          Expanded(
            child: products.isEmpty
                ? _buildEmptyState()
                : _buildProductGrid(products, w),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  APP BAR
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildAppBar(BuildContext context, bool compact) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 12,
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF8F5).withValues(alpha: 0.98),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE8D5D0).withValues(alpha: 0.50),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE8B4B8).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF5A3A40).withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFE8D5D0).withValues(alpha: 0.50),
                ),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFF2D1B20),
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title,
                  style: const TextStyle(
                    color: Color(0xFF2D1B20),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  '${products.length} products',
                  style: TextStyle(
                    color: const Color(0xFF5A3A40).withValues(alpha: 0.55),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Consumer<CartProvider>(
            builder: (context, cart, _) {
              return InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => context.push('/cart'),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5A3A40).withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFE8D5D0).withValues(alpha: 0.50),
                    ),
                  ),
                  child: Badge(
                    isLabelVisible: cart.totalQuantity > 0,
                    label: Text('${cart.totalQuantity}'),
                    backgroundColor: const Color(0xFFB76E79),
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      color: Color(0xFF2D1B20),
                      size: 22,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  SEARCH BAR
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      color: const Color(0xFFFDF8F5),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white,
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
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: (v) => setState(() => _searchQuery = v),
                style: const TextStyle(color: Color(0xFF2D1B20), fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search beauty products...',
                  hintStyle: TextStyle(
                    color: const Color(0xFF8B4A52).withValues(alpha: 0.38),
                    fontSize: 13,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(
                    Icons.close_rounded,
                    color: const Color(0xFF8B4A52).withValues(alpha: 0.55),
                    size: 18,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<CatalogProduct> get products {
    final allProducts = Provider.of<AdminProvider>(
      context,
      listen: false,
    ).products;
    final source = allProducts.isNotEmpty ? allProducts : CatalogProduct.all;
    return _filteredProducts(source);
  }

  bool get _hasActiveFilters {
    return (_selectedCollection != null) ||
        (_selectedCategory != null && _selectedCategory != 'All') ||
        (_selectedBrand != null && _selectedBrand != 'All') ||
        (_selectedConcern != null && _selectedConcern != 'All') ||
        _priceRange.start > 0 ||
        _priceRange.end < 1000;
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  ACTIVE FILTER CHIPS — shown below app bar when filters are set
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildActiveChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        height: 32,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            if (_selectedCollection != null)
              _activeChip(
                _collections.entries
                    .firstWhere((e) => e.value == _selectedCollection)
                    .key,
                () => setState(() => _selectedCollection = null),
              ),
            if (_selectedCategory != null && _selectedCategory != 'All')
              _activeChip(
                _selectedCategory!,
                () => setState(() => _selectedCategory = null),
              ),
            if (_selectedBrand != null && _selectedBrand != 'All')
              _activeChip(
                _selectedBrand!,
                () => setState(() => _selectedBrand = null),
              ),
            if (_selectedConcern != null && _selectedConcern != 'All')
              _activeChip(
                _selectedConcern!,
                () => setState(() => _selectedConcern = null),
              ),
            if (_priceRange.start > 0 || _priceRange.end < 1000)
              _activeChip(
                '₹${_priceRange.start.round()}-₹${_priceRange.end.round()}',
                () => setState(() => _priceRange = const RangeValues(0, 1000)),
              ),
            if (_selectedSort != 'Popularity')
              _activeChip(
                _selectedSort,
                () => setState(() => _selectedSort = 'Popularity'),
              ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => setState(() {
                _selectedCollection = null;
                _selectedCategory = null;
                _selectedBrand = null;
                _selectedConcern = null;
                _selectedSort = 'Popularity';
                _priceRange = const RangeValues(0, 1000);
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: const Color(0xFFB76E79).withValues(alpha: 0.30),
                  ),
                ),
                child: const Text(
                  'Clear all',
                  style: TextStyle(
                    color: Color(0xFFB76E79),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  BOTTOM BAR — Sort | Category | Filter
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildBottomBar(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final hasSort = _selectedSort != 'Popularity';
    final hasCat = _selectedCategory != null && _selectedCategory != 'All';
    final hasFilter =
        (_selectedBrand != null && _selectedBrand != 'All') ||
        (_selectedConcern != null && _selectedConcern != 'All') ||
        _priceRange.start > 0 ||
        _priceRange.end < 1000 ||
        _selectedCollection != null;

    return Container(
      padding: EdgeInsets.fromLTRB(0, 0, 0, bottomPad),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: const Color(0xFFE8D5D0).withValues(alpha: 0.60),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE8B4B8).withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          _bottomBarButton(
            icon: Icons.swap_vert_rounded,
            label: 'Sort',
            active: hasSort,
            onTap: () => _showSortSheet(context),
          ),
          _bottomBarDivider(),
          _bottomBarButton(
            icon: Icons.grid_view_rounded,
            label: 'Category',
            active: hasCat,
            onTap: () => _showCategorySheet(context),
          ),
          _bottomBarDivider(),
          _bottomBarButton(
            icon: Icons.tune_rounded,
            label: 'Filter',
            active: hasFilter,
            onTap: () => _showFilterSheet(context),
          ),
        ],
      ),
    );
  }

  Widget _bottomBarButton({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: active
                    ? const Color(0xFFB76E79)
                    : const Color(0xFF5A3A40),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: active
                      ? const Color(0xFFB76E79)
                      : const Color(0xFF5A3A40),
                  fontSize: 13,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
              if (active) ...[
                const SizedBox(width: 4),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFFB76E79),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomBarDivider() {
    return Container(
      width: 1,
      height: 24,
      color: const Color(0xFFE8D5D0).withValues(alpha: 0.50),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  SORT BOTTOM SHEET
  // ═════════════════════════════════════════════════════════════════════════

  void _showSortSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFDF8F5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            MediaQuery.of(ctx).padding.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8D5D0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Sort By',
                style: TextStyle(
                  color: Color(0xFF2D1B20),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              ..._sortOptions.map((opt) {
                final sel = _selectedSort == opt;
                return InkWell(
                  onTap: () {
                    setState(() => _selectedSort = opt);
                    Navigator.pop(ctx);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    margin: const EdgeInsets.only(bottom: 4),
                    decoration: BoxDecoration(
                      color: sel
                          ? const Color(0xFFB76E79).withValues(alpha: 0.08)
                          : null,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            opt,
                            style: TextStyle(
                              color: sel
                                  ? const Color(0xFFB76E79)
                                  : const Color(0xFF2D1B20),
                              fontSize: 15,
                              fontWeight: sel
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                        if (sel)
                          const Icon(
                            Icons.check_rounded,
                            color: Color(0xFFB76E79),
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  CATEGORY BOTTOM SHEET
  // ═════════════════════════════════════════════════════════════════════════

  void _showCategorySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFDF8F5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            MediaQuery.of(ctx).padding.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8D5D0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Category',
                style: TextStyle(
                  color: Color(0xFF2D1B20),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              ..._categories.map((cat) {
                final sel = (_selectedCategory ?? 'All') == cat;
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedCategory = cat == 'All' ? null : cat;
                    });
                    Navigator.pop(ctx);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    margin: const EdgeInsets.only(bottom: 4),
                    decoration: BoxDecoration(
                      color: sel
                          ? const Color(0xFFB76E79).withValues(alpha: 0.08)
                          : null,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _categoryIcons[cat] ?? Icons.grid_view_rounded,
                          size: 18,
                          color: sel
                              ? const Color(0xFFB76E79)
                              : const Color(0xFF5A3A40).withValues(alpha: 0.60),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            cat,
                            style: TextStyle(
                              color: sel
                                  ? const Color(0xFFB76E79)
                                  : const Color(0xFF2D1B20),
                              fontSize: 15,
                              fontWeight: sel
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                        if (sel)
                          const Icon(
                            Icons.check_rounded,
                            color: Color(0xFFB76E79),
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _activeChip(String label, VoidCallback onRemove) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFB76E79).withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: const Color(0xFFB76E79).withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFFB76E79),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onRemove,
              child: const Icon(
                Icons.close_rounded,
                size: 14,
                color: Color(0xFFB76E79),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  FILTER BOTTOM SHEET
  // ═════════════════════════════════════════════════════════════════════════

  void _showFilterSheet(BuildContext context) {
    String? tempBrand = _selectedBrand;
    String? tempConcern = _selectedConcern;
    String? tempCollection = _selectedCollection;
    RangeValues tempPrice = _priceRange;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFDF8F5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              maxChildSize: 0.9,
              minChildSize: 0.4,
              expand: false,
              builder: (_, scrollCtrl) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: ListView(
                    controller: scrollCtrl,
                    children: [
                      // Handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8D5D0),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Filters',
                        style: TextStyle(
                          color: Color(0xFF2D1B20),
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Collection filter
                      const Text(
                        'COLLECTION',
                        style: TextStyle(
                          color: Color(0xFFB76E79),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _collections.entries.map((e) {
                          final sel = tempCollection == e.value;
                          return _sheetChip(
                            label: e.key,
                            selected: e.key == 'All'
                                ? tempCollection == null
                                : sel,
                            onTap: () => setSheetState(() {
                              tempCollection = e.value;
                            }),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 22),

                      // Brand filter
                      const Text(
                        'BRAND',
                        style: TextStyle(
                          color: Color(0xFFB76E79),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _brands.map((b) {
                          return _sheetChip(
                            label: b,
                            selected: (tempBrand ?? 'All') == b,
                            onTap: () => setSheetState(() {
                              tempBrand = b == 'All' ? null : b;
                            }),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 22),

                      // Concern filter
                      const Text(
                        'CONCERN',
                        style: TextStyle(
                          color: Color(0xFFB76E79),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _concerns.map((c) {
                          return _sheetChip(
                            label: c,
                            selected: (tempConcern ?? 'All') == c,
                            onTap: () => setSheetState(() {
                              tempConcern = c == 'All' ? null : c;
                            }),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 22),

                      // Price range
                      const Text(
                        'PRICE RANGE',
                        style: TextStyle(
                          color: Color(0xFFB76E79),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${tempPrice.start.round()} – ₹${tempPrice.end.round()}',
                        style: TextStyle(
                          color: const Color(
                            0xFF5A3A40,
                          ).withValues(alpha: 0.70),
                          fontSize: 13,
                        ),
                      ),
                      RangeSlider(
                        values: tempPrice,
                        min: 0,
                        max: 1000,
                        divisions: 20,
                        activeColor: const Color(0xFFB76E79),
                        inactiveColor: const Color(
                          0xFFE8D5D0,
                        ).withValues(alpha: 0.50),
                        onChanged: (v) => setSheetState(() => tempPrice = v),
                      ),
                      const SizedBox(height: 24),

                      // Apply / Reset
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setSheetState(() {
                                  tempCollection = null;
                                  tempBrand = null;
                                  tempConcern = null;
                                  tempPrice = const RangeValues(0, 1000);
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF5A3A40),
                                side: const BorderSide(
                                  color: Color(0xFFE8D5D0),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                'Reset',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedCollection = tempCollection;
                                  _selectedBrand = tempBrand;
                                  _selectedConcern = tempConcern;
                                  _priceRange = tempPrice;
                                });
                                Navigator.pop(ctx);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFB76E79),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                'Apply Filters',
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _sheetChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFB76E79) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? const Color(0xFFB76E79)
                : const Color(0xFFE8D5D0).withValues(alpha: 0.60),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF5A3A40),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  PRODUCT GRID
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildProductGrid(List<CatalogProduct> products, double screenW) {
    final cols = screenW >= 1140
        ? 4
        : screenW >= 820
        ? 3
        : 2;
    const spacing = 12.0;
    final cardW = (screenW - 32 - (cols - 1) * spacing) / cols;
    const cardH = 370.0;

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: cardW / cardH,
      ),
      itemBuilder: (_, i) =>
          ProductCard(product: products[i], onAddToCart: _addToCart),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  EMPTY STATE
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: const Color(0xFFE8B4B8).withValues(alpha: 0.50),
            ),
            const SizedBox(height: 16),
            const Text(
              'No products found',
              style: TextStyle(
                color: Color(0xFF2D1B20),
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters to find what you\'re looking for.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF5A3A40).withValues(alpha: 0.60),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => setState(() {
                _selectedCategory = null;
                _selectedBrand = null;
                _selectedConcern = null;
                _priceRange = const RangeValues(0, 1000);
              }),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFB76E79),
                side: const BorderSide(color: Color(0xFFB76E79)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Clear Filters',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
