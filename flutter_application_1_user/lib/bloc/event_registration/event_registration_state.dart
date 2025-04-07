// State
abstract class EventRegistrationState {}

class EventRegistrationInitial extends EventRegistrationState {}

class EventRegistrationLoading extends EventRegistrationState {}

class EventRegistrationSuccess extends EventRegistrationState {}

class EventRegistrationError extends EventRegistrationState {
  final String message;
  EventRegistrationError(this.message);
}

class ParticipatedEventsLoaded extends EventRegistrationState {
  final List<Map<String, dynamic>> events;
  ParticipatedEventsLoaded(this.events);
}

class RegisteredEventsLoaded extends EventRegistrationState {
  final Set<String> registeredEventIds;
  RegisteredEventsLoaded(this.registeredEventIds);
}
