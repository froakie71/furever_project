class RescueReport {
  final String id;
  final String imageUrl;
  final String address;
  final String landmark;
  final String status;
  final DateTime createdAt;
  final String userId;

  RescueReport({
    required this.id,
    required this.imageUrl,
    required this.address,
    required this.landmark,
    this.status = 'pending',
    required this.createdAt,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'address': address,
      'landmark': landmark,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'userId': userId,
    };
  }

  factory RescueReport.fromMap(Map<String, dynamic> map) {
    return RescueReport(
      id: map['id'],
      imageUrl: map['imageUrl'],
      address: map['address'],
      landmark: map['landmark'],
      status: map['status'],
      createdAt: DateTime.parse(map['createdAt']),
      userId: map['userId'],
    );
  }
}
