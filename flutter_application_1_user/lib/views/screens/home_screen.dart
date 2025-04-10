import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1_user/bloc/auth/auth_bloc.dart';
import 'package:flutter_application_1_user/bloc/auth/auth_event.dart';
import 'package:flutter_application_1_user/views/screens/adopted_dogs_screen.dart';
import 'package:flutter_application_1_user/views/screens/dog_screen.dart';
import 'package:flutter_application_1_user/views/screens/donation_screen.dart';
import 'package:flutter_application_1_user/views/screens/event_screen.dart';
import 'package:flutter_application_1_user/views/screens/merch_screen.dart';
import 'package:flutter_application_1_user/views/widgets/shared_drawer.dart';
import 'medical_services_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PageController _pageController = PageController();
  String? userPhotoUrl;
  Timer? _timer;
  int _currentImageIndex = 0;

  final List<String> _imageUrls = [
    'assets/images/dog-1.jpg',
    'assets/images/dog-2.jpg',
    'assets/images/dog-3.jpg',
  ];

  final List<String> actionImages = [
    'assets/images/donate.png',
    'assets/images/events.png',
    'assets/images/dogs.png',
    'assets/images/adopted.png',
    'assets/images/medical.png',
  ];

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // Don't start auto-scroll immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  void _startAutoScroll() {
    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return; // Check if widget is still mounted
      if (_pageController.hasClients) {
        // Check if controller has clients
        if (_currentImageIndex < _imageUrls.length - 1) {
          _currentImageIndex++;
        } else {
          _currentImageIndex = 0;
        }
        _pageController.animateToPage(
          _currentImageIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: const Color(0xFF32649B),
        automaticallyImplyLeading: false,
        title: InkWell(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
          child: Image.asset('assets/images/Furever_logo.png', height: 80),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: SharedDrawer(),
      body: Container(
        color: const Color.fromARGB(26, 206, 202, 202),
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification notification) {
            if (notification is ScrollUpdateNotification) {
              _onScroll();
            }
            return true;
          },
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // Hero Banner
              Stack(
                children: [
                  SizedBox(
                    height: 250,
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                      itemCount: _imageUrls.length,
                      itemBuilder: (context, index) {
                        return Image.asset(
                          _imageUrls[index],
                          width: double.infinity,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
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
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DonationScreen(),
                              ),
                            );
                          },
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

              // Quick Actions Section
              Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Follow the journey of our rescued dogs.',
                      style: TextStyle(
                        color: Color(0xFF32649B),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Quick action cards
                    _buildQuickActions(),
                    const SizedBox(height: 32),
                    _buildImpactSection(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              _buildAnimatedMission(),
              const SizedBox(height: 20),
              _buildAnimatedValues(),
              const SizedBox(height: 20),
              _buildContactFooter(),
            ],
          ),
        ),
      ),
    );
  }

  // Update the _buildActionCard method signature and implementation
  Widget _buildActionCard(
    String title,
    String imagePath, // Changed from IconData to String
    String subtitle,
    Color color,
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: () {
        if (title == 'Pet Adoption Day!') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EventScreen()),
          );
        } else if (title == 'Want to Adopt?') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DogScreen()),
          );
        } else if (title == 'Medical Concerns?') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MedicalServicesScreen(),
            ),
          );
        } else if (title == 'Shop Here!') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MerchScreen()),
          );
        }
      },
      child: Card(
        elevation: 4,
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Image.asset(imagePath, width: 100, fit: BoxFit.contain),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildActionCard(
          'Pet Adoption Day!',
          'assets/images/home-1.png',
          'See upcoming events',
          const Color.fromARGB(255, 255, 255, 255),
          context,
        ),
        _buildActionCard(
          'Want to Adopt?',
          'assets/images/home-2.png',
          'Browse available dogs',
          const Color.fromARGB(255, 255, 255, 255),
          context,
        ),
        _buildActionCard(
          'Medical Concerns?',
          'assets/images/home-3.png',
          'Check FAQs➡',
          const Color.fromARGB(255, 255, 255, 255),
          context,
        ),
        _buildActionCard(
          'Shop Here!',
          'assets/images/home-4.png',
          'Browse merches',
          const Color.fromARGB(255, 255, 255, 255),
          context,
        ),
      ],
    );
  }

  Widget _buildImpactSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 46, 199, 255),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Our Impact',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildAnimatedMission() {
    return SlideTransition(
      position: _slideAnimation,
      child: Stack(
        children: [
          Image.asset(
            'assets/images/dog-4.jpg',
            height: 400,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Container(
            height: 400,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 70,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Our Mission',
                  style: TextStyle(
                    color: Color.fromARGB(255, 255, 180, 49),
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  'To provide loving homes for abandoned and rescued dogs through responsible adoption, while promoting animal welfare education and compassionate pet care in our community.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedValues() {
    return SlideTransition(
      position: _slideAnimation,
      child: Stack(
        children: [
          Image.asset(
            'assets/images/dog-5.jpg',
            height: 300,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Container(
            height: 300,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  // ignore: deprecated_member_use
                  Colors.black.withOpacity(0.1),
                  // ignore: deprecated_member_use
                  Colors.black.withOpacity(0.6),
                ],
              ),
            ),
          ),
          Positioned(
            top: 30,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Text(
                  'Our Values',
                  style: TextStyle(
                    color: Color.fromARGB(255, 46, 199, 255),
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 170),
                Text(
                  'Compassion. Responsibility. Community.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactFooter() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Color(0xFF32649B),
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 10,
                  backgroundColor: const Color.fromARGB(255, 46, 199, 255),
                  child: const Icon(
                    Icons.location_on,
                    size: 13,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 5),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Visit Us',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '123 Pet Street, Manila',
                        style: TextStyle(fontSize: 10, color: Colors.white70),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 10,
                  backgroundColor: const Color.fromARGB(255, 46, 199, 255),
                  child: const Icon(Icons.email, size: 13, color: Colors.white),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Email Us',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'contact@fureverhome.org',
                        style: TextStyle(fontSize: 10, color: Colors.white70),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 10,
                  backgroundColor: const Color.fromARGB(255, 46, 199, 255),
                  child: const Icon(Icons.phone, size: 13, color: Colors.white),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Call Us',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '+63 123 456 7890',
                        style: TextStyle(fontSize: 10, color: Colors.white70),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            color: Color.fromARGB(221, 255, 255, 255),
          ),
        ),
      ],
    );
  }
}
