import 'package:flutter_application_1_user/models/dog_model.dart';

abstract class AdoptionEvent {}

class SubmitAdoption extends AdoptionEvent {
  final Dog dog;
  final String userId;
  final String userEmail;

  SubmitAdoption({
    required this.dog,
    required this.userId,
    required this.userEmail,
  });
}

class RequestAdoption extends AdoptionEvent {
  final String userId;
  final String dogId;

  RequestAdoption({
    required this.userId,
    required this.dogId,
  });
}
