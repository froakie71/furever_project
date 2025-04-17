import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Error loading notifications'),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final notifications =
                    (snapshot.data?.docs ?? []).where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      // Show admin-relevant notifications only
                      if (data['type'] == 'donation') {
                        return !(data['message']
                                ?.toString()
                                .toLowerCase()
                                .startsWith('you have donated') ??
                            false);
                      }
                      return data['type'] == 'event_join' ||
                          data['type'] == 'new_user' ||
                          data['type'] ==
                              'adoption_request'; // <-- Add this line
                    }).toList();
                if (notifications.isEmpty) {
                  return const Center(child: Text('No notifications'));
                }
                return ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification =
                        notifications[index].data() as Map<String, dynamic>;
                    return ListTile(
                      leading: Icon(
                        notification['type'] == 'new_user'
                            ? Icons.person_add
                            : notification['type'] == 'event_join'
                            ? Icons.event_available
                            : notification['type'] == 'donation'
                            ? Icons.monetization_on
                            : Icons.notifications,
                        color:
                            notification['type'] == 'new_user'
                                ? Colors.green
                                : notification['type'] == 'event_join'
                                ? Colors.orange
                                : notification['type'] == 'donation'
                                ? Colors.blue
                                : null,
                      ),
                      title: Text(notification['message'] ?? 'No message'),
                      subtitle:
                          notification['type'] == 'donation'
                              ? Text(
                                'Donor: '
                                '${(notification['username'] != null && notification['username'].toString().trim().isNotEmpty) ? notification['username'] : (notification['email'] != null && notification['email'].toString().contains('@') ? notification['email'].toString().split('@')[0] + '@' : "Unknown")}\n'
                                'Time: ${notification['timestamp'] != null ? (notification['timestamp'] as Timestamp).toDate().toString() : ""}',
                                style: const TextStyle(fontSize: 12),
                              )
                              : Text(
                                notification['timestamp'] != null
                                    ? (notification['timestamp'] as Timestamp)
                                        .toDate()
                                        .toString()
                                    : '',
                                style: const TextStyle(fontSize: 12),
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
