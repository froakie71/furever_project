abstract class EventState {}

class EventInitial extends EventState {}

class EventLoading extends EventState {}

class EventSuccess extends EventState {}

class EventFailure extends EventState {
  final String error;

  EventFailure(this.error);
}