import 'package:flutter/material.dart';

/// Announcement model used by both admin and announcements page.
class Announcement {
  final String id;
  final String title;
  final String subtitle;
  final String body;
  final String date;
  final String tag; // e.g. NEW ARRIVALS, OFFER, EXCLUSIVE
  final String category; // e.g. New Arrivals, Offers, Updates, News
  final Color tagColor;
  final IconData icon;
  final String? imageUrl; // optional image URL / asset path

  const Announcement({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.date,
    required this.tag,
    required this.category,
    required this.tagColor,
    required this.icon,
    this.imageUrl,
  });

  Announcement copyWith({
    String? title,
    String? subtitle,
    String? body,
    String? date,
    String? tag,
    String? category,
    Color? tagColor,
    IconData? icon,
    String? imageUrl,
  }) {
    return Announcement(
      id: id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      body: body ?? this.body,
      date: date ?? this.date,
      tag: tag ?? this.tag,
      category: category ?? this.category,
      tagColor: tagColor ?? this.tagColor,
      icon: icon ?? this.icon,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'subtitle': subtitle,
        'body': body,
        'date': date,
        'tag': tag,
        'category': category,
        'tagColor': tagColor.toARGB32(),
        'icon': icon.codePoint,
        'imageUrl': imageUrl,
      };

  factory Announcement.fromMap(String id, Map<String, dynamic> map) {
    return Announcement(
      id: id,
      title: map['title']?.toString() ?? '',
      subtitle: map['subtitle']?.toString() ?? '',
      body: map['body']?.toString() ?? '',
      date: map['date']?.toString() ?? '',
      tag: map['tag']?.toString() ?? '',
      category: map['category']?.toString() ?? '',
      tagColor: Color((map['tagColor'] as num?)?.toInt() ?? 0xFF000000),
      icon: IconData((map['icon'] as num?)?.toInt() ?? 0xe3e7, fontFamily: 'MaterialIcons'),
      imageUrl: map['imageUrl']?.toString(),
    );
  }
}
