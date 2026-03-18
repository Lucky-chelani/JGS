class ProductVariant {
  final String id;
  final String sizeLabel;
  final double mrp;
  final double sellingPrice;

  const ProductVariant({
    required this.id,
    required this.sizeLabel,
    required this.mrp,
    required this.sellingPrice,
  });

  int get discountPct {
    if (mrp <= 0 || sellingPrice >= mrp) return 0;
    return ((1 - (sellingPrice / mrp)) * 100).round();
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'sizeLabel': sizeLabel,
    'mrp': mrp,
    'sellingPrice': sellingPrice,
  };

  factory ProductVariant.fromMap(Map<String, dynamic> map) {
    return ProductVariant(
      id: map['id'] as String? ?? '',
      sizeLabel: map['sizeLabel'] as String? ?? '',
      mrp: (map['mrp'] as num?)?.toDouble() ?? 0,
      sellingPrice: (map['sellingPrice'] as num?)?.toDouble() ?? 0,
    );
  }
}

class CatalogProduct {
  final String id;
  final String name;
  final double price;
  final double? originalPrice;
  final double rating;
  final String image;
  final String? subtitle;
  final String? brand;
  final String? category;
  final String? concern;
  final String? description;
  final List<String> tags;
  final List<ProductVariant> variants;

  const CatalogProduct({
    required this.id,
    required this.name,
    required this.price,
    this.originalPrice,
    required this.rating,
    required this.image,
    this.subtitle,
    this.brand,
    this.category,
    this.concern,
    this.description,
    this.tags = const [],
    this.variants = const [],
  });

  double get effectivePrice =>
      variants.isNotEmpty ? variants.first.sellingPrice : price;

  double? get effectiveOriginalPrice {
    if (variants.isNotEmpty) {
      final mrp = variants.first.mrp;
      return mrp > 0 ? mrp : null;
    }
    return originalPrice;
  }

  int get effectiveDiscountPct {
    final o = effectiveOriginalPrice;
    final p = effectivePrice;
    if (o == null || o <= 0 || p >= o) return 0;
    return ((1 - p / o) * 100).round();
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'price': price,
    'originalPrice': originalPrice,
    'rating': rating,
    'image': image,
    'subtitle': subtitle,
    'brand': brand,
    'category': category,
    'concern': concern,
    'description': description,
    'tags': tags,
    'variants': variants.map((v) => v.toMap()).toList(),
    'updatedAt': DateTime.now().toIso8601String(),
  };

