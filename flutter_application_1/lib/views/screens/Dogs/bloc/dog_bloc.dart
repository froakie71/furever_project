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
          final ref = FirebaseStorage.instance.ref().child(
            'dogs/${DateTime.now().toString()}',
          );

          if (kIsWeb) {
            await ref.putData(event.imageBytes);
          } else {
            await ref.putFile(File(event.imageUrl));
          }

          imageUrl = await ref.getDownloadURL();
        }

        await FirebaseFirestore.instance.collection('dogs').add({
          'name': event.name,
          'breed': event.breed,
          'gender': event.gender,
          'size': event.size,
          'medicalRecords':
              event.medicalRecords, // This will now be text instead of a Map
          'imageUrl': imageUrl,
          'description': event.description,
          'status': 'available',
          'createdAt': FieldValue.serverTimestamp(),
        });

        emit(DogSuccess());
      } catch (e) {
        emit(DogError(e.toString()));
      }
    });

    on<ProcessAdoption>(_onProcessAdoption);
    on<DeleteDog>(_onDeleteDog);
  }

  Future<void> _handleAdoptionRequest(String dogId, String status) async {
    try {
      await FirebaseFirestore.instance.collection('dogs').doc(dogId).update({
        'status': status,
      });

      if (status == 'declined') {
        final adoptionsQuery =
            await FirebaseFirestore.instance
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

  Future<void> _onProcessAdoption(
    ProcessAdoption event,
    Emitter<DogState> emit,
  ) async {
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

  Future<void> _onDeleteDog(
    DeleteDog event,
    Emitter<DogState> emit,
  ) async {
    try {
      emit(DogLoading());
      
      // Get the dog document
      final dogDoc = await FirebaseFirestore.instance
          .collection('dogs')
          .doc(event.dogId)
          .get();

      if (dogDoc.exists) {
        final dogData = dogDoc.data();
        // Delete the image from storage if it exists
        if (dogData != null && dogData['imageUrl'] != null && dogData['imageUrl'].isNotEmpty) {
          try {
            final ref = FirebaseStorage.instance
                .refFromURL(dogData['imageUrl']);
            await ref.delete();
          } catch (e) {
            print('Error deleting image: $e');
            // Continue with dog deletion even if image deletion fails
          }
        }

        // Delete the dog document
        await FirebaseFirestore.instance
            .collection('dogs')
            .doc(event.dogId)
            .delete();

        emit(DogDeleted());
      } else {
        emit(DogError('Dog not found'));
      }
    } catch (e) {
      emit(DogError(e.toString()));
    }
  }
}
