import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import '../../../shared/models/order_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrdersProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Order> _orders = [];
  bool _loading = false;
  String? _error;

  List<Order> get orders => [..._orders];
  bool get loading => _loading;
  String? get error => _error;

  Future<bool> saveOrder(Order order) async {
    try {
      await _firestore.collection('orders').doc(order.id).set({
        ...order.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      // Also add to active listener if the user is fetching right now
      _orders.insert(0, order);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error saving order: $e');
      _error = 'Failed to place order. Please try again.';
      return false;
    }
  }

  Future<void> fetchMyOrders() async {
    final user = _auth.currentUser;
    if (user == null) {
      _orders = [];
      notifyListeners();
      return;
    }

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();

      _orders = snapshot.docs
          .map((doc) => Order.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      bool isIndexError = false;
      if (e is FirebaseException) {
        if (e.code == 'failed-precondition' || e.message?.contains('index') == true) {
          isIndexError = true;
        }
      } else if (e.toString().toLowerCase().contains('index') || e.toString().toLowerCase().contains('failed-precondition')) {
        isIndexError = true;
      }

      if (isIndexError) {
         try {
           final fallbackSnapshot = await _firestore
              .collection('orders')
              .where('userId', isEqualTo: user.uid)
              .get();
           
           _orders = fallbackSnapshot.docs
              .map((doc) => Order.fromMap(doc.id, doc.data()))
              .toList();
            
           // Sort locally by id (which contains timestamp) descending
           _orders.sort((a, b) => b.id.compareTo(a.id)); 
           _error = null; // Clear error if fallback works
         } catch (e2) {
           debugPrint('EmailService: Fallback fetch failed: $e2');
           _orders = [];
           _error = 'Failed to load your orders. Please try again.';
         }
      } else {
        debugPrint('EmailService: Error fetching orders: $e');
        _orders = [];
        _error = 'Failed to load your orders. Please try again.';
      }
    }

    _loading = false;
    notifyListeners();
  }
}
