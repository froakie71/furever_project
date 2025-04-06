// BLoC
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/views/screens/ProcessAdoption/bloc/adoption_event.dart';
import 'package:flutter_application_1/views/screens/ProcessAdoption/bloc/adoption_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdoptionBloc extends Bloc<AdoptionEvent, AdoptionState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AdoptionBloc() : super(AdoptionInitial()) {
    on<LoadPendingAdoptions>(_onLoadPendingAdoptions);
    on<AcceptAdoption>(_onAcceptAdoption);
    on<DeclineAdoption>(_onDeclineAdoption);
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

  Future<void> _onAcceptAdoption(
    AcceptAdoption event,
    Emitter<AdoptionState> emit,
  ) async {
    try {
      final batch = _firestore.batch();

      // Update adoption status
      batch.update(
        _firestore.collection('adoptions').doc(event.adoptionId),
        {'status': 'accepted'},
      );

      // Update dog status
      batch.update(
        _firestore.collection('dogs').doc(event.dogId),
        {'status': 'adopted'},
      );

      await batch.commit();
      add(LoadPendingAdoptions());
    } catch (e) {
      emit(AdoptionError(e.toString()));
    }
  }

  Future<void> _onDeclineAdoption(
    DeclineAdoption event,
    Emitter<AdoptionState> emit,
  ) async {
    try {
      final batch = _firestore.batch();

      // Update adoption status
      batch.update(
        _firestore.collection('adoptions').doc(event.adoptionId),
        {'status': 'declined'},
      );

      // Update dog status back to available
      batch.update(
        _firestore.collection('dogs').doc(event.dogId),
        {
          'status': 'available',
          'adoptedBy': FieldValue.delete(),
        },
      );

      await batch.commit();
      add(LoadPendingAdoptions());
    } catch (e) {
      emit(AdoptionError(e.toString()));
    }
  }
}