/// SMS / Alert model for admin dashboard logs.
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

  Map<String, dynamic> toMap() => {
        'title': title,
        'message': message,
        'sentTo': sentTo,
        'sentAt': sentAt,
        'type': type,
      };

  factory SmsAlert.fromMap(String id, Map<String, dynamic> map) {
    return SmsAlert(
      id: id,
      title: map['title'] as String? ?? '',
      message: map['message'] as String? ?? '',
      sentTo: map['sentTo'] as String? ?? '',
      sentAt: map['sentAt'] as String? ?? '',
      type: map['type'] as String? ?? 'Promotional',
    );
  }
}
