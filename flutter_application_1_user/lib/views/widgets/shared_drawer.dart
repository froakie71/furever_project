import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1_user/bloc/auth/auth_bloc.dart';
import 'package:flutter_application_1_user/bloc/auth/auth_event.dart';
import 'package:flutter_application_1_user/views/screens/adopted_dogs_screen.dart';
import 'package:flutter_application_1_user/views/screens/sign_in_screen.dart';
import 'package:flutter_application_1_user/views/screens/dog_screen.dart';
import 'package:flutter_application_1_user/views/screens/donation_screen.dart';
import 'package:flutter_application_1_user/views/screens/event_screen.dart';
import 'package:flutter_application_1_user/views/screens/home_screen.dart';
import 'package:flutter_application_1_user/views/screens/medical_services_screen.dart';
import 'package:flutter_application_1_user/views/screens/merch_screen.dart';
import 'package:flutter_application_1_user/views/widgets/notifications_bottom_sheet.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_storage/firebase_storage.dart';

class SharedDrawer extends StatefulWidget {
  const SharedDrawer({super.key});

  @override
  State<SharedDrawer> createState() => _SharedDrawerState();
}

class _SharedDrawerState extends State<SharedDrawer> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Use StreamController to handle user data updates
  late Stream<DocumentSnapshot> _userStream;

  @override
  void initState() {
    super.initState();
    // Initialize the stream
    final user = _auth.currentUser;
    if (user != null) {
      _userStream = _firestore.collection('users').doc(user.uid).snapshots();
    }
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => NotificationsBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          StreamBuilder<DocumentSnapshot>(
            stream: _userStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const UserAccountsDrawerHeader(
                  accountName: Text('Error loading data'),
                  accountEmail: Text(''),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const UserAccountsDrawerHeader(
                  accountName: Text('Loading...'),
                  accountEmail: Text(''),
                );
              }

              final userData = snapshot.data?.data() as Map<String, dynamic>?;
              final userName = userData?['fullName'] ?? 'User';
              final userEmail =
                  userData?['email'] ?? _auth.currentUser?.email ?? '';
              final userPhotoUrl =
                  userData?['user_profiles'] ?? userData?['profileImage'];

              return UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: Color(0xFF32649B)),
                currentAccountPicture: FutureBuilder<String>(
                  future: _getUserProfileImage(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircleAvatar(
                        backgroundColor: Colors.white,
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      return CircleAvatar(
                        backgroundColor: Colors.white,
                        backgroundImage: NetworkImage(snapshot.data!),
                      );
                    }

                    return const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 50, color: Colors.grey),
                    );
                  },
                ),
                otherAccountsPictures: [
                  StreamBuilder<QuerySnapshot>(
                    stream:
                        FirebaseFirestore.instance
                            .collection('notifications')
                            .where(
                              'userId',
                              isEqualTo: FirebaseAuth.instance.currentUser?.uid,
                            )
                            .where('isRead', isEqualTo: false)
                            .snapshots(),
                    builder: (context, snapshot) {
                      int unreadCount = 0;
                      if (snapshot.hasData) {
                        unreadCount = snapshot.data!.docs.length;
                      }
                      return Stack(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.notifications,
                              color: Colors.white,
                              size: 24,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              _showNotifications(context);
                            },
                          ),
                          if (unreadCount > 0)
                            Positioned(
                              right: 4,
                              top: 4,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  '$unreadCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
                accountName: Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                accountEmail: Text(
                  userEmail,
                  style: const TextStyle(color: Colors.white),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
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
          ExpansionTile(
            leading: const Icon(Icons.pets_rounded, color: Color(0xFF32649B)),
            title: const Text('Dog Rescue'),
            children: [
              ListTile(
                leading: const Icon(Icons.add_circle_outline),
                title: const Text('Report New Case'),
                onTap: () {
                  Navigator.pushNamed(context, '/rescue-report');
                },
              ),
              ListTile(
                leading: const Icon(Icons.list_alt),
                title: const Text('My Reports'),
                trailing: StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('rescue_reports')
                          .where(
                            'userId',
                            isEqualTo: FirebaseAuth.instance.currentUser?.uid,
                          )
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${snapshot.data!.docs.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                onTap: () {
                  Navigator.pushNamed(context, '/my-rescue-reports');
                },
              ),
            ],
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

  Future<String> _getUserProfileImage() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // First check Firestore for user profile URL
        final userData =
            await _firestore.collection('users').doc(user.uid).get();

        // Try all possible profile image field names
        final userPhotoUrl =
            userData.data()?['user_profiles'] ??
            userData.data()?['profileImage'] ??
            userData.data()?['photoUrl'];

        if (userPhotoUrl != null && userPhotoUrl.isNotEmpty) {
          return userPhotoUrl;
        }

        // If not in Firestore, try Firebase Storage
        try {
          final ref = FirebaseStorage.instance
              .ref()
              .child('user_profiles')
              .child('${user.uid}.jpg');

          final url = await ref.getDownloadURL();

          // Update Firestore with the URL
          await _firestore.collection('users').doc(user.uid).update({
            'user_profiles': url,
          });
          return url;
        } catch (storageError) {
          debugPrint('Storage error: $storageError');
        }
      }
    } catch (e) {
      debugPrint('Error loading profile image: $e');
    }
    return '';
  }
}

class MyAppBarWithBadge extends StatefulWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize;
  MyAppBarWithBadge({Key? key})
    : preferredSize = const Size.fromHeight(kToolbarHeight),
      super(key: key);

  @override
  State<MyAppBarWithBadge> createState() => _MyAppBarWithBadgeState();
}

class _MyAppBarWithBadgeState extends State<MyAppBarWithBadge> {
  int _unreadCount = 0;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // ...other AppBar properties...
      actions: [
        StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('notifications')
                  .where(
                    'userId',
                    isEqualTo: FirebaseAuth.instance.currentUser?.uid,
                  )
                  .where('isRead', isEqualTo: false)
                  .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              _unreadCount = snapshot.data!.docs.length;
            }
            return IconButton(
              icon: Stack(
                children: [
                  const Icon(Icons.notifications, color: Colors.white),
                  if (_unreadCount > 0)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$_unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: () {
                setState(() {
                  _unreadCount = 0; // Instantly hide badge
                });
                showModalBottomSheet(
                  context: context,
                  builder:
                      (context) => NotificationsBottomSheet(
                        onOpened: () {
                          setState(() {
                            _unreadCount = 0;
                          });
                        },
                      ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
