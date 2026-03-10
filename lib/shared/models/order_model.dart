/// Order model for admin order management.
class Order {
  final String id;
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
}
