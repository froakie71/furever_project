abstract class EventRegistrationEvent {}

class RegisterForEvent extends EventRegistrationEvent {
  final String eventId;
  RegisterForEvent(this.eventId);
}

class LoadParticipatedEvents extends EventRegistrationEvent {}

class CheckRegisteredEvents extends EventRegistrationEvent {}
