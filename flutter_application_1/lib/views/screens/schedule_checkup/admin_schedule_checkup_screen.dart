import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/views/screens/schedule_checkup/ScheduleCheckupBloc/schedule_checkup_bloc.dart';
import 'package:flutter_application_1/views/screens/schedule_checkup/ScheduleCheckupBloc/schedule_checkup_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'dog_checkup_detail_modal.dart';

class AdminScheduleCheckupScreen extends StatefulWidget {
  const AdminScheduleCheckupScreen({super.key});

  @override
  State<AdminScheduleCheckupScreen> createState() =>
      _AdminScheduleCheckupScreenState();
}

class _AdminScheduleCheckupScreenState
    extends State<AdminScheduleCheckupScreen> {
  final Set<String> _recentlyDisapproved = {};

  Future<void> _createNotification({
    required String userId,
    required String dogName,
    required String status,
    required DateTime checkupDate,
  }) async {
    String message;
    String type = 'checkup';
    
    // Format the date and time in a user-friendly way
    final dateFormatter = DateFormat('EEEE, MMMM d, y');
    final timeFormatter = DateFormat('h:mm a');
    final formattedDate = dateFormatter.format(checkupDate);
    final formattedTime = timeFormatter.format(checkupDate);
    
    if (status == 'approved') {
      message = 'Your checkup request for $dogName has been approved.\nScheduled for: $formattedDate at $formattedTime';
    } else {
      message = 'Your checkup request for $dogName has been disapproved';
    }

    await FirebaseFirestore.instance.collection('notifications').add({
      'userId': userId,
      'type': type,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
      'for': 'user',
      'checkupDate': checkupDate, // Store the actual date for future reference
    });
  }

  String _formatDateTime(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    final date = timestamp.toDate();
    final dateFormatter = DateFormat('yyyy-MM-dd');
    final timeFormatter = DateFormat('h:mm a');
    return '${dateFormatter.format(date)} at ${timeFormatter.format(date)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Image.network(
                  'https://cdn-icons-png.flaticon.com/512/2921/2921222.png',
                  fit: BoxFit.contain,
                  width: 36,
                  height: 36,
                ),
              ),
            ),
            const Text(
              'Schedule Checkups',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        // No leading widget
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('schedule_checkup')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final checkups = snapshot.data!.docs;
          // Group by userId
          final Map<String, List<DocumentSnapshot>> userMap = {};
          for (var doc in checkups) {
            final userId = doc['userId'];
            userMap.putIfAbsent(userId, () => []).add(doc);
          }
          if (userMap.isEmpty) {
            return const Center(child: Text('No scheduled checkups.'));
          }
          return ListView(
            children: userMap.entries.map((entry) {
              final userId = entry.key;
              final userCheckups = entry.value;
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .get(),
                builder: (context, userSnap) {
                  final userData =
                      userSnap.data?.data() as Map<String, dynamic>? ?? {};
                  final userName = userData['name'] ?? 'User';
                  final userEmail = userData['email'] ?? '';
                  return ExpansionTile(
                    leading: FutureBuilder<String>(
                      future: _getUserProfileImage(userData),
                      builder: (context, imageSnapshot) {
                        if (imageSnapshot.hasData &&
                            imageSnapshot.data!.isNotEmpty) {
                          return CircleAvatar(
                            backgroundColor: Colors.grey[200],
                            child: ClipOval(
                              child: Image.network(
                                imageSnapshot.data!,
                                fit: BoxFit.cover,
                                width: 40,
                                height: 40,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildFallbackAvatar(userData);
                                },
                              ),
                            ),
                          );
                        }
                        return _buildFallbackAvatar(userData);
                      },
                    ),
                    title: Text('$userName (${userCheckups.length} dogs)'),
                    subtitle: Text(userEmail),
                    children: userCheckups.map((dogDoc) {
                      final dogId = dogDoc['dogId'];
                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('dogs')
                            .doc(dogId)
                            .get(),
                        builder: (context, dogSnap) {
                          if (!dogSnap.hasData) {
                            return const ListTile(
                              title: Text('Loading...'),
                            );
                          }
                          final dogData =
                              dogSnap.data!.data() as Map<String, dynamic>? ?? {};
                          final docData =
                              dogDoc.data() as Map<String, dynamic>? ?? {};
                          final status = docData['status'] ?? 'pending';

                          // Check if this checkup was just disapproved
                          if (_recentlyDisapproved.contains(
                            dogDoc.id,
                          )) {
                            return ListTile(
                              leading: const Icon(
                                Icons.info,
                                color: Colors.red,
                              ),
                              title: Text(dogData['name'] ?? 'Dog'),
                              subtitle: const Text(
                                'Disapproved (will disappear soon)',
                              ),
                            );
                          }

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: dogData['imageUrl'] != null
                                  ? NetworkImage(
                                      dogData['imageUrl'],
                                    )
                                  : null,
                              child: dogData['imageUrl'] == null
                                  ? const Icon(Icons.pets)
                                  : null,
                            ),
                            title: Text(dogData['name'] ?? 'Dog'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Scheduled for: ${_formatDateTime(docData['date'])}'),
                                const SizedBox(height: 4),
                                Text('Notes: ${docData['description'] ?? 'No notes'}'),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    if (status == 'pending') ...[
                                      ElevatedButton.icon(
                                        icon: const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                        ),
                                        label: const Text('Approve'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                        ),
                                        onPressed: () async {
                                          // Get the user and dog information before updating status
                                          final checkupData = dogDoc.data() as Map<String, dynamic>;
                                          final userId = checkupData['userId'];
                                          final checkupDate = (checkupData['date'] as Timestamp).toDate();

                                          context
                                              .read<ScheduleCheckupBloc>()
                                              .add(
                                                ApproveCheckup(
                                                  dogDoc.id,
                                                ),
                                              );
                                          
                                          // Create notification after approval
                                          await _createNotification(
                                            userId: userId,
                                            dogName: dogData['name'] ?? 'your dog',
                                            status: 'approved',
                                            checkupDate: checkupDate,
                                          );
                                        },
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton.icon(
                                        icon: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                        ),
                                        label: const Text('Disapprove'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                        onPressed: () async {
                                          // Get the user and dog information before updating status
                                          final checkupData = dogDoc.data() as Map<String, dynamic>;
                                          final userId = checkupData['userId'];
                                          final checkupDate = (checkupData['date'] as Timestamp).toDate();

                                          context
                                              .read<ScheduleCheckupBloc>()
                                              .add(
                                                DisapproveCheckup(
                                                  dogDoc.id,
                                                ),
                                              );

                                          // Create notification after disapproval
                                          await _createNotification(
                                            userId: userId,
                                            dogName: dogData['name'] ?? 'your dog',
                                            status: 'disapproved',
                                            checkupDate: checkupDate,
                                          );

                                          setState(() {
                                            _recentlyDisapproved.add(
                                              dogDoc.id,
                                            );
                                          });
                                          Future.delayed(
                                            const Duration(seconds: 2),
                                            () {
                                              setState(() {
                                                _recentlyDisapproved
                                                    .remove(dogDoc.id);
                                              });
                                            },
                                          );
                                        },
                                      ),
                                    ] else if (status == 'approved') ...[
                                      const Icon(
                                        Icons.verified,
                                        color: Colors.green,
                                      ),
                                      const Text(
                                        'Approved',
                                        style: TextStyle(
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => DogCheckupDetailModal(
                                  dogData: dogData,
                                  checkupData:
                                      dogDoc.data() as Map<String, dynamic>,
                                ),
                              );
                            },
                          );
                        },
                      );
                    }).toList(),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Future<String> _getUserProfileImage(Map<String, dynamic> userData) async {
    final profileUrl = userData['user_profiles'] ??
        userData['profileImage'] ??
        userData['profileImages'];

    if (profileUrl != null && profileUrl.toString().isNotEmpty) {
      return profileUrl.toString();
    }
    return '';
  }

  Widget _buildFallbackAvatar(Map<String, dynamic> userData) {
    return CircleAvatar(
      backgroundColor: Colors.grey[200],
      child: Text(
        (userData['fullName'] != null &&
                    userData['fullName'].toString().isNotEmpty
                ? userData['fullName'][0]
                : userData['email'] != null &&
                        userData['email'].toString().isNotEmpty
                    ? userData['email'][0]
                    : '?')
            .toUpperCase(),
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
    );
  }
}
