import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/merch_model.dart';
import 'package:flutter_application_1/views/screens/Merch/bloc/merch_event.dart';
import 'package:flutter_application_1/views/screens/Merch/bloc/merch_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MerchBloc extends Bloc<MerchEvent, MerchState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  MerchBloc() : super(MerchInitial()) {
    on<LoadMerch>((event, emit) async {
      emit(MerchLoading());
      try {
        final merchCollection = await _firestore.collection('merch').get();
        final merchList = merchCollection.docs
            .map((doc) => MerchModel.fromMap(doc.id, doc.data()))
            .toList();
        emit(MerchLoaded(merchList));
      } catch (e) {
        emit(MerchError(e.toString()));
      }
    });

    on<AddMerch>((event, emit) async {
      try {
        await _firestore.collection('merch').add(event.merch.toMap());
        add(LoadMerch());
      } catch (e) {
        emit(MerchError(e.toString()));
      }
    });
  }
}