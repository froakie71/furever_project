import 'package:cloud_firestore/cloud_firestore.dart';

class Donation {
  final String id;
  final String userId;
  final String userEmail;
  final double amount;
  final String? imageUrl;
  final DateTime timestamp;

  Donation({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.amount,
    this.imageUrl,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'amount': amount,
      'imageUrl': imageUrl,
      'timestamp': timestamp,
    };
  }

  factory Donation.fromMap(String id, Map<String, dynamic> map) {
    return Donation(
      id: id,
      userId: map['userId'] ?? '',
      userEmail: map['userEmail'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}