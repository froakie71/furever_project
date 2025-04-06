abstract class AdoptionState {}

class AdoptionInitial extends AdoptionState {}
class AdoptionLoading extends AdoptionState {}
class AdoptionSuccess extends AdoptionState {}
class AdoptionError extends AdoptionState {
  final String message;
  AdoptionError(this.message);
}