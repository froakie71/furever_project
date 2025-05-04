import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'event_event.dart';
import 'event_state.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  EventBloc() : super(EventInitial()) {
    on<CreateEvent>(_onCreateEvent);
  }

  Future<void> _onCreateEvent(
    CreateEvent event,
    Emitter<EventState> emit,
  ) async {
    emit(EventLoading());
    try {
      await _firestore.collection('events').add({
        'title': event.title,
        'location': event.location,
        'description': event.description,
        'date': event.date,
        'time': event.time,
        'imageUrl': event.imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });
      emit(EventSuccess());
    } catch (e) {
      emit(EventFailure(e.toString()));
    }
  }
}