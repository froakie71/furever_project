import 'package:flutter_application_1_user/models/donation_model.dart';

abstract class DonationState {}

class DonationInitial extends DonationState {}

class DonationLoading extends DonationState {}

class DonationSuccess extends DonationState {
  final double totalAmount;
  final List<Donation> userDonations;

  DonationSuccess({required this.totalAmount, required this.userDonations});
}

class TopDonatorsLoaded extends DonationState {
  final List<Map<String, dynamic>> topDonators;

  TopDonatorsLoaded(this.topDonators);
}

class DonatorDetailsLoaded extends DonationState {
  final String donatorId;
  final String donatorEmail;
  final List<Map<String, dynamic>> donations;

  DonatorDetailsLoaded({
    required this.donatorId,
    required this.donatorEmail,
    required this.donations,
  });
}

class DonationError extends DonationState {
  final String message;

  DonationError(this.message);
}
