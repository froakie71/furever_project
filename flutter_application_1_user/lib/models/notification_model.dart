import 'package:cloud_firestore/cloud_firestore.dart';

class EventNotification {
  final String id;
  final String eventId;
  final String eventTitle;
  final String eventImage;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  EventNotification({
    required this.id,
    required this.eventId,
    required this.eventTitle,
    required this.eventImage,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });

  factory EventNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventNotification(
      id: doc.id,
      eventId: data['eventId'] ?? '',
      eventTitle: data['eventTitle'] ?? '',
      eventImage: data['eventImage'] ?? '',
      message: data['message'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
    );
  }
}