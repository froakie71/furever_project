import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/views/screens/schedule_checkup/admin_schedule_checkup_screen.dart';
import 'package:intl/intl.dart';
import '../screens/AdoptedDogs/adopted.dart';
import '../screens/Clients/clients.dart';
import '../screens/Dogs/dogslist.dart';
import '../screens/DonationList/donationlist.dart';
import '../screens/Donations/donations.dart';
import '../screens/Events/eventlist.dart';
import '../screens/Merch/merch_screen.dart';
import '../screens/authentication/bloc/auth_bloc.dart';
import '../screens/authentication/bloc/auth_event.dart';
import '../screens/authentication/login/admin_signin_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../screens/ProcessAdoption/process_adoption_screen.dart';

class SharedDrawer extends StatelessWidget {
  const SharedDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: StreamBuilder<DocumentSnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('admins')
                      .doc(FirebaseAuth.instance.currentUser?.uid)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data?.exists == true) {
                  final adminData =
                      snapshot.data?.data() as Map<String, dynamic>?;
                  final adminName = adminData?['name'] ?? 'Admin User';
                  return Text(
                    adminName,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  );
                }
                return const Text(
                  'Admin User',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                );
              },
            ),
            accountEmail: Text(
              FirebaseAuth.instance.currentUser?.email ?? '',
              style: const TextStyle(color: Colors.white),
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Colors.blue),
            ),
            decoration: const BoxDecoration(color: Colors.blue),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          // ListTile(
          //   leading: const Icon(Icons.dashboard),
          //   title: const Text('Dashboard'),
          //   onTap: () {
          //     Navigator.pop(context);
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => const DashboardScreen(),
          //       ),
          //     );
          //   },
          // ),
          ListTile(
            leading: const Icon(Icons.event),
            title: const Text('Events'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EventScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.pets),
            title: const Text('Dogs'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DogsListScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Adopted'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdoptedDogsScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Clients'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ClientsView()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.pets_outlined),
            title: const Text('Process Adoptions'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProcessAdoptionScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.monetization_on),
            title: const Text('Donations'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TopDonatorsScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('Donation List'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DonationListScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: const Text('Merchandise'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MerchScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => const _AdminNotificationsBottomSheet(),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.schedule), // Schedule/check icon
            title: const Text('Schedule Checkups'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminScheduleCheckupScreen(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () => _handleLogout(context),
          ),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    context.read<AuthBloc>().add(SignOutRequested());
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => AdminSignInView()),
      (route) => false,
    );
  }
}

class _AdminNotificationsBottomSheet extends StatelessWidget {
  const _AdminNotificationsBottomSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notifications',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('notifications')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final notifications =
                    (snapshot.data?.docs ?? []).where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      // Only show admin notifications, including checkup requests
                      return data['type'] == 'adoption_admin' ||
                          data['type'] == 'donation_admin' ||
                          data['type'] == 'event_join' ||
                          data['type'] == 'checkup_schedule_request';
                    }).toList();

                if (notifications.isEmpty) {
                  return const Center(child: Text('No notifications'));
                }

                return ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notif =
                        notifications[index].data() as Map<String, dynamic>;
                    final type = notif['type'];
                    IconData icon;
                    Color iconColor;

                    if (type == 'event_join') {
                      icon = Icons.event_available;
                      iconColor = Colors.blue;
                    } else if (type == 'adoption_admin') {
                      icon = Icons.pets;
                      iconColor = Colors.orange;
                    } else if (type == 'donation_admin') {
                      icon = Icons.volunteer_activism;
                      iconColor = Colors.purple;
                    } else {
                      icon = Icons.notifications;
                      iconColor = Colors.grey;
                    }

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: iconColor.withOpacity(0.15),
                          child: Icon(icon, color: iconColor),
                        ),
                        title: Text(
                          notif['message'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          notif['timestamp'] != null
                              ? DateFormat('yyyy-MM-dd – kk:mm').format(
                                (notif['timestamp'] as Timestamp).toDate(),
                              )
                              : '',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
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

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('notifications')
                .orderBy('timestamp', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final notifications = snapshot.data!.docs;
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index].data() as Map<String, dynamic>;
              if (notif['type'] == 'checkup_schedule') {
                return FutureBuilder<DocumentSnapshot>(
                  future:
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(notif['userId'])
                          .get(),
                  builder: (context, userSnap) {
                    final user =
                        userSnap.data?.data() as Map<String, dynamic>? ?? {};
                    return FutureBuilder<DocumentSnapshot>(
                      future:
                          FirebaseFirestore.instance
                              .collection('dogs')
                              .doc(notif['dogId'])
                              .get(),
                      builder: (context, dogSnap) {
                        final dog =
                            dogSnap.data?.data() as Map<String, dynamic>? ?? {};
                        return ListTile(
                          leading: const Icon(
                            Icons.calendar_today,
                            color: Colors.blue,
                          ),
                          title: Text(
                            '${user['fullName'] ?? 'A user'} scheduled a checkup',
                          ),
                          subtitle: Text(
                            'Dog: ${dog['name'] ?? 'Unknown'}\n'
                            'Date: ${notif['date'] != null ? DateFormat('yyyy-MM-dd').format((notif['date'] as Timestamp).toDate()) : 'N/A'}\n'
                            'Notes: ${notif['description'] ?? ''}',
                          ),
                        );
                      },
                    );
                  },
                );
              }
              // ...handle other notification types if needed
              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }
}

Future<void> addAdoptionAdminNotification(
  String? username,
  String userEmail,
  String dogName,
) async {
  await FirebaseFirestore.instance.collection('notifications').add({
    'type': 'adoption_admin',
    'message': '${username ?? userEmail} wants to adopt the dog: $dogName',
    'timestamp': FieldValue.serverTimestamp(),
    'isRead': false,
    // Optionally include userId, dogId, etc. for admin reference
  });
}
