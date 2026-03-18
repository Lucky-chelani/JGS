import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:cloud_functions/cloud_functions.dart';
import 'dart:async';
import '../../../shared/models/product_model.dart';
import '../../../shared/models/announcement_model.dart';
import '../../../shared/models/order_model.dart';
import '../../../shared/models/coupon_model.dart';
import '../../../shared/models/alert_model.dart';

/// Central admin provider managing products, announcements, orders, and alerts.
class AdminProvider with ChangeNotifier {
  // ═══════════════════════════════════════════════════════════════════════
  //  PRODUCTS
  // ═══════════════════════════════════════════════════════════════════════

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final List<CatalogProduct> _products = [];
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _productsSub;

  List<CatalogProduct> get products => List.unmodifiable(_products);

  AdminProvider() {
    _listenProducts();
    _listenCoupons();
    _listenAnnouncements();
    _listenOrders();
    _listenAlerts();
  }

  void _listenProducts() {
    _productsSub?.cancel();
    _productsSub = _firestore
        .collection('products')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .listen((snapshot) {
          _products
            ..clear()
            ..addAll(
              snapshot.docs.map((d) {
                final data = d.data();
                return CatalogProduct.fromMap(d.id, data);
              }),
            );
          notifyListeners();
        }, onError: (e) {
          debugPrint('Error in products listener: $e');
        });
  }

