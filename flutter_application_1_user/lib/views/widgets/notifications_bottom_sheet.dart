import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
                  if (context.mounted) {
                    Navigator.of(context).pop(); // Only close if still mounted
                  }
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

                print(
                  'Current user UID: ${FirebaseAuth.instance.currentUser?.uid}',
                );

                final notifications =
                    (snapshot.data?.docs ?? []).where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      // Only show notifications for the current user and user types
                      return data['userId'] ==
                              FirebaseAuth.instance.currentUser?.uid &&
                          (data['type'] == 'adoption_update' ||
                              data['type'] == 'donation_user' ||
                              data['type'] == 'checkup_approved' ||
                              data['type'] == 'checkup_disapproved' ||
                              data['type'] == 'event_registration' ||
                              data['type'] ==
                                  'adoption'); // add other user types as needed
                    }).toList();
                if (notifications.isEmpty) {
                  return const Center(child: Text('No notifications'));
                }

                return ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification =
                        notifications[index].data() as Map<String, dynamic>;
                    final type = notification['type'];
                    String title = '';
                    String message = notification['message'] ?? '';

                    if (type == 'checkup_approved') {
                      title = 'Checkup Approved';
                    } else if (type == 'checkup_disapproved') {
                      title = 'Checkup Disapproved';
                    } else if (type == 'adoption') {
                      title = 'Adoption Update';
                    } else {
                      title = notification['eventTitle'] ?? 'Event';
                    }

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: Icon(
                          type == 'checkup_approved'
                              ? Icons.verified
                              : type == 'checkup_disapproved'
                              ? Icons.cancel
                              : Icons.notifications,
                          color:
                              type == 'checkup_approved'
                                  ? Colors.green
                                  : type == 'checkup_disapproved'
                                  ? Colors.red
                                  : null,
                          size: 40,
                        ),
                        title: Text(title),
                        subtitle: Text(message),
                        onTap: () async {
                          await notifications[index].reference.update({
                            'isRead': true,
                          });
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
}
