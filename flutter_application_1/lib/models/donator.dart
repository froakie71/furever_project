import 'package:cloud_firestore/cloud_firestore.dart';

class Donator {
  final String name;
  final String amount;
  final DateTime date;
  final String imageUrl;
  final String userEmail;
  final String userId;

  Donator({
    required this.name,
    required this.amount,
    required this.date,
    required this.imageUrl,
    required this.userEmail,
    required this.userId,
  });

  factory Donator.fromFirestore(Map<String, dynamic> data) {
    return Donator(
      name: data['userEmail'] ?? '', // Using email as name for now
      amount: data['amount']?.toString() ?? '0',
      date: (data['timestamp'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'] ?? '',
      userEmail: data['userEmail'] ?? '',
      userId: data['userId'] ?? '',
    );
  }
}
