import 'package:flutter_application_1/models/user_donations.dart';

abstract class DonatorState {}

class DonatorInitial extends DonatorState {}

class DonatorLoading extends DonatorState {}

class DonatorSuccess extends DonatorState {
  final List<UserDonations> userDonations;

  DonatorSuccess({required this.userDonations});
}

class DonatorError extends DonatorState {
  final String message;

  DonatorError(this.message);
}
