// BLoC
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/views/screens/ProcessAdoption/bloc/adoption_event.dart';
import 'package:flutter_application_1/views/screens/ProcessAdoption/bloc/adoption_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdoptionBloc extends Bloc<AdoptionEvent, AdoptionState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AdoptionBloc() : super(AdoptionInitial()) {
    on<LoadPendingAdoptions>(_onLoadPendingAdoptions);
    on<UpdateAdoptionStatus>(_onUpdateAdoptionStatus);
    // Remove AcceptAdoption and DeclineAdoption handlers since we're using UpdateAdoptionStatus
  }

  Future<void> _onLoadPendingAdoptions(
    LoadPendingAdoptions event,
    Emitter<AdoptionState> emit,
  ) async {
    emit(AdoptionLoading());
    try {
      final snapshot = await _firestore
          .collection('adoptions')
          .where('status', isEqualTo: 'pending')
          .get();

      final adoptions = await Future.wait(
        snapshot.docs.map((doc) async {
          final data = doc.data();
          final dogSnapshot = await _firestore
              .collection('dogs')
              .doc(data['dogId'])
              .get();
          
          return {
            'id': doc.id,
            ...data,
            'dogData': dogSnapshot.data(),
          };
        }),
      );

      emit(AdoptionLoaded(adoptions));
    } catch (e) {
      emit(AdoptionError(e.toString()));
    }
  }

  Future<void> _onUpdateAdoptionStatus(
    UpdateAdoptionStatus event,
    Emitter<AdoptionState> emit,
  ) async {
    try {
      emit(AdoptionLoading());
      final batch = _firestore.batch();

      if (event.isDeclined) {
        // Delete the adoption document if declined
        final adoptionRef = _firestore.collection('adoptions').doc(event.adoptionId);
        batch.delete(adoptionRef);

        // Update dog status back to available
        final dogRef = _firestore.collection('dogs').doc(event.dogId);
        batch.update(dogRef, {
          'status': 'available',
          'pendingAdoption': FieldValue.delete(),
        });
      } else {
        // Update both documents if approved
        final adoptionRef = _firestore.collection('adoptions').doc(event.adoptionId);
        batch.update(adoptionRef, {
          'status': 'approved',
          'approvedAt': FieldValue.serverTimestamp(),
        });

        final dogRef = _firestore.collection('dogs').doc(event.dogId);
        batch.update(dogRef, {
          'status': 'adopted',
          'pendingAdoption.status': 'approved',
          'pendingAdoption.approvedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      emit(AdoptionSuccess());
      
      // Reload pending adoptions after status update
      add(LoadPendingAdoptions());
    } catch (e) {
      emit(AdoptionError(e.toString()));
    }
  }

  // Helper method to be called from UI
  void updateAdoptionStatus(String adoptionId, String dogId, bool isDeclined) {
    add(UpdateAdoptionStatus(
      adoptionId: adoptionId,
      dogId: dogId,
      isDeclined: isDeclined,
    ));
  }
}