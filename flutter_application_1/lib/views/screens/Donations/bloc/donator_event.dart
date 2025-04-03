abstract class DonatorEvent {}

class AddDonator extends DonatorEvent {
  final String name;
  final String amount;

  AddDonator({required this.name, required this.amount});
}
