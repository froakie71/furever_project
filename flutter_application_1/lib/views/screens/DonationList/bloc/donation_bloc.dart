import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_1/models/user_donations.dart';
import 'donation_event.dart';
import 'donation_state.dart';

class DonationBloc extends Bloc<DonationEvent, DonationState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DonationBloc() : super(DonationInitial()) {
    on<LoadDonations>((event, emit) async {
      emit(DonationLoading());
      try {
        final QuerySnapshot snapshot =
            await _firestore
                .collection('donations')
                .orderBy('timestamp', descending: true)
                .get();

        // Convert to DonationHistory objects
        final List<DonationHistory> allDonations =
            snapshot.docs
                .map(
                  (doc) => DonationHistory.fromFirestore(
                    doc.data() as Map<String, dynamic>,
                  ),
                )
                .toList();

        // Group by user email
        final Map<String, List<DonationHistory>> groupedDonations = {};
        for (var donation in allDonations) {
          if (!groupedDonations.containsKey(donation.userEmail)) {
            groupedDonations[donation.userEmail] = [];
          }
          groupedDonations[donation.userEmail]!.add(donation);
        }

        // Convert to UserDonations objects
        final List<UserDonations> userDonations =
            groupedDonations.entries
                .map((entry) => UserDonations.fromDonations(entry.value))
                .toList();

        // Sort by total amount
        userDonations.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

        emit(DonationSuccess(donations: userDonations));
      } catch (e) {
        emit(DonationError(e.toString()));
      }
    });

    on<AddDonation>((event, emit) async {
      try {
        await _firestore.collection('donations').add({
          'userEmail': event.email,
          'amount': event.amount,
          'imageUrl': event.imageUrl,
          'timestamp': FieldValue.serverTimestamp(),
          'userId': '', // You might want to get this from auth
        });
        add(LoadDonations());
      } catch (e) {
        emit(DonationError(e.toString()));
      }
    });
  }
}
