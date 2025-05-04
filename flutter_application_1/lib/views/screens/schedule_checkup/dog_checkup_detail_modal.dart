import 'package:flutter/material.dart';

class DogCheckupDetailModal extends StatelessWidget {
  final Map<String, dynamic> dogData;
  final Map<String, dynamic> checkupData;

  const DogCheckupDetailModal({
    super.key,
    required this.dogData,
    required this.checkupData,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(dogData['name'] ?? 'Dog Details'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dogData['imageUrl'] != null)
            Image.network(dogData['imageUrl'], height: 120),
          const SizedBox(height: 12),
          Text(dogData['description'] ?? 'No description.'),
          const SizedBox(height: 12),
          Text('Checkup Date: ${checkupData['date'] != null ? checkupData['date'].toDate().toString().split(' ')[0] : 'N/A'}'),
          Text('Notes: ${checkupData['description'] ?? ''}'),
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