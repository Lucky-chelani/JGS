import 'package:flutter/foundation.dart';
import '../../../shared/models/coupon_model.dart';

class CartItem {
  final String id;
  final String productId;
  final String title;
  final String? variantLabel;
  final String imageUrl;
  final double price;
  int quantity;

  CartItem({
    required this.id,
    required this.productId,
    required this.title,
    this.variantLabel,
    required this.imageUrl,
    required this.price,
    this.quantity = 1,
  });
}

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};
  Coupon? _appliedCoupon;
  bool _isPremiumMember = false;

  Map<String, CartItem> get items => {..._items};
  Coupon? get appliedCoupon => _appliedCoupon;
  bool get isPremiumMember => _isPremiumMember;

  int get itemCount => _items.length;

  int get totalQuantity {
    int count = 0;
    _items.forEach((key, item) {
      count += item.quantity;
    });
    return count;
  }

  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, item) {
      total += item.price * item.quantity;
    });
    return total;
  }

  double get couponDiscountAmount {
    if (_appliedCoupon == null) return 0.0;
    return _appliedCoupon!.calculateDiscount(totalAmount);
  }

  double get memberDiscountAmount {
    if (!_isPremiumMember || totalAmount < 1200) return 0.0;
    return totalAmount * 0.10;
  }

  double get totalDiscountAmount => couponDiscountAmount + memberDiscountAmount;

  double get finalAmount {
    return (totalAmount - totalDiscountAmount).clamp(0, double.infinity);
  }

  void setPremiumMember(bool value) {
    if (_isPremiumMember != value) {
      _isPremiumMember = value;
      notifyListeners();
    }
  }

  void applyCoupon(Coupon coupon) {
    _appliedCoupon = coupon;
    notifyListeners();
  }

  void removeCoupon() {
    _appliedCoupon = null;
    notifyListeners();
  }

  void addItem(
    String productId,
    String title,
    double price,
    String imageUrl, {
    String? variantLabel,
  }) {
    final lineKey = variantLabel == null || variantLabel.isEmpty
        ? productId
        : '${productId}_$variantLabel';

    if (_items.containsKey(lineKey)) {
      _items.update(
        lineKey,
        (existingItem) => CartItem(
          id: existingItem.id,
          productId: existingItem.productId,
          title: existingItem.title,
          variantLabel: existingItem.variantLabel,
          price: existingItem.price,
          imageUrl: existingItem.imageUrl,
          quantity: existingItem.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        lineKey,
        () => CartItem(
          id: DateTime.now().toString(),
          productId: productId,
          title: title,
          variantLabel: variantLabel,
          price: price,
          imageUrl: imageUrl,
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) return;
    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
        (existingItem) => CartItem(
          id: existingItem.id,
          productId: existingItem.productId,
          title: existingItem.title,
          variantLabel: existingItem.variantLabel,
          price: existingItem.price,
          imageUrl: existingItem.imageUrl,
          quantity: existingItem.quantity - 1,
        ),
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
