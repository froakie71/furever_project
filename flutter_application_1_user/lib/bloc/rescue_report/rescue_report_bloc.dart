import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_application_1_user/bloc/rescue_report/rescue_report_event.dart';
import 'package:flutter_application_1_user/bloc/rescue_report/rescue_report_state.dart';
import 'package:flutter_application_1_user/models/rescue_report.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

class RescueReportBloc extends Bloc<RescueReportEvent, RescueReportState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  RescueReportBloc() : super(RescueReportInitial()) {
    on<SubmitRescueReport>(_onSubmitRescueReport);
    on<LoadRescueReports>(_onLoadRescueReports);
  }

  Future<void> _onSubmitRescueReport(
    SubmitRescueReport event,
    Emitter<RescueReportState> emit,
  ) async {
    try {
      emit(RescueReportLoading());

      // Upload image
      final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final Reference ref = _storage.ref().child(
        'rescue_reports/$fileName.jpg',
      );
      await ref.putFile(File(event.imagePath));
      final String imageUrl = await ref.getDownloadURL();

      // Save to Firestore
      final currentUser = FirebaseAuth.instance.currentUser!;
      await FirebaseFirestore.instance.collection('rescue_reports').add({
        'address': event.address,
        'landmark': event.landmark,
        'imageUrl': imageUrl,
        'userId': currentUser.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'phoneNumber': event.phoneNumber, // Add this field
        'status': 'pending',
      });

      emit(RescueReportSuccess([]));
    } catch (e) {
      emit(RescueReportError(e.toString()));
    }
  }

  Future<void> _onLoadRescueReports(
    LoadRescueReports event,
    Emitter<RescueReportState> emit,
  ) async {
    try {
      emit(RescueReportLoading());
      final snapshot = await _firestore.collection('rescue_reports').get();
      final reports =
          snapshot.docs.map((doc) => RescueReport.fromMap(doc.data())).toList();
      emit(RescueReportSuccess(reports));
    } catch (e) {
      emit(RescueReportError(e.toString()));
    }
  }
}
