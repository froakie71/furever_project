import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ClientsView extends StatelessWidget {
  const ClientsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registered Users'),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data?.docs ?? [];

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userData = users[index].data() as Map<String, dynamic>;
              final createdAt = userData['createdAt'] as Timestamp?;
              final formattedDate =
                  createdAt != null
                      ? DateFormat('MMM d, yyyy').format(createdAt.toDate())
                      : 'N/A';

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage:
                        userData['profileImage'] != null &&
                                userData['profileImage'].toString().isNotEmpty
                            ? NetworkImage(userData['profileImage'])
                            : null,
                    child:
                        userData['profileImage'] == null ||
                                userData['profileImage'].toString().isEmpty
                            ? const Icon(Icons.person)
                            : null,
                  ),
                  title: Text(
                    userData['fullName'] ?? 'No Name',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Email: ${userData['email'] ?? 'N/A'}'),
                      Text('Joined: $formattedDate'),
                      Text(
                        'Sign-in Provider: ${userData['provider'] ?? 'email'}',
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  onTap: () {
                    _showUserDetails(context, userData);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showUserDetails(BuildContext context, Map<String, dynamic> userData) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('User Details'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (userData['profileImage'] != null &&
                      userData['profileImage'].toString().isNotEmpty)
                    Center(
                      child: Container(
                        width: 120,
                        height: 120,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(userData['profileImage']),
                          ),
                        ),
                      ),
                    ),
                  _buildDetailRow('Full Name', userData['fullName'] ?? 'N/A'),
                  _buildDetailRow('Email', userData['email'] ?? 'N/A'),
                  _buildDetailRow('Age', userData['age']?.toString() ?? 'N/A'),
                  _buildDetailRow(
                    'Phone',
                    userData['phone']?.toString() ?? 'N/A',
                  ),
                  _buildDetailRow('Gender', userData['gender'] ?? 'N/A'),
                  _buildDetailRow('Address', userData['address'] ?? 'N/A'),
                  if (userData['createdAt'] != null)
                    _buildDetailRow(
                      'Joined',
                      DateFormat(
                        'MMM d, yyyy HH:mm',
                      ).format(userData['createdAt'].toDate()),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 16)),
          const Divider(),
        ],
      ),
    );
  }
}