  factory CatalogProduct.fromMap(String id, Map<String, dynamic> map) {
    final rawVariants = map['variants'] as List<dynamic>? ?? const [];
    return CatalogProduct(
      id: id,
      name: map['name'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      originalPrice: (map['originalPrice'] as num?)?.toDouble(),
      rating: (map['rating'] as num?)?.toDouble() ?? 4.5,
      image: map['image'] as String? ?? '',
      subtitle: map['subtitle'] as String?,
      brand: map['brand'] as String?,
      category: map['category'] as String?,
      concern: map['concern'] as String?,
      description: map['description'] as String?,
      tags: (map['tags'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      variants: rawVariants
          .whereType<Map>()
          .map((e) => ProductVariant.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  static const bestsellers = [
    CatalogProduct(
      id: 'bs_foundation',
      name: 'Lakme 9to5 Foundation',
      price: 499,
      originalPrice: 799,
      rating: 4.7,
      image: 'assets/images/products/foundation.png',
      subtitle: 'Flawless finish · SPF 20',
      brand: 'Lakme',
      category: 'Makeup',
      tags: ['bestseller', 'popular'],
    ),
    CatalogProduct(
      id: 'bs_facewash',
      name: 'Lotus Vitamin C Face Wash',
      price: 199,
      originalPrice: 299,
      rating: 4.5,
      image: 'assets/images/products/facewash.png',
      subtitle: 'Brightening · All skin types',
      brand: 'Lotus',
      category: 'Skincare',
      concern: 'Acne & Blemishes',
      tags: ['bestseller', 'popular'],
    ),
    CatalogProduct(
      id: 'bs_lipstick',
      name: 'Revlon Super Lustrous',
      price: 349,
      originalPrice: 549,
      rating: 4.8,
      image: 'assets/images/products/lipstick.png',
      subtitle: '12hr wear · Creamy matte',
      brand: 'Revlon',
      category: 'Makeup',
      tags: ['bestseller', 'popular'],
    ),
    CatalogProduct(
      id: 'bs_serum',
      name: 'Biotique Vitamin C Serum',
      price: 279,
      originalPrice: 450,
      rating: 4.6,
      image: 'assets/images/products/serum.png',
      subtitle: 'Anti-oxidant · Glow boost',
      brand: 'Biotique',
      category: 'Skincare',
      concern: 'Anti-Aging',
      tags: ['bestseller', 'popular'],
    ),
    CatalogProduct(
      id: 'bs_sunscreen',
      name: 'Lakme Sun Expert SPF 50',
      price: 329,
      originalPrice: 499,
      rating: 4.4,
      image: 'assets/images/products/foundation.png',
      subtitle: 'UV protection · Lightweight',
      brand: 'Lakme',
      category: 'Skincare',
      concern: 'Sun Protection',
      tags: ['bestseller'],
    ),
    CatalogProduct(
      id: 'bs_lotion',
      name: 'Nivea Soft Light Cream',
      price: 229,
      originalPrice: 375,
      rating: 4.3,
      image: 'assets/images/products/facewash.png',
      subtitle: 'Deep moisturizing · 24hr',
      brand: 'Nivea',
      category: 'Bath & Body',
      concern: 'Dry Skin',
      tags: ['bestseller'],
    ),
  ];

  static const newArrivals = [
    CatalogProduct(
      id: 'na_serum_ha',
      name: 'Minimalist HA Serum',
      price: 399,
      rating: 4.9,
      image: 'assets/images/products/serum.png',
      subtitle: 'Hyaluronic acid · Hydration',
      brand: 'Minimalist',
      category: 'Skincare',
      concern: 'Dry Skin',
      tags: ['new_arrival', 'popular'],
    ),
    CatalogProduct(
      id: 'na_lip_tint',
      name: 'Maybelline Lip Tint',
      price: 249,
      rating: 4.6,
      image: 'assets/images/products/lipstick.png',
      subtitle: 'Waterproof · 8 shades',
      brand: 'Maybelline',
      category: 'Makeup',
      tags: ['new_arrival', 'popular'],
    ),
    CatalogProduct(
      id: 'na_night_cream',
      name: 'Olay Retinol Night Cream',
      price: 599,
      rating: 4.7,
      image: 'assets/images/products/foundation.png',
      subtitle: 'Anti-aging · Repair',
      brand: 'Olay',
      category: 'Skincare',
      concern: 'Anti-Aging',
      tags: ['new_arrival', 'popular'],
    ),
    CatalogProduct(
      id: 'na_hair_oil',
      name: 'Indulekha Bringha Oil',
      price: 349,
      rating: 4.5,
      image: 'assets/images/products/serum.png',
      subtitle: 'Hair growth · Ayurvedic',
      brand: 'Indulekha',
      category: 'Haircare',
      concern: 'Hair Fall',
      tags: ['new_arrival'],
    ),
    CatalogProduct(
      id: 'na_perfume',
      name: 'Engage Eau de Parfum',
      price: 449,
      rating: 4.4,
      image: 'assets/images/products/facewash.png',
      subtitle: 'Long lasting · Floral',
      brand: 'Engage',
      category: 'Fragrance',
      tags: ['new_arrival'],
    ),
  ];

  static final List<CatalogProduct> all = [...bestsellers, ...newArrivals];
}
