import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1_user/bloc/auth/auth_bloc.dart';
import 'package:flutter_application_1_user/bloc/auth/auth_event.dart';
import 'package:flutter_application_1_user/views/screens/authentication/sign_in_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../views/screens/home_screen.dart';
import '../views/screens/event_screen.dart';
import '../views/screens/dog_screen.dart';
import '../views/screens/donation_screen.dart';
import '../views/screens/adopted_dogs_screen.dart';
import '../views/screens/medical_services_screen.dart';
import '../views/screens/merch_screen.dart';

class SharedDrawer extends StatefulWidget {
  SharedDrawer({super.key});

  @override
  State<SharedDrawer> createState() => _SharedDrawerState();
}

class _SharedDrawerState extends State<SharedDrawer> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String userName = '';

  String userEmail = '';

  String? userPhotoUrl;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userData = await _firestore.collection('users').doc(user.uid).get();
      if (userData.exists && mounted) {
        // Use built-in mounted property
        setState(() {
          userName = userData.data()?['fullName'] ?? 'User';
          userEmail = userData.data()?['email'] ?? user.email ?? '';
          userPhotoUrl = userData.data()?['profileImage'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage:
                  userPhotoUrl != null ? NetworkImage(userPhotoUrl!) : null,
              child:
                  userPhotoUrl == null
                      ? const Icon(Icons.person, size: 50, color: Colors.grey)
                      : null,
            ),
            accountName: Text(userName),
            accountEmail: Text(userEmail),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
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
                MaterialPageRoute(builder: (context) => EventScreen()),
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
                MaterialPageRoute(builder: (context) => DogScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.volunteer_activism),
            title: const Text('Donate'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DonationScreen()),
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
            leading: const Icon(Icons.medical_services),
            title: const Text('Medical Services'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MedicalServicesScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: const Text('Merch'),
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
            onTap: () {
              context.read<AuthBloc>().add(SignOutRequested());
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const SignInScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
