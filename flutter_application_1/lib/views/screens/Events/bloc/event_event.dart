abstract class EventEvent {}

class CreateEvent extends EventEvent {
  final String title;
  final String location;
  final String description;
  final DateTime date;
  final String time;
  final String imageUrl;

  CreateEvent({
    required this.title,
    required this.location,
    required this.description,
    required this.date,
    required this.time,
    required this.imageUrl,
  });
}