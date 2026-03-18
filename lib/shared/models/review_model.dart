import 'package:cloud_firestore/cloud_firestore.dart';

class ProductReview {
  final String id;
  final String productId;
  final String productName;
  final String userId;
  final String userName;
  final int rating;
  final String comment;
  final DateTime? createdAt;

  const ProductReview({
    required this.id,
    required this.productId,
    required this.productName,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    this.createdAt,
  });

  factory ProductReview.fromMap(String id, Map<String, dynamic> map) {
    final createdRaw = map['createdAt'];
    DateTime? created;
    if (createdRaw is Timestamp) {
      created = createdRaw.toDate();
    } else if (createdRaw is String) {
      created = DateTime.tryParse(createdRaw);
    }

    return ProductReview(
      id: id,
      productId: map['productId'] as String? ?? '',
      productName: map['productName'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      userName: map['userName'] as String? ?? 'Anonymous',
      rating: (map['rating'] as num?)?.round() ?? 5,
      comment: map['comment'] as String? ?? '',
      createdAt: created,
    );
  }

  Map<String, dynamic> toMap() => {
    'productId': productId,
    'productName': productName,
    'userId': userId,
    'userName': userName,
    'rating': rating,
    'comment': comment,
    'createdAt': FieldValue.serverTimestamp(),
  };
}
