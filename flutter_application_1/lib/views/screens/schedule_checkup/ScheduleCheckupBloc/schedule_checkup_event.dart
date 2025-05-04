abstract class ScheduleCheckupEvent {}

class ApproveCheckup extends ScheduleCheckupEvent {
  final String checkupId;
  ApproveCheckup(this.checkupId);
}

class DisapproveCheckup extends ScheduleCheckupEvent {
  final String checkupId;
  DisapproveCheckup(this.checkupId);
}
