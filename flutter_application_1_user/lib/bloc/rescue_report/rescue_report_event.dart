abstract class RescueReportEvent {
  const RescueReportEvent();
}

class SubmitRescueReport extends RescueReportEvent {
  final String address;
  final String landmark;
  final String imagePath;
  final String
  phoneNumber; // Changed from int numberOfDogs to String phoneNumber

  const SubmitRescueReport({
    required this.address,
    required this.landmark,
    required this.imagePath,
    required this.phoneNumber, // Updated parameter name
  }) : super();

  @override
  List<Object> get props => [address, landmark, imagePath, phoneNumber]; // Updated props
}

class LoadRescueReports extends RescueReportEvent {
  const LoadRescueReports() : super();

  @override
  List<Object> get props => [];
}
