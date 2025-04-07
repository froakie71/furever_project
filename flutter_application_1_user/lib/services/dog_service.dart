import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1_user/models/dog_model.dart';

Future<void> createDog(Dog dog) async {
  await FirebaseFirestore.instance.collection('dogs').add({
    'name': dog.name,
    'breed': dog.breed,
    'gender': dog.gender,
    'size': dog.size,
    'description': dog.description,
    'imageUrl': dog.imageUrl,
    'medicalRecords': dog.medicalRecords,
    'status': 'available', // Make sure this is set
    'createdAt': FieldValue.serverTimestamp(),
  });
}
