import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'schedule_checkup_event.dart';
import 'schedule_checkup_state.dart';

class ScheduleCheckupBloc
    extends Bloc<ScheduleCheckupEvent, ScheduleCheckupState> {
  final FirebaseFirestore firestore;

  ScheduleCheckupBloc({FirebaseFirestore? firestoreInstance})
    : firestore = firestoreInstance ?? FirebaseFirestore.instance,
      super(ScheduleCheckupInitial()) {
    on<LoadScheduleCheckup>(_onLoad);
    on<AddOrUpdateScheduleCheckup>(_onAddOrUpdate);
  }

  Future<void> _onLoad(LoadScheduleCheckup event, Emitter emit) async {
    emit(ScheduleCheckupLoading());
    try {
      final query =
          await firestore
              .collection('schedule_checkup')
              .where('dogId', isEqualTo: event.dogId)
              .where('userId', isEqualTo: event.userId)
              .limit(1)
              .get();
      if (query.docs.isNotEmpty) {
        emit(ScheduleCheckupLoaded(query.docs.first.data()));
      } else {
        emit(ScheduleCheckupLoaded(null));
      }
    } catch (e) {
      emit(ScheduleCheckupError(e.toString()));
    }
  }

  Future<void> _onAddOrUpdate(
    AddOrUpdateScheduleCheckup event,
    Emitter emit,
  ) async {
    emit(ScheduleCheckupLoading());
    try {
      final query =
          await firestore
              .collection('schedule_checkup')
              .where('dogId', isEqualTo: event.dogId)
              .where('userId', isEqualTo: event.userId)
              .limit(1)
              .get();
      if (query.docs.isNotEmpty) {
        // Update
        await firestore
            .collection('schedule_checkup')
            .doc(query.docs.first.id)
            .update({
              'date': Timestamp.fromDate(event.date),
              'description': event.description,
              'updatedAt': FieldValue.serverTimestamp(),
            });
        // Notification for update (user)
        await firestore.collection('notifications').add({
          'type': 'checkup_schedule',
          'action': 'updated',
          'userId': event.userId,
          'dogId': event.dogId,
          'date': Timestamp.fromDate(event.date),
          'description': event.description,
          'timestamp': FieldValue.serverTimestamp(),
        });
        // Notification for admin
        final dogDoc =
            await firestore.collection('dogs').doc(event.dogId).get();
        final dogName = dogDoc.data()?['name'] ?? 'their dog';
        final userDoc =
            await firestore.collection('users').doc(event.userId).get();
        final username = userDoc.data()?['username'] ?? 'A user';

        await firestore.collection('notifications').add({
          'type': 'checkup_schedule_request',
          'action': query.docs.isNotEmpty ? 'updated' : 'created',
          'userId': 'admin',
          'dogId': event.dogId,
          'date': Timestamp.fromDate(event.date),
          'description': event.description,
          'timestamp': FieldValue.serverTimestamp(),
          'message':
              '$username wants to schedule a checkup with their dog $dogName',
          'isRead': false,
        });
      } else {
        // Add
        await firestore.collection('schedule_checkup').add({
          'dogId': event.dogId,
          'userId': event.userId,
          'date': Timestamp.fromDate(event.date),
          'description': event.description,
          'createdAt': FieldValue.serverTimestamp(),
        });
        // Notification for creation (user)
        await firestore.collection('notifications').add({
          'type': 'checkup_schedule',
          'action': 'created',
          'userId': event.userId,
          'dogId': event.dogId,
          'date': Timestamp.fromDate(event.date),
          'description': event.description,
          'timestamp': FieldValue.serverTimestamp(),
        });
        // Notification for admin
        final dogDoc =
            await firestore.collection('dogs').doc(event.dogId).get();
        final dogName = dogDoc.data()?['name'] ?? 'their dog';
        final userDoc =
            await firestore.collection('users').doc(event.userId).get();
        final username = userDoc.data()?['username'] ?? 'A user';

        await firestore.collection('notifications').add({
          'type': 'checkup_schedule_request',
          'action': query.docs.isNotEmpty ? 'updated' : 'created',
          'userId': 'admin',
          'dogId': event.dogId,
          'date': Timestamp.fromDate(event.date),
          'description': event.description,
          'timestamp': FieldValue.serverTimestamp(),
          'message':
              '$username wants to schedule a checkup with their dog $dogName',
          'isRead': false,
        });
      }

      add(LoadScheduleCheckup(event.dogId, event.userId));
    } catch (e) {
      emit(ScheduleCheckupError(e.toString()));
    }
  }
}
