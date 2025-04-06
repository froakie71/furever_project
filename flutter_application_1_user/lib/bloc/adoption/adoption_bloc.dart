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
}
