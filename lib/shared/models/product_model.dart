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
  final List<String> tags;

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
    this.tags = const [],
  });

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
