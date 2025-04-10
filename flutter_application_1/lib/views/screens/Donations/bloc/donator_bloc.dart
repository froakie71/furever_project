import 'package:flutter_application_1/models/user_donations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'donator_event.dart';
import 'donator_state.dart';

class DonatorBloc extends Bloc<DonatorEvent, DonatorState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DonatorBloc() : super(DonatorInitial()) {
    on<LoadDonators>((event, emit) async {
      emit(DonatorLoading());
      try {
        final QuerySnapshot snapshot = await _firestore
            .collection('donations')
            .orderBy('timestamp', descending: true)
            .get();

        // Convert to DonationHistory objects
        final List<DonationHistory> allDonations = snapshot.docs
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
        final List<UserDonations> userDonations = groupedDonations.values
            .map((donations) => UserDonations.fromDonations(donations))
            .toList();

        // Sort by total amount
        userDonations.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

        emit(DonatorSuccess(userDonations: userDonations));
      } catch (e) {
        print('Error loading donations: $e');
        emit(DonatorError(e.toString()));
      }
    });

    on<AddDonator>((event, emit) async {
      emit(DonatorLoading());
      try {
        await _firestore.collection('donations').add({
          'amount': event.amount,
          'timestamp': Timestamp.now(),
          'userEmail': event.name, // Using name as email for now
          'userId': '', // You might want to get this from auth
          'imageUrl': '', // Handle image upload separately
        });
        add(LoadDonators());
      } catch (e) {
        emit(DonatorError(e.toString()));
      }
    });
  }
}
