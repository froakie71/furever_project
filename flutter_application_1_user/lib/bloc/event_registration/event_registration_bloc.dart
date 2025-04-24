// Bloc
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_1_user/models/event_model.dart';
import 'package:flutter_application_1_user/bloc/event_registration/event_registration_event.dart';
import 'package:flutter_application_1_user/bloc/event_registration/event_registration_state.dart';

class EventRegistrationBloc
    extends Bloc<EventRegistrationEvent, EventRegistrationState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Set<String> _registeredEventIds = {};

  EventRegistrationBloc() : super(EventRegistrationInitial()) {
    on<RegisterForEvent>(_onRegisterForEvent);
    on<LoadParticipatedEvents>(_onLoadParticipatedEvents);
    on<CheckRegisteredEvents>(_onCheckRegisteredEvents);

    add(CheckRegisteredEvents());
  }

  Future<void> _onRegisterForEvent(
    RegisterForEvent event,
    Emitter<EventRegistrationState> emit,
  ) async {
    try {
      // Start with loading state
      emit(EventRegistrationLoading());

      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        emit(EventRegistrationFailure(error: 'User not logged in'));
        return;
      }

      // Check if already registered in memory
      if (_registeredEventIds.contains(event.event.id)) {
        emit(
          EventRegistrationFailure(error: 'Already registered for this event'),
        );
        return;
      }

      // Check if registration exists in Firestore
      final existingRegistration =
          await _firestore
              .collection('event_registrations')
              .where('eventId', isEqualTo: event.event.id)
              .where('userId', isEqualTo: currentUser.uid)
              .get();

      if (existingRegistration.docs.isNotEmpty) {
        emit(
          EventRegistrationFailure(error: 'Already registered for this event'),
        );
        return;
      }

      // Create registration document
      final registration = await _firestore
          .collection('event_registrations')
          .add({
            'eventId': event.event.id,
            'eventTitle': event.event.title,
            'userId': currentUser.uid,
            'userEmail': currentUser.email,
            'registeredAt': FieldValue.serverTimestamp(),
          });

      if (registration.id.isNotEmpty) {
        _registeredEventIds.add(event.event.id);

        // Create notification (for the user)
        await _createEventNotification(
          event.event.id,
          event.event.title,
          event.event.imageUrl,
        );

        // Fetch username from users collection
        String? username;
        final userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(currentUser.uid)
                .get();
        if (userDoc.exists) {
          final userData = userDoc.data();
          if (userData != null &&
              userData['username'] != null &&
              userData['username'].toString().trim().isNotEmpty) {
            username = userData['username'];
          }
        }

        // Admin notification (for the admin panel)
        await FirebaseFirestore.instance.collection('notifications').add({
          'type': 'event_join',
          'message':
              '${username ?? (currentUser.email != null && currentUser.email!.contains('@') ? currentUser.email!.split('@')[0] + '@' : "A user")} joined the event: ${event.event.title}',
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
          'username': username,
          'email': currentUser.email,
          'eventId': event.event.id,
          'eventTitle': event.event.title,
        });

        emit(EventRegistrationSuccess());
        // Do NOT emit RegisteredEventsLoaded here!
        // Instead, trigger CheckRegisteredEvents from the UI after showing the SnackBar
      } else {
        emit(EventRegistrationFailure(error: 'Failed to register for event'));
      }
    } catch (e) {
      emit(EventRegistrationFailure(error: e.toString()));
    }
  }

  Future<void> _onCheckRegisteredEvents(
    CheckRegisteredEvents event,
    Emitter<EventRegistrationState> emit,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        emit(EventRegistrationFailure(error: 'User not logged in'));
        return;
      }

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
      if (user == null) {
        emit(EventRegistrationFailure(error: 'User not logged in'));
        return;
      }

      final registrations =
          await _firestore
              .collection('event_registrations')
              .where('userId', isEqualTo: user.uid)
              .orderBy('registeredAt', descending: true)
              .get();

      final List<Map<String, dynamic>> participatedEvents = [];

      for (var reg in registrations.docs) {
        final eventData = reg.data();
        final eventDoc =
            await _firestore
                .collection('events')
                .doc(eventData['eventId'])
                .get();

        if (eventDoc.exists) {
          participatedEvents.add({
            ...eventDoc.data()!,
            'id': eventDoc.id,
            'registeredAt': eventData['registeredAt'],
          });
        }
      }

      emit(ParticipatedEventsLoaded(participatedEvents));
    } catch (e) {
      emit(EventRegistrationFailure(error: e.toString()));
    }
  }

  Future<void> _createEventNotification(
    String eventId,
    String eventTitle,
    String eventImage,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // First check if notification already exists
      final existingNotifications =
          await _firestore
              .collection('notifications')
              .where('userId', isEqualTo: user.uid)
              .where('eventId', isEqualTo: eventId)
              .where('type', isEqualTo: 'event_registration')
              .get();

      if (existingNotifications.docs.isEmpty) {
        await _firestore.collection('notifications').add({
          'userId': user.uid,
          'eventId': eventId,
          'eventTitle': eventTitle,
          'eventImage': eventImage,
          'message': 'You have registered for $eventTitle',
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
          'type': 'event_registration',
        });
      }
    } catch (e) {
      debugPrint('Error creating notification: $e');
    }
  }
}
