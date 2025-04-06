import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final String location;
  final String description;
  final DateTime date;
  final String time;
  final String imageUrl;

  Event({
    required this.id,
    required this.title,
    required this.location,
    required this.description,
    required this.date,
    required this.time,
    required this.imageUrl,
  });

  factory Event.fromFirestore(Map<String, dynamic> data, String id) {
    return Event(
      id: id,
      title: data['title'] ?? '',
      location: data['location'] ?? '',
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      time: data['time'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
    );
  }
}