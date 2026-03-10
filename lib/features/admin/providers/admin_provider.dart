import 'package:flutter/material.dart';
import '../../../shared/models/product_model.dart';
import '../../../shared/models/announcement_model.dart';
import '../../../shared/models/order_model.dart';

/// Central admin provider managing products, announcements, orders, and alerts.
class AdminProvider with ChangeNotifier {
  // ═══════════════════════════════════════════════════════════════════════
  //  PRODUCTS
  // ═══════════════════════════════════════════════════════════════════════

  final List<CatalogProduct> _products = [...CatalogProduct.all];

  List<CatalogProduct> get products => List.unmodifiable(_products);

  void addProduct(CatalogProduct product) {
    _products.insert(0, product);
    notifyListeners();
  }

  void updateProduct(String id, CatalogProduct updated) {
    final idx = _products.indexWhere((p) => p.id == id);
    if (idx != -1) {
      _products[idx] = updated;
      notifyListeners();
    }
  }

  void deleteProduct(String id) {
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  ANNOUNCEMENTS
  // ═══════════════════════════════════════════════════════════════════════

  final List<Announcement> _announcements = [
    Announcement(
      id: 'ann_1',
      title: '🎉 Grand New Arrivals!',
      subtitle: 'Fresh stock just landed at JGS',
      body:
          'We\'ve just received an exciting shipment of premium beauty products! Come visit our store or browse online to discover the latest from Lakme, Maybelline, L\'Oreal, and more.',
      date: 'Mar 10, 2026',
      tag: 'NEW ARRIVALS',
      category: 'New Arrivals',
      tagColor: const Color(0xFF4CAF50),
      icon: Icons.new_releases_outlined,
      imageUrl:
          'https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=800',
    ),
    Announcement(
      id: 'ann_2',
      title: '💄 Lakme Festive Collection',
      subtitle: 'Exclusive festive shades now available',
      body:
          'The much-awaited Lakme festive collection has arrived! Explore stunning lipstick shades, eye palettes, and nail colors.',
      date: 'Mar 8, 2026',
      tag: 'EXCLUSIVE',
      category: 'New Arrivals',
      tagColor: const Color(0xFFB76E79),
      icon: Icons.auto_awesome_outlined,
      imageUrl:
          'https://images.unsplash.com/photo-1631214524020-7e18db9a8f92?w=800',
    ),
    Announcement(
      id: 'ann_3',
      title: '🧴 Buy 2 Get 1 Free — Skincare',
      subtitle: 'Special offer on all skincare products',
      body:
          'This week only! Buy any 2 skincare products and get 1 absolutely free. Valid on Biotique, Mamaearth, Himalaya, and more.',
      date: 'Mar 5, 2026',
      tag: 'OFFER',
      category: 'Offers',
      tagColor: const Color(0xFFFF9800),
      icon: Icons.local_offer_outlined,
      imageUrl:
          'https://images.unsplash.com/photo-1556228578-0d85b1a4d571?w=800',
    ),
    Announcement(
      id: 'ann_4',
      title: '🚚 Free Home Delivery Update',
      subtitle: 'Now delivering to more areas!',
      body:
          'Free home delivery is now available for orders above ₹500 across the entire city.',
      date: 'Mar 1, 2026',
      tag: 'UPDATE',
      category: 'Updates',
      tagColor: const Color(0xFF2196F3),
      icon: Icons.local_shipping_outlined,
    ),
    Announcement(
      id: 'ann_5',
      title: '✨ Store Renovation Complete',
      subtitle: 'New look, same trusted service',
      body:
          'Our store has a brand new look! Visit us to experience a more spacious, well-organized shopping space.',
      date: 'Feb 25, 2026',
      tag: 'NEWS',
      category: 'News',
      tagColor: const Color(0xFF9C27B0),
      icon: Icons.storefront_outlined,
    ),
  ];

  List<Announcement> get announcements => List.unmodifiable(_announcements);

  void addAnnouncement(Announcement a) {
    _announcements.insert(0, a);
    notifyListeners();
  }

  void updateAnnouncement(String id, Announcement updated) {
    final idx = _announcements.indexWhere((a) => a.id == id);
    if (idx != -1) {
      _announcements[idx] = updated;
      notifyListeners();
    }
  }

  void deleteAnnouncement(String id) {
    _announcements.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  ORDERS
  // ═══════════════════════════════════════════════════════════════════════

  final List<Order> _orders = [
    Order(
      id: 'JGS-10234',
      customerName: 'Priya Sharma',
      phone: '9876543210',
      address: '45, MG Road, Near Temple',
      pincode: '452001',
      city: 'Indore',
      total: 1299,
      date: 'Mar 8, 2026',
      status: 'Delivered',
      items: [
        const OrderLineItem(
          name: 'Lakme 9to5 Primer + Matte Lipstick',
          qty: 1,
          price: 649,
        ),
        const OrderLineItem(
          name: 'Maybelline Fit Me Foundation',
          qty: 1,
          price: 650,
        ),
      ],
    ),
    Order(
      id: 'JGS-10235',
      customerName: 'Ritu Jain',
      phone: '9988776655',
      address: '12, Nehru Nagar, Block B',
      pincode: '452002',
      city: 'Indore',
      total: 875,
      date: 'Mar 9, 2026',
      status: 'Pending',
      items: [
        const OrderLineItem(
          name: 'L\'Oreal Hyaluron Shampoo',
          qty: 1,
          price: 475,
        ),
        const OrderLineItem(name: 'Nivea Soft Cream', qty: 2, price: 200),
      ],
    ),
    Order(
      id: 'JGS-10236',
      customerName: 'Ankit Verma',
      phone: '8877665544',
      address: '78, Vijay Nagar, Scheme 54',
      pincode: '452010',
      city: 'Indore',
      total: 2150,
      date: 'Mar 10, 2026',
      status: 'Confirmed',
      items: [
        const OrderLineItem(
          name: 'Forest Essentials Night Cream',
          qty: 1,
          price: 1900,
        ),
        const OrderLineItem(name: 'Biotique Face Wash', qty: 1, price: 250),
      ],
    ),
  ];

  List<Order> get orders => List.unmodifiable(_orders);

  void updateOrderStatus(String id, String status) {
    final idx = _orders.indexWhere((o) => o.id == id);
    if (idx != -1) {
      _orders[idx].status = status;
      notifyListeners();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  SMS / ALERTS LOG
  // ═══════════════════════════════════════════════════════════════════════

  final List<SmsAlert> _sentAlerts = [
    SmsAlert(
      id: 'sms_1',
      title: 'New Arrivals Alert',
      message:
          'Hi! New beauty products just arrived at JGS. Visit us or browse online. Use code BEAUTY10 for 10% off!',
      sentTo: 'All Customers',
      sentAt: 'Mar 10, 2026 - 10:30 AM',
      type: 'Promotional',
    ),
    SmsAlert(
      id: 'sms_2',
      title: 'Order Shipped',
      message: 'Your order JGS-10234 has been shipped! Track: bit.ly/jgs10234',
      sentTo: 'Priya Sharma (+91-9876543210)',
      sentAt: 'Mar 8, 2026 - 2:15 PM',
      type: 'Transactional',
    ),
  ];

  List<SmsAlert> get sentAlerts => List.unmodifiable(_sentAlerts);

  void sendAlert(SmsAlert alert) {
    _sentAlerts.insert(0, alert);
    notifyListeners();
  }
}

class SmsAlert {
  final String id;
  final String title;
  final String message;
  final String sentTo;
  final String sentAt;
  final String type; // Promotional, Transactional, Offer

  const SmsAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.sentTo,
    required this.sentAt,
    required this.type,
  });
}
