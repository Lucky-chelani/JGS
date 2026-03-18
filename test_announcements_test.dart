import 'package:flutter_test/flutter_test.dart';
import 'lib/shared/models/announcement_model.dart';
import 'dart:convert';

void main() {
  test('Announcement fromMap', () {
    final Map<String, dynamic> firestoreMap = {
      'title': 'Test',
      'tagColor': 4283184976, // 0xFF4CAF50
      'icon': 50000,
    };
    
    try {
      final ann = Announcement.fromMap('1', firestoreMap);
      print('Success: ${ann.title}');
    } catch (e, stack) {
      print('Error: $e\n$stack');
    }
  });
}
