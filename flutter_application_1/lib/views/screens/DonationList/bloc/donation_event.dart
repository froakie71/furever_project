abstract class DonationEvent {}

class LoadDonations extends DonationEvent {}

class AddDonation extends DonationEvent {
  final String email;
  final String amount;
  final String imageUrl;

  AddDonation({
    required this.email,
    required this.amount,
    required this.imageUrl,
  });
}