  Future<void> addProduct(CatalogProduct product) async {
    await _firestore.collection('products').doc(product.id).set({
      ...product.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateProduct(String id, CatalogProduct updated) async {
    await _firestore.collection('products').doc(id).set({
      ...updated.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteProduct(String id) async {
    await _firestore.collection('products').doc(id).delete();
  }

  String suggestDescription({
    required String name,
    required String category,
    String? concern,
  }) {
    final cleanName = name.trim();
    final cleanCat = category.trim();
    final focus = (concern ?? '').trim();
    final concernLine = focus.isNotEmpty
        ? 'Specially formulated for $focus.'
        : '';
    return '$cleanName is a premium $cleanCat essential designed for daily use. '
        'It offers lightweight, effective care with skin-friendly ingredients and quick absorption. '
        '$concernLine Best suited for Indian weather and routines, this product delivers visible results with consistent use.';
  }

  Future<String> suggestDescriptionAi({
    required String name,
    required String category,
    String? concern,
  }) async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable(
        'suggestProductDescription',
      );
      final result = await callable.call({
        'name': name,
        'category': category,
        'concern': concern,
      });
      final data = result.data;
      if (data is Map && data['description'] is String) {
        final value = (data['description'] as String).trim();
        if (value.isNotEmpty) return value;
      }
    } catch (_) {
      // Fallback to deterministic suggestion if function is unavailable.
    }
    return suggestDescription(name: name, category: category, concern: concern);
  }


  // ═══════════════════════════════════════════════════════════════════════
  //  COUPONS
  // ═══════════════════════════════════════════════════════════════════════

  final List<Coupon> _coupons = [];
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _couponsSub;

  List<Coupon> get coupons => List.unmodifiable(_coupons);

  void _listenCoupons() {
    _couponsSub?.cancel();
    _couponsSub = _firestore
        .collection('coupons')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .listen((snapshot) {
          _coupons
            ..clear()
            ..addAll(
              snapshot.docs.map((d) {
                final data = d.data();
                return Coupon.fromMap(d.id, data);
              }),
            );
          notifyListeners();
        }, onError: (e) {
          debugPrint('Error in coupons listener: $e');
        });
  }

  Future<void> addCoupon(Coupon coupon) async {
    await _firestore.collection('coupons').doc(coupon.id).set({
      ...coupon.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateCoupon(String id, Coupon updated) async {
    await _firestore.collection('coupons').doc(id).set({
      ...updated.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteCoupon(String id) async {
    await _firestore.collection('coupons').doc(id).delete();
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  ANNOUNCEMENTS
  // ═══════════════════════════════════════════════════════════════════════

  // ═══════════════════════════════════════════════════════════════════════
  //  ANNOUNCEMENTS
  // ═══════════════════════════════════════════════════════════════════════

  final List<Announcement> _announcements = [];
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _announcementsSub;

  List<Announcement> get announcements => List.unmodifiable(_announcements);

  void _listenAnnouncements() {
    _announcementsSub?.cancel();
    _announcementsSub = _firestore
        .collection('announcements')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _announcements
        ..clear()
        ..addAll(
          snapshot.docs.map((d) => Announcement.fromMap(d.id, d.data())),
        );
      notifyListeners();
    }, onError: (e) {
      debugPrint('Error in announcements listener: $e');
    });
  }

  Future<void> addAnnouncement(Announcement a) async {
    await _firestore.collection('announcements').doc(a.id).set({
      ...a.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateAnnouncement(String id, Announcement updated) async {
    await _firestore.collection('announcements').doc(id).set({
      ...updated.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteAnnouncement(String id) async {
    await _firestore.collection('announcements').doc(id).delete();
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  ORDERS
  // ═══════════════════════════════════════════════════════════════════════

  // ═══════════════════════════════════════════════════════════════════════
  //  ORDERS
  // ═══════════════════════════════════════════════════════════════════════

  final List<Order> _orders = [];
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _ordersSub;

  List<Order> get orders => List.unmodifiable(_orders);

  void _listenOrders() {
    _ordersSub?.cancel();
    _ordersSub = _firestore
        .collection('orders')
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isEmpty && _orders.isEmpty) {
        _initializeDefaultOrders();
      }
      _orders
        ..clear()
        ..addAll(snapshot.docs.map((d) => Order.fromMap(d.id, d.data())));
      notifyListeners();
    }, onError: (e) {
      if (e.toString().contains('permission-denied')) return;
      debugPrint('Error in orders listener: $e');
    });
  }

  Future<void> _initializeDefaultOrders() async {
    final batch = _firestore.batch();
    final defaults = [
      Order(
        id: 'JGS-10234',
        userId: '',
        customerName: 'Priya Sharma',
        phone: '9876543210',
        address: '45, MG Road, Near Temple',
        pincode: '452001',
        city: 'Indore',
        total: 1299,
        date: 'Mar 8, 2026',
        status: 'Delivered',
        items: [
          const OrderLineItem(name: 'Lakme 9to5 Primer + Matte Lipstick', qty: 1, price: 649),
          const OrderLineItem(name: 'Maybelline Fit Me Foundation', qty: 1, price: 650),
        ],
      ),
    ];
    for (var o in defaults) {
      batch.set(_firestore.collection('orders').doc(o.id), {
        ...o.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  Future<void> updateOrderStatus(String id, String status) async {
    await _firestore.collection('orders').doc(id).update({'status': status});
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  USERS / MEMBERSHIP
  // ═══════════════════════════════════════════════════════════════════════

  Future<void> toggleMembership(String userId, bool isMember) async {
    await _firestore.collection('users').doc(userId).set({
      'isMember': isMember,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  SMS / ALERTS LOG
  // ═══════════════════════════════════════════════════════════════════════

  final List<SmsAlert> _sentAlerts = [];
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _alertsSub;

  List<SmsAlert> get sentAlerts => List.unmodifiable(_sentAlerts);

  void _listenAlerts() {
    _alertsSub?.cancel();
    _alertsSub = _firestore
        .collection('alerts')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _sentAlerts
        ..clear()
        ..addAll(snapshot.docs.map((d) => SmsAlert.fromMap(d.id, d.data())));
      notifyListeners();
    }, onError: (e) {
      if (e.toString().contains('permission-denied')) return;
      debugPrint('Error in alerts listener: $e');
    });
  }

  Future<void> sendAlert(SmsAlert alert) async {
    // 1. Log to history (handled by cloud function as well, but we can do it locally for immediate UI)
    // Actually, let's just call the function and let it handle everything.
    try {
      final callable = _functions.httpsCallable('sendBulkAlert');
      final result = await callable.call({
        'title': alert.title,
        'message': alert.message,
        'sentTo': alert.sentTo,
        'type': alert.type,
      });

      if (result.data['success'] == true) {
        debugPrint('Bulk alert sent successfully: ${result.data['summary']}');
      }
    } catch (e) {
      debugPrint('Error sending bulk alert: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _productsSub?.cancel();
    _couponsSub?.cancel();
    _announcementsSub?.cancel();
    _ordersSub?.cancel();
    _alertsSub?.cancel();
    super.dispose();
  }
}
