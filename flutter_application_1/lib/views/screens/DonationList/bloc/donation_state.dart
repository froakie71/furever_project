import 'package:flutter_application_1/models/user_donations.dart';

abstract class DonationState {}

class DonationInitial extends DonationState {}

class DonationLoading extends DonationState {}

class DonationSuccess extends DonationState {
  final List<UserDonations> donations;

  DonationSuccess({required this.donations});
}

class DonationError extends DonationState {
  final String message;

  DonationError(this.message);
}
