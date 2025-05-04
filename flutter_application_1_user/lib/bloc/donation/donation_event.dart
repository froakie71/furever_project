import 'dart:io';

abstract class DonationEvent {}

class LoadDonations extends DonationEvent {}

class LoadTopDonators extends DonationEvent {}

class SubmitDonation extends DonationEvent {
  final double amount;
  final File? imageFile;

  SubmitDonation({required this.amount, this.imageFile});
}

class LoadDonatorDetails extends DonationEvent {
  final String userId;
  final String email;

  LoadDonatorDetails({required this.userId, required this.email});
}
