/// Order model for admin order management.
class Order {
  final String id;
  final String userId;
  final String customerName;
  final String phone;
  final String address;
  final String pincode;
  final String city;
  final double total;
  final String date;
  String status; // Pending, Confirmed, Shipped, Delivered, Cancelled
  final List<OrderLineItem> items;

  Order({
    required this.id,
    required this.userId,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.pincode,
    required this.city,
    required this.total,
    required this.date,
    required this.status,
    required this.items,
  });

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'customerName': customerName,
        'phone': phone,
        'address': address,
        'pincode': pincode,
        'city': city,
        'total': total,
        'date': date,
        'status': status,
        'items': items.map((i) => i.toMap()).toList(),
      };

  factory Order.fromMap(String id, Map<String, dynamic> map) {
    return Order(
      id: id,
      userId: map['userId']?.toString() ?? '',
      customerName: map['customerName']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      pincode: map['pincode']?.toString() ?? '',
      city: map['city']?.toString() ?? '',
      total: (map['total'] as num?)?.toDouble() ?? 0,
      date: map['date']?.toString() ?? '',
      status: map['status']?.toString() ?? 'Pending',
      items: (map['items'] as List? ?? [])
          .map((i) => OrderLineItem.fromMap(i as Map<String, dynamic>))
          .toList(),
    );
  }
}

class OrderLineItem {
  final String name;
  final int qty;
  final double price;

  const OrderLineItem({
    required this.name,
    required this.qty,
    required this.price,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'qty': qty,
        'price': price,
      };

  factory OrderLineItem.fromMap(Map<String, dynamic> map) {
    return OrderLineItem(
      name: map['name']?.toString() ?? '',
      qty: (map['qty'] as num?)?.toInt() ?? 0,
      price: (map['price'] as num?)?.toDouble() ?? 0,
    );
  }
}
