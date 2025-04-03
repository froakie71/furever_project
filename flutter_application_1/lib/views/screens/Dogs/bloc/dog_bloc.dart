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
          final imageRef = storageRef
              .child('dogs/${DateTime.now().millisecondsSinceEpoch}.jpg');

          if (kIsWeb) {
            // Handle web image upload
            final bytes = Uint8List.fromList(event.imageUrl.codeUnits);
            await imageRef.putData(bytes);
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
          'createdAt': FieldValue.serverTimestamp(),
        });

        emit(DogSuccess());
      } catch (e) {
        emit(DogError(e.toString()));
      }
    });
  }
}
