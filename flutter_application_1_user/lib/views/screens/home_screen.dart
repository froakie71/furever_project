import 'package:flutter/material.dart';
import 'package:flutter_application_1_user/bloc/auth/auth_bloc.dart';
import 'package:flutter_application_1_user/bloc/auth/auth_event.dart';
import 'package:flutter_application_1_user/views/screens/adopted_dogs_screen.dart';
import 'package:flutter_application_1_user/views/screens/dog_screen.dart';
import 'package:flutter_application_1_user/views/screens/donation_screen.dart';
import 'package:flutter_application_1_user/views/screens/event_screen.dart';
import 'package:flutter_application_1_user/views/screens/merch_screen.dart';
import 'package:flutter_application_1_user/widgets/shared_drawer.dart';
import 'medical_services_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'authentication/sign_in_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: SharedDrawer(),
      appBar: AppBar(
        title: Image.asset('assets/images/Furever_logo.png', height: 40),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),

      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Hero Banner
          Stack(
            children: [
              Image.asset(
                'assets/images/Furever_logo.png',
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 250,
                    color: Colors.grey[300],
                    child: const Icon(Icons.error),
                  );
                },
              ),
              Container(
                height: 250,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Help them find a home',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Donate Now'),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Quick Actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'How You Can Help',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _buildActionCard(
                      'Events',
                      Icons.event,
                      'View upcoming events',
                      Colors.purple,
                      context,
                    ),
                    _buildActionCard(
                      'Dogs',
                      Icons.pets,
                      'Browse available dogs',
                      Colors.blue,
                      context,
                    ),
                    _buildActionCard(
                      'Donate',
                      Icons.volunteer_activism,
                      'Support our cause',
                      Colors.orange,
                      context,
                    ),
                    _buildActionCard(
                      'Adopted',
                      Icons.favorite,
                      'Your adopted pets',
                      Colors.red,
                      context,
                    ),
                    _buildActionCard(
                      'Medical',
                      Icons.medical_services,
                      'Pet health services',
                      Colors.green,
                      context,
                    ),
                    _buildActionCard(
                      'About',
                      Icons.info_outline,
                      'Learn about us',
                      Colors.teal,
                      context,
                    ),
                  ],
                ),
                SizedBox(height: 32),
                //               const Text(
                //                 'Dogs for Adoption',
                //                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                //               ),
                //               const SizedBox(height: 16),
                //               ListView.builder(
                //                 shrinkWrap: true,
                //                 physics: const NeverScrollableScrollPhysics(),
                //                 itemCount: 5,
                //                 itemBuilder: (context, index) {
                //                   return Card(
                //                     margin: const EdgeInsets.only(bottom: 16),
                //                     child: Column(
                //                       crossAxisAlignment: CrossAxisAlignment.start,
                //                       children: [
                //                         ClipRRect(
                //                           borderRadius: const BorderRadius.vertical(
                //                             top: Radius.circular(8),
                //                           ),
                //                           child: Image.asset(
                //                             'assets/images/Furever_logo.png',
                //                             height: 200,
                //                             width: double.infinity,
                //                             fit: BoxFit.cover,
                //                           ),
                //                         ),
                //                         Padding(
                //                           padding: const EdgeInsets.all(16),
                //                           child: Column(
                //                             crossAxisAlignment: CrossAxisAlignment.start,
                //                             children: [
                //                               Text(
                //                                 'Dog ${index + 1}',
                //                                 style: const TextStyle(
                //                                   fontSize: 20,
                //                                   fontWeight: FontWeight.bold,
                //                                 ),
                //                               ),
                //                               const SizedBox(height: 8),
                //                               Text(
                //                                 'Age: 2 years • Gender: Male\nBreed: Mixed',
                //                                 style: TextStyle(color: Colors.grey[600]),
                //                               ),
                //                               const SizedBox(height: 16),
                //                               ElevatedButton(
                //                                 onPressed: () {},
                //                                 style: ElevatedButton.styleFrom(
                //                                   backgroundColor: Colors.orange,
                //                                   foregroundColor: Colors.white,
                //                                 ),
                //                                 child: const Text('Learn More'),
                //                               ),
                //                             ],
                //                           ),
                //                         ),
                //                       ],
                //                     ),
                //                   );
                //                 },
                //               ),
                //               const SizedBox(height: 32),
                _buildAboutUsSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    String subtitle,
    Color color,
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: () {
        if (title == 'Donate') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DonationScreen()),
          );
        } else if (title == 'Events') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EventScreen()),
          );
        } else if (title == 'Dogs') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DogScreen()),
          );
        } else if (title == 'Adopted') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdoptedDogsScreen()),
          );
        } else if (title == 'Medical') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MedicalServicesScreen()),
          );
        }
      },
      child: Card(
        elevation: 2,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: color, width: 4)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAboutUsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About Us',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF32649B),
            ),
          ),
          const SizedBox(height: 16),

          // Hero Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/about_us_banner.jpg', // Add this image to your assets
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback container if image fails to load
                return Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.pets, size: 50, color: Colors.grey[600]),
                      const SizedBox(height: 8),
                      Text(
                        'Furever Home',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Mission
          const Text(
            'Our Mission',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF32649B),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'To provide loving homes for abandoned and rescued dogs through responsible adoption, while promoting animal welfare education and compassionate pet care in our community.',
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 24),

          // Impact Stats
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Our Impact',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF32649B),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard('500+', 'Dogs\nRescued'),
                    _buildStatCard('400+', 'Happy\nAdopters'),
                    _buildStatCard('50+', 'Partner\nVets'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Contact Info
          const Text(
            'Get in Touch',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF32649B),
            ),
          ),
          const SizedBox(height: 16),
          _buildContactTile(
            Icons.location_on,
            'Visit Us',
            '123 Pet Street, Manila, Philippines',
          ),
          _buildContactTile(Icons.email, 'Email Us', 'contact@fureverhome.org'),
          _buildContactTile(Icons.phone, 'Call Us', '+63 123 456 7890'),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildContactTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.orange.shade100,
        child: Icon(icon, color: Colors.orange),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}
