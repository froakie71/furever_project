import 'package:cloud_firestore/cloud_firestore.dart';

class Dog {
  final String id;
  final String name;
  final String breed;
  final String gender;
  final String size;
  final String description;
  final String imageUrl;
  final String status;
  final Map<String, bool> medicalRecords; // Change this to Map<String, bool>
  final String? adoptedBy;

  Dog({
    required this.id,
    required this.name,
    required this.breed,
    required this.gender,
    required this.size,
    required this.description,
    required this.imageUrl,
    this.status = 'available',
    this.medicalRecords = const {}, // Default to empty map
    this.adoptedBy,
  });

  factory Dog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Dog(
      id: doc.id,
      name: data['name'] ?? '',
      breed: data['breed'] ?? '',
      gender: data['gender'] ?? '',
      size: data['size'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      status: data['status'] ?? 'available', // Default to available if missing
      medicalRecords: Map<String, bool>.from(data['medicalRecords'] ?? {}),
      adoptedBy: data['adoptedBy']?['userEmail'] as String?,
    );
  }
}
