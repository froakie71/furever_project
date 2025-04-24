import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'schedule_checkup_event.dart';
import 'schedule_checkup_state.dart';

class ScheduleCheckupBloc
    extends Bloc<ScheduleCheckupEvent, ScheduleCheckupState> {
  ScheduleCheckupBloc() : super(ScheduleCheckupInitial()) {
    on<ApproveCheckup>((event, emit) async {
      final doc =
          await FirebaseFirestore.instance
              .collection('schedule_checkup')
              .doc(event.checkupId)
              .get();
      final data = doc.data();
      if (data != null) {
        await FirebaseFirestore.instance.collection('notifications').add({
          'userId': data['userId'],
          'dogId': data['dogId'],
          'type': 'checkup_approved',
          'message': 'Your checkup for your dog has been approved!',
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
        });
        await FirebaseFirestore.instance
            .collection('schedule_checkup')
            .doc(event.checkupId)
            .update({'status': 'approved'});
      }
    });

    on<DisapproveCheckup>((event, emit) async {
      final doc =
          await FirebaseFirestore.instance
              .collection('schedule_checkup')
              .doc(event.checkupId)
              .get();
      final data = doc.data();
      if (data != null) {
        await FirebaseFirestore.instance.collection('notifications').add({
          'userId': data['userId'],
          'dogId': data['dogId'],
          'type': 'checkup_disapproved',
          'message': 'Admin declined your schedule checkup for ${data['dogName'] ?? 'your dog'}.',
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
        });
        await FirebaseFirestore.instance
            .collection('schedule_checkup')
            .doc(event.checkupId)
            .delete();
      }
    });
  }
}
