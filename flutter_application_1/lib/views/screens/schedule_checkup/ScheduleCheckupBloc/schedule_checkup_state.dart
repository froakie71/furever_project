abstract class ScheduleCheckupState {}

class ScheduleCheckupInitial extends ScheduleCheckupState {}

class ScheduleCheckupLoading extends ScheduleCheckupState {}

class ScheduleCheckupLoaded extends ScheduleCheckupState {
  final Map<String, dynamic>? checkupData;
  ScheduleCheckupLoaded(this.checkupData);
}

class ScheduleCheckupError extends ScheduleCheckupState {
  final String message;
  ScheduleCheckupError(this.message);
}
