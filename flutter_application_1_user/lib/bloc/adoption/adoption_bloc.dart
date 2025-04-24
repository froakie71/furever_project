import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1_user/bloc/adoption/adoption_event.dart';
import 'package:flutter_application_1_user/bloc/adoption/adoption_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdoptionBloc extends Bloc<AdoptionEvent, AdoptionState> {
  final FirebaseFirestore _firestore;

  AdoptionBloc({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      super(AdoptionInitial()) {
    on<SubmitAdoption>(_onSubmitAdoption);
    on<RequestAdoption>(_onRequestAdoption);
  }

  Future<void> _onSubmitAdoption(
    SubmitAdoption event,
    Emitter<AdoptionState> emit,
  ) async {
    emit(AdoptionLoading());

    try {
      final batch = _firestore.batch();

      // Create adoption document
      final adoptionRef = _firestore.collection('adoptions').doc();
      batch.set(adoptionRef, {
        'dogId': event.dog.id,
        'dogName': event.dog.name,
        'dogImageUrl': event.dog.imageUrl,
        'userId': event.userId,
        'userEmail': event.userEmail,
        'status': 'pending', // Set initial status as pending
        'submittedAt': FieldValue.serverTimestamp(),
      });

      // Update dog document to pending status
      final dogRef = _firestore.collection('dogs').doc(event.dog.id);
      batch.update(dogRef, {
        'status': 'pending',
        'pendingAdoption': {
          'userId': event.userId,
          'userEmail': event.userEmail,
          'submittedAt': FieldValue.serverTimestamp(),
          'adoptionId': adoptionRef.id,
        },
      });

      await batch.commit();
      emit(AdoptionSuccess());
    } catch (e) {
      emit(AdoptionError(e.toString()));
    }
  }

  Future<void> _onRequestAdoption(
    RequestAdoption event,
    Emitter<AdoptionState> emit,
  ) async {
    try {
      emit(AdoptionLoading());

      final batch = _firestore.batch();

      // Create adoption document
      final adoptionRef = _firestore.collection('adoptions').doc();
      batch.set(adoptionRef, {
        'userId': event.userId,
        'dogId': event.dogId,
        'status': 'pending',
        'submittedAt': FieldValue.serverTimestamp(),
        'adoptionId': adoptionRef.id, // Add this line
        'isDeclined': false, // Add this field to track declined status
      });

      // Update dog status to pending
      final dogRef = _firestore.collection('dogs').doc(event.dogId);
      batch.update(dogRef, {
        'status': 'pending',
        'pendingAdoption': {
          // Add this nested object
          'userId': event.userId,
          'submittedAt': FieldValue.serverTimestamp(),
          'adoptionId': adoptionRef.id,
          'status': 'pending',
        },
      });

      await batch.commit();

      // Fetch username from users collection
      String? username;
      String? email;
      final userDoc =
          await _firestore.collection('users').doc(event.userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        if (userData != null) {
          if (userData['username'] != null &&
              userData['username'].toString().trim().isNotEmpty) {
            username = userData['username'];
          }
          if (userData['email'] != null &&
              userData['email'].toString().trim().isNotEmpty) {
            email = userData['email'];
          }
        }
      }

      // Fetch dog name for notification (optional, if not already available)
      final dogDoc = await _firestore.collection('dogs').doc(event.dogId).get();
      final dogName =
          dogDoc.exists ? (dogDoc.data()?['name'] ?? 'the dog') : 'the dog';

      // Admin notification (for the admin panel)
      await _firestore.collection('notifications').add({
        'type': 'adoption_request',
        'message':
            '${(username != null && username.trim().isNotEmpty) ? username : (email != null && email.contains('@') ? email.split('@')[0] + '@' : "A user")} wants to adopt the dog: $dogName',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'userId': event.userId,
        'username': username,
        'email': email,
        'dogId': event.dogId,
        'dogName': dogName,
        'recipient': 'admin', // <-- Add this line
      });

      await FirebaseFirestore.instance.collection('notifications').add({
        'type': 'adoption_admin',
        'message': '${username ?? email} wants to adopt the dog: $dogName',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'dogId': event.dogId,
        'dogName': dogName,
        // Do NOT include 'userId' for admin notifications
      });

      emit(AdoptionSuccess());
    } catch (e) {
      emit(AdoptionError(e.toString()));
    }
  }

  // Add this new method to handle declined adoptions
  Future<void> updateAdoptionStatus(
    String adoptionId,
    String dogId,
    bool isDeclined,
  ) async {
    try {
      final batch = _firestore.batch();

      if (isDeclined) {
        // Instead of deleting, update the adoption status to 'declined'
        final adoptionRef = _firestore.collection('adoptions').doc(adoptionId);
        batch.update(adoptionRef, {
          'status': 'declined',
          'declinedAt': FieldValue.serverTimestamp(),
        });

        // Update dog status back to available
        final dogRef = _firestore.collection('dogs').doc(dogId);
        batch.update(dogRef, {
          'status': 'available',
          'pendingAdoption': FieldValue.delete(),
        });
      } else {
        // If approved, update both documents
        final adoptionRef = _firestore.collection('adoptions').doc(adoptionId);
        batch.update(adoptionRef, {
          'status': 'approved',
          'approvedAt': FieldValue.serverTimestamp(),
        });

        final dogRef = _firestore.collection('dogs').doc(dogId);
        batch.update(dogRef, {
          'status': 'adopted',
          'pendingAdoption': {
            'status': 'approved',
            'approvedAt': FieldValue.serverTimestamp(),
          },
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to update adoption status: $e');
    }
  }
}
