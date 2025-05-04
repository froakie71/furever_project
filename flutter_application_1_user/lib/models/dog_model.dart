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
  final String medicalRecords; // Changed to String type
  final String? adoptedBy;

  Dog({
    required this.id,
    required this.name,
    required this.breed,
    required this.gender,
    required this.size,
    required this.description,
    required this.imageUrl,
    required this.status,
    required this.medicalRecords, // Now expects String
    this.adoptedBy,
  });

  factory Dog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Handle medical records that could be either Map or String
    String medicalRecordsStr = '';
    final medicalRecords = data['medicalRecords'];
    if (medicalRecords is Map) {
      // Convert map to string representation if needed
      medicalRecordsStr = medicalRecords.entries
          .map((e) => '${e.key}: ${e.value}')
          .join('\n');
    } else if (medicalRecords is String) {
      medicalRecordsStr = medicalRecords;
    }

    return Dog(
      id: doc.id,
      name: data['name'] ?? '',
      breed: data['breed'] ?? '',
      gender: data['gender'] ?? '',
      size: data['size'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      status: data['status'] ?? 'available',
      medicalRecords: medicalRecordsStr,
      adoptedBy: data['adoptedBy']?['userEmail'] as String?,
    );
  }

  factory Dog.fromMap(Map<String, dynamic> map, String id) {
    // Similar handling for fromMap
    String medicalRecordsStr = '';
    final medicalRecords = map['medicalRecords'];
    if (medicalRecords is Map) {
      medicalRecordsStr = medicalRecords.entries
          .map((e) => '${e.key}: ${e.value}')
          .join('\n');
    } else if (medicalRecords is String) {
      medicalRecordsStr = medicalRecords;
    }

    return Dog(
      id: id,
      name: map['name'] as String,
      breed: map['breed'] as String,
      gender: map['gender'] as String,
      size: map['size'] as String,
      description: map['description'] as String,
      imageUrl: map['imageUrl'] as String,
      status: map['status'] as String,
      medicalRecords: medicalRecordsStr,
    );
  }
}
