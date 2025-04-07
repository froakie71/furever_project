// Bloc
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1_user/bloc/event_registration/event_registration_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'event_registration_state.dart';

class EventRegistrationBloc
    extends Bloc<EventRegistrationEvent, EventRegistrationState> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  Set<String> _registeredEventIds =
      {}; // Add this line to cache the registered events

  EventRegistrationBloc() : super(EventRegistrationInitial()) {
    on<RegisterForEvent>(_onRegisterForEvent);
    on<LoadParticipatedEvents>(_onLoadParticipatedEvents);
    on<CheckRegisteredEvents>(_onCheckRegisteredEvents);

    // Initialize by checking registered events
    add(CheckRegisteredEvents());
  }

  Future<void> _onRegisterForEvent(
    RegisterForEvent event,
    Emitter<EventRegistrationState> emit,
  ) async {
    try {
      emit(EventRegistrationLoading());

      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Check if already registered
      if (_registeredEventIds.contains(event.eventId)) {
        emit(EventRegistrationError('Already registered for this event'));
        return;
      }

      await _firestore.collection('event_registrations').add({
        'eventId': event.eventId,
        'userId': user.uid,
        'userEmail': user.email,
        'registeredAt': FieldValue.serverTimestamp(),
      });

      _registeredEventIds.add(event.eventId); // Add to cached set
      emit(EventRegistrationSuccess());

      // Refresh registered events list
      add(CheckRegisteredEvents());
    } catch (e) {
      emit(EventRegistrationError(e.toString()));
    }
  }

  Future<void> _onCheckRegisteredEvents(
    CheckRegisteredEvents event,
    Emitter<EventRegistrationState> emit,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final registrations =
          await _firestore
              .collection('event_registrations')
              .where('userId', isEqualTo: user.uid)
              .get();

      _registeredEventIds =
          registrations.docs
              .map((doc) => doc.data()['eventId'] as String)
              .toSet();

      emit(RegisteredEventsLoaded(_registeredEventIds));
    } catch (e) {
      emit(EventRegistrationError(e.toString()));
    }
  }

  Future<void> _onLoadParticipatedEvents(
    LoadParticipatedEvents event,
    Emitter<EventRegistrationState> emit,
  ) async {
    try {
      emit(EventRegistrationLoading());

      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final registrations =
          await _firestore
              .collection('event_registrations')
              .where('userId', isEqualTo: user.uid)
              .get();

      final List<Map<String, dynamic>> participatedEvents = [];

      for (var reg in registrations.docs) {
        final eventDoc =
            await _firestore
                .collection('events')
                .doc(reg.data()['eventId'])
                .get();

        if (eventDoc.exists) {
          participatedEvents.add({
            ...eventDoc.data()!,
            'id': eventDoc.id,
            'registeredAt': reg.data()['registeredAt'],
          });
        }
      }

      emit(ParticipatedEventsLoaded(participatedEvents));
    } catch (e) {
      emit(EventRegistrationError(e.toString()));
    }
  }
}
