import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyRescueReportsScreen extends StatelessWidget {
  const MyRescueReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get current user
    final currentUser = FirebaseAuth.instance.currentUser;

    // If no user is logged in, show appropriate message
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view your reports')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Rescue Reports')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('rescue_reports')
                .where(
                  'userId',
                  isEqualTo: currentUser.uid,
                ) // Use current user's ID
                .orderBy('createdAt', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No rescue reports yet'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final report = snapshot.data!.docs[index];
              final data = report.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      data['imageUrl'],
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.error);
                      },
                    ),
                  ),
                  title: Text('Location: ${data['address']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Landmark: ${data['landmark']}'),
                      Text('Reported On: ${_formatDate(data['createdAt'])}'),
                      Text('Phone Number: ${data['phoneNumber'] ?? 'N/A'}'),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date is String) {
      return DateTime.parse(date).toString().split('.')[0];
    } else if (date is Timestamp) {
      return date.toDate().toString().split('.')[0];
    }
    return 'Date not available';
  }
}
