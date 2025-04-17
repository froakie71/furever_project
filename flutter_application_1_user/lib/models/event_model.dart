import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final String imageUrl;
  final DateTime date;
  final String time;
  final String description;
  final String location;

  Event({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.date,
    required this.time,
    required this.description,
    required this.location,
  });

  factory Event.fromFirestore(Map<String, dynamic> data, String id) {
    return Event(
      id: id,
      title: data['title'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      time: data['time'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
    );
  }

  // Add this method to convert Event to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'date': Timestamp.fromDate(date),
      'time': time,
      'description': description,
      'location': location,
    };
  }
}
