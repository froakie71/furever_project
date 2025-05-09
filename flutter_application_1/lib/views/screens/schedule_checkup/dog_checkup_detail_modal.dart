import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DogCheckupDetailModal extends StatelessWidget {
  final Map<String, dynamic> dogData;
  final Map<String, dynamic> checkupData;

  const DogCheckupDetailModal({
    super.key,
    required this.dogData,
    required this.checkupData,
  });

  String _formatDateTime(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    final date = timestamp.toDate();
    final dateFormatter = DateFormat('yyyy-MM-dd');
    final timeFormatter = DateFormat('h:mm a');
    return '${dateFormatter.format(date)} at ${timeFormatter.format(date)}';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(dogData['name'] ?? 'Dog Details'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dogData['imageUrl'] != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                dogData['imageUrl'],
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 12),
          Text(
            'Happy dog',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Checkup Date: ${_formatDateTime(checkupData['date'])}',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'Notes: ${checkupData['description'] ?? ''}',
            style: TextStyle(color: Colors.grey[700]),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}