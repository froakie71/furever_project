import 'package:flutter_application_1_user/models/rescue_report.dart';

abstract class RescueReportState {}

class RescueReportInitial extends RescueReportState {}

class RescueReportLoading extends RescueReportState {}

class RescueReportSuccess extends RescueReportState {
  final List<RescueReport> reports;
  RescueReportSuccess(this.reports);
}

class RescueReportError extends RescueReportState {
  final String message;
  RescueReportError(this.message);
}