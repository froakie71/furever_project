abstract class ScheduleCheckupEvent {}

class LoadScheduleCheckup extends ScheduleCheckupEvent {
  final String dogId;
  final String userId;
  LoadScheduleCheckup(this.dogId, this.userId);
}

class AddOrUpdateScheduleCheckup extends ScheduleCheckupEvent {
  final String dogId;
  final String userId;
  final DateTime date;
  final String description;
  AddOrUpdateScheduleCheckup(this.dogId, this.userId, this.date, this.description);
}