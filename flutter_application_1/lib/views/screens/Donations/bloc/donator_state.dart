abstract class DonatorState {}

class DonatorInitial extends DonatorState {}

class DonatorLoading extends DonatorState {}

class DonatorSuccess extends DonatorState {}

class DonatorError extends DonatorState {
  final String message;
  DonatorError(this.message);
}
