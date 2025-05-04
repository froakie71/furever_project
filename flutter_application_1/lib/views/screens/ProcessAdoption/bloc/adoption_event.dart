// Events
abstract class AdoptionEvent {}

class LoadPendingAdoptions extends AdoptionEvent {}
class AcceptAdoption extends AdoptionEvent {
  final String adoptionId;
  final String dogId;
  AcceptAdoption({required this.adoptionId, required this.dogId});
}
class DeclineAdoption extends AdoptionEvent {
  final String adoptionId;
  final String dogId;
  DeclineAdoption({required this.adoptionId, required this.dogId});
}

class UpdateAdoptionStatus extends AdoptionEvent {
  final String adoptionId;
  final String dogId;
  final bool isDeclined;

  UpdateAdoptionStatus({
    required this.adoptionId,
    required this.dogId,
    required this.isDeclined,
  });
}
