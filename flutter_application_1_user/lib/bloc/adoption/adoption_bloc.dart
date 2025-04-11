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
        // If declined, delete the adoption document
        final adoptionRef = _firestore.collection('adoptions').doc(adoptionId);
        batch.delete(adoptionRef);

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
