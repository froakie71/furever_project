import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../views/screens/dashboard/dashboard.dart';
import '../views/screens/Events/eventlist.dart';
import '../views/screens/Dogs/dogslist.dart';
import '../views/screens/AdoptedDogs/adopted.dart';
import '../views/screens/Clients/clients.dart';
import '../views/screens/Donations/donations.dart';
import '../views/screens/DonationList/donationlist.dart';
import '../views/screens/Merch/merch_screen.dart';
import '../views/screens/ProcessAdoption/process_adoption_screen.dart';
import '../views/screens/authentication/bloc/auth_bloc.dart';
import '../views/screens/authentication/bloc/auth_event.dart';
import '../views/screens/authentication/login/admin_signin_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
              stream: FirebaseFirestore.instance
                  .collection('admins')
                  .doc(FirebaseAuth.instance.currentUser?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data?.exists == true) {
                  final adminData = snapshot.data?.data() as Map<String, dynamic>?;
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
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DashboardScreen()),
              );
            },
          ),
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
            leading: const Icon(Icons.pets_outlined),
            title: const Text('Process Adoptions'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProcessAdoptionScreen()),
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
                MaterialPageRoute(builder: (context) => const AdoptedDogsScreen()),
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
            leading: const Icon(Icons.monetization_on),
            title: const Text('Donations'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TopDonatorsScreen()),
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
                MaterialPageRoute(builder: (context) => const DonationListScreen()),
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