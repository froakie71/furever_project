import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dog_event.dart';
import 'dog_state.dart';
import 'package:flutter/foundation.dart';

class DogBloc extends Bloc<DogEvent, DogState> {
  DogBloc() : super(DogInitial()) {
    on<AddDog>((event, emit) async {
      try {
        emit(DogLoading());

        String imageUrl = '';
        if (event.imageUrl.isNotEmpty) {
          final storageRef = FirebaseStorage.instance.ref();
          final imageRef = storageRef.child(
            'dogs/${DateTime.now().millisecondsSinceEpoch}.jpg',
          );

          if (kIsWeb) {
            // Handle web image upload
            // final bytes = Uint8List.fromList(event.imageUrl.codeUnits);
            final bytes = event.imageBytes;
            await imageRef.putData(
              bytes,
              SettableMetadata(contentType: 'image/jpeg'),
            );
          } else {
            // Handle mobile image upload
            final file = File(event.imageUrl);
            await imageRef.putFile(file);
          }

          imageUrl = await imageRef.getDownloadURL();
        }

        await FirebaseFirestore.instance.collection('dogs').add({
          'name': event.name,
          'breed': event.breed,
          'gender': event.gender,
          'size': event.size,
          'medicalRecords': event.medicalRecords,
          'imageUrl': imageUrl,
          'description': event.description,
          'status': 'available', // Add this field
          'createdAt': FieldValue.serverTimestamp(),
        });

        emit(DogSuccess());
      } catch (e) {
        emit(DogError(e.toString()));
      }
    });

    on<ProcessAdoption>(_onProcessAdoption);
  }

  Future<void> _handleAdoptionRequest(String dogId, String status) async {
    try {
      // Update dog status in dogs collection
      await FirebaseFirestore.instance
          .collection('dogs')
          .doc(dogId)
          .update({'status': status});

      // If declined, remove from adoptions collection
      if (status == 'declined') {
        final adoptionsQuery = await FirebaseFirestore.instance
            .collection('adoptions')
            .where('dogId', isEqualTo: dogId)
            .where('status', isEqualTo: 'pending')
            .get();

        for (var doc in adoptionsQuery.docs) {
          await doc.reference.delete();
        }
      }
    } catch (e) {
      print('Error updating adoption status: $e');
      throw Exception('Failed to update adoption status');
    }
  }

  Future<void> _onProcessAdoption(ProcessAdoption event, Emitter<DogState> emit) async {
    try {
      if (event.isApproved) {
        await _handleAdoptionRequest(event.dogId, 'adopted');
      } else {
        await _handleAdoptionRequest(event.dogId, 'available');
      }
      emit(AdoptionProcessed());
    } catch (e) {
      emit(DogError(e.toString()));
    }
  }
}
