import 'package:flutter_application_1_user/models/event_model.dart';

abstract class EventRegistrationEvent {}

class RegisterForEvent extends EventRegistrationEvent {
  final Event event;
  RegisterForEvent(this.event);
}

class LoadParticipatedEvents extends EventRegistrationEvent {}

class CheckRegisteredEvents extends EventRegistrationEvent {}
