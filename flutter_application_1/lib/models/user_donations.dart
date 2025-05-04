import 'package:cloud_firestore/cloud_firestore.dart';

class UserDonations {
  final String userEmail;
  final String userId;
  final List<DonationHistory> donations;
  final double totalAmount;

  UserDonations({
    required this.userEmail,
    required this.userId,
    required this.donations,
    required this.totalAmount,
  });

  factory UserDonations.fromDonations(List<DonationHistory> donations) {
    final firstDonation = donations.first;
    final total = donations.fold(
      0.0,
      (sum, donation) => sum + double.parse(donation.amount),
    );

    return UserDonations(
      userEmail: firstDonation.userEmail,
      userId: firstDonation.userId,
      donations: donations,
      totalAmount: total,
    );
  }
}

class DonationHistory {
  final String amount;
  final DateTime date;
  final String imageUrl;
  final String userEmail;
  final String userId;

  DonationHistory({
    required this.amount,
    required this.date,
    required this.imageUrl,
    required this.userEmail,
    required this.userId,
  });

  factory DonationHistory.fromFirestore(Map<String, dynamic> data) {
    return DonationHistory(
      amount: data['amount'].toString(),
      date: (data['timestamp'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'] ?? '',
      userEmail: data['userEmail'] ?? '',
      userId: data['userId'] ?? '',
    );
  }
}