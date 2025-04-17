import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationsBottomSheet extends StatelessWidget {
  final VoidCallback? onOpened;
  const NotificationsBottomSheet({Key? key, this.onOpened}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Call the callback as soon as the sheet is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (onOpened != null) onOpened!();
    });

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF32649B),
                ),
              ),
              TextButton(
                onPressed: () async {
                  final batch = FirebaseFirestore.instance.batch();
                  final notifications =
                      await FirebaseFirestore.instance
                          .collection('notifications')
                          .where(
                            'userId',
                            isEqualTo: FirebaseAuth.instance.currentUser?.uid,
                          )
                          .where('isRead', isEqualTo: false)
                          .get();

                  for (var doc in notifications.docs) {
                    batch.update(doc.reference, {'isRead': true});
                  }
                  await batch.commit();
                  Navigator.of(
                    context,
                  ).pop(); // This will close the sheet and update the badge
                },
                child: const Text('Mark all as read'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('notifications')
                      .where(
                        'userId',
                        isEqualTo: FirebaseAuth.instance.currentUser?.uid,
                      )
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Error loading notifications',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final notifications =
                    (snapshot.data?.docs ?? []).where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      // Only show notifications meant for the user
                      // Exclude admin notifications (event_join, new_user, etc.)
                      return data['type'] != 'event_join' &&
                          data['type'] != 'new_user';
                    }).toList();
                if (notifications.isEmpty) {
                  return const Center(child: Text('No notifications'));
                }

                return ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification =
                        notifications[index].data() as Map<String, dynamic>;
                    final isAdoption = notification['type'] == 'adoption';
                    final imageUrl =
                        isAdoption
                            ? notification['dogImage']
                            : notification['eventImage'];

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading:
                            imageUrl != null && imageUrl != ''
                                ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    imageUrl,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.pets, size: 40);
                                    },
                                  ),
                                )
                                : Icon(
                                  isAdoption ? Icons.pets : Icons.event,
                                  size: 40,
                                ),
                        title: Text(
                          isAdoption
                              ? 'Adoption Update'
                              : (notification['eventTitle'] ?? 'Event'),
                        ),
                        subtitle: Text(notification['message'] ?? ''),
                        onTap: () async {
                          await notifications[index].reference.update({
                            'isRead': true,
                          });
                          // Optionally close the bottom sheet:
                          // Navigator.of(context).pop();
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final date = timestamp.toDate();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
