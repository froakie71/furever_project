// ignore_for_file: avoid_types_as_parameter_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_application_1_user/bloc/donation/donation_event.dart';
import 'package:flutter_application_1_user/bloc/donation/donation_state.dart';
import 'package:flutter_application_1_user/models/donation_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DonationBloc extends Bloc<DonationEvent, DonationState> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  TopDonatorsLoaded? _lastTopDonatorsState;
  DonationSuccess? _lastDonationState;

  DonationBloc() : super(DonationInitial()) {
    on<LoadDonations>(_onLoadDonations);
    on<LoadTopDonators>(_onLoadTopDonators);
    on<SubmitDonation>(_onSubmitDonation);
    on<LoadDonatorDetails>(_onLoadDonatorDetails);
  }

  Future<void> _onLoadDonations(
    LoadDonations event,
    Emitter<DonationState> emit,
  ) async {
    try {
      // Only show loading on first load
      if (_lastDonationState == null) {
        emit(DonationLoading());
      }

      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Modified query to remove the need for composite index
      final donations =
          await _firestore
              .collection('donations')
              .where('userId', isEqualTo: user.uid)
              .get();

      final userDonations =
          donations.docs
              .map((doc) => Donation.fromMap(doc.id, doc.data()))
              .toList()
            ..sort(
              (a, b) => b.timestamp.compareTo(a.timestamp),
            ); // Sort in memory instead

      final totalAmount = userDonations.fold<double>(
        0,
        (sum, donation) => sum + donation.amount,
      );

      _lastDonationState = DonationSuccess(
        totalAmount: totalAmount,
        userDonations: userDonations,
      );
      emit(_lastDonationState!);
    } catch (e) {
      emit(DonationError(e.toString()));
    }
  }

  Future<void> _onLoadTopDonators(
    LoadTopDonators event,
    Emitter<DonationState> emit,
  ) async {
    try {
      // Only show loading on first load
      if (_lastTopDonatorsState == null) {
        emit(DonationLoading());
      }

      final QuerySnapshot donationsSnapshot =
          await _firestore
              .collection('donations')
              .orderBy('amount', descending: true)
              .get();

      if (donationsSnapshot.docs.isEmpty) {
        emit(TopDonatorsLoaded([]));
        return;
      }

      // Calculate user totals
      Map<String, Map<String, dynamic>> userTotals = {};

      for (var doc in donationsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final userId = data['userId'] as String;
        final email = data['userEmail'] as String;
        final amount = (data['amount'] as num).toDouble();

        if (!userTotals.containsKey(userId)) {
          userTotals[userId] = {'email': email, 'total': 0.0};
        }
        userTotals[userId]!['total'] += amount;
      }

      // Convert to list and sort
      List<Map<String, dynamic>> topDonators =
          userTotals.entries
              .map(
                (entry) => {
                  'userId': entry.key,
                  'email': entry.value['email'],
                  'total': entry.value['total'],
                },
              )
              .toList()
            ..sort(
              (a, b) => (b['total'] as double).compareTo(a['total'] as double),
            );

      // Take top 5 or less
      final topList = topDonators.take(5).toList();

      _lastTopDonatorsState = TopDonatorsLoaded(topList);
      emit(_lastTopDonatorsState!);
    } catch (e) {
      ('Error loading top donators: $e'); // Add debug print
      emit(DonationError('Failed to load top donators: $e'));
    }
  }

  Future<void> _onSubmitDonation(
    SubmitDonation event,
    Emitter<DonationState> emit,
  ) async {
    try {
      emit(DonationLoading());

      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      String? imageUrl;
      if (event.imageFile != null) {
        final ref = _storage
            .ref()
            .child('donation_receipts')
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

        await ref.putFile(event.imageFile!);
        imageUrl = await ref.getDownloadURL();
      }

      await _firestore.collection('donations').add({
        'userId': user.uid,
        'userEmail': user.email,
        'amount': event.amount,
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Fetch username from users collection
      String? username;
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        if (userData != null &&
            userData['username'] != null &&
            userData['username'].toString().trim().isNotEmpty) {
          username = userData['username'];
        }
      }

      // User notification (for the user themselves)
      await _createDonationNotification(
        userId: user.uid,
        userEmail: user.email ?? '',
        amount: event.amount,
        imageUrl: imageUrl,
      );

      // Admin notification (for the admin panel)
      await FirebaseFirestore.instance.collection('notifications').add({
        'type': 'donation_admin',
        'message':
            '${username ?? user.email?.split('@')[0] ?? "A user"} donated ₱${event.amount.toStringAsFixed(2)}',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'userId': 'admin', // <--- CHANGE THIS LINE
        'username': username,
        'email': user.email,
        'amount': event.amount,
      });

      // Wait for both operations to complete
      await Future.wait([
        _onLoadDonations(LoadDonations(), emit),
        _onLoadTopDonators(LoadTopDonators(), emit),
      ]);
    } catch (e) {
      emit(DonationError(e.toString()));
    }
  }

  Future<void> _onLoadDonatorDetails(
    LoadDonatorDetails event,
    Emitter<DonationState> emit,
  ) async {
    try {
      emit(DonationLoading());

      // Simplified query that doesn't require a composite index
      final donationsSnapshot =
          await _firestore
              .collection('donations')
              .where('userId', isEqualTo: event.userId)
              .get();

      if (donationsSnapshot.docs.isEmpty) {
        emit(
          DonatorDetailsLoaded(
            donatorId: event.userId,
            donatorEmail: event.email,
            donations: [],
          ),
        );
        return;
      }

      final donations =
          donationsSnapshot.docs.map((doc) {
              final data = doc.data();
              return {
                ...data,
                'id': doc.id,
                'timestamp': (data['timestamp'] as Timestamp).toDate(),
              };
            }).toList()
            // Sort in memory instead of in the query
            ..sort(
              (a, b) => (b['timestamp'] as DateTime).compareTo(
                a['timestamp'] as DateTime,
              ),
            );

      emit(
        DonatorDetailsLoaded(
          donatorId: event.userId,
          donatorEmail: event.email,
          donations: donations,
        ),
      );
    } catch (e) {
      emit(DonationError(e.toString()));
    }
  }

  Future<void> _createDonationNotification({
    required String userId,
    required String userEmail,
    required double amount,
    String? imageUrl,
  }) async {
    await _firestore.collection('notifications').add({
      'userId': userId,
      'eventId': null,
      'eventTitle': null,
      'eventImage': imageUrl,
      'message': 'You have donated ₱${amount.toStringAsFixed(2)}',
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
      'type': 'donation',
      'userEmail': userEmail,
    });
  }
}
