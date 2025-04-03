import 'package:flutter/material.dart';

class EventParticipantsScreen extends StatelessWidget {
  final String eventId;
  final String eventTitle;

  const EventParticipantsScreen({
    super.key,
    required this.eventId,
    required this.eventTitle,
  });

  @override
  Widget build(BuildContext context) {
    // Dummy data for participants
    final List<Map<String, dynamic>> participants = [
      {
        'name': 'John Doe',
        'email': 'john.doe@example.com',
        'registeredDate': '2024-03-28',
        'status': 'Confirmed',
      },
      {
        'name': 'Jane Smith',
        'email': 'jane.smith@example.com',
        'registeredDate': '2024-03-27',
        'status': 'Pending',
      },
      {
        'name': 'Robert Johnson',
        'email': 'robert.j@example.com',
        'registeredDate': '2024-03-26',
        'status': 'Confirmed',
      },
    ];

    return Scaffold(
      appBar: AppBar(title: Text('Participants - $eventTitle')),
      body: ListView.builder(
        itemCount: participants.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final participant = participants[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.orange.shade100,
                child: Text(
                  participant['name'][0],
                  style: TextStyle(
                    color: Colors.orange.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                participant['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(participant['email']),
                  const SizedBox(height: 4),
                  Text(
                    'Registered: ${participant['registeredDate']}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      participant['status'] == 'Confirmed'
                          ? Colors.green.shade100
                          : Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  participant['status'],
                  style: TextStyle(
                    color:
                        participant['status'] == 'Confirmed'
                            ? Colors.green.shade800
                            : Colors.orange.shade800,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
