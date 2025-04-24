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
        // Notification for update
        await firestore.collection('notifications').add({
          'type': 'checkup_schedule',
          'action': 'updated',
          'userId': event.userId,
          'dogId': event.dogId,
          'date': Timestamp.fromDate(event.date),
          'description': event.description,
          'timestamp': FieldValue.serverTimestamp(),
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
        // Notification for creation
        await firestore.collection('notifications').add({
          'type': 'checkup_schedule',
          'action': 'created',
          'userId': event.userId,
          'dogId': event.dogId,
          'date': Timestamp.fromDate(event.date),
          'description': event.description,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      add(LoadScheduleCheckup(event.dogId, event.userId));
    } catch (e) {
      emit(ScheduleCheckupError(e.toString()));
    }
  }
}
