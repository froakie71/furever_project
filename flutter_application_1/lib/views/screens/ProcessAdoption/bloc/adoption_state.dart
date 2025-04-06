// States
abstract class AdoptionState {}

class AdoptionInitial extends AdoptionState {}
class AdoptionLoading extends AdoptionState {}
class AdoptionLoaded extends AdoptionState {
  final List<Map<String, dynamic>> adoptions;
  AdoptionLoaded(this.adoptions);
}
class AdoptionError extends AdoptionState {
  final String message;
  AdoptionError(this.message);
}
