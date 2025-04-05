import 'package:flutter/material.dart';
import 'package:furever_home/views/screens/adopted_dogs_screen.dart';
import 'package:furever_home/views/screens/dog_screen.dart';
import 'package:furever_home/views/screens/donation_screen.dart';
import 'package:furever_home/views/screens/event_screen.dart';
import 'package:furever_home/views/screens/merch_screen.dart';
import 'medical_services_screen.dart';
import 'about_screen.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PageController _pageController = PageController();
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
    'assets/images/medical.png'
  ];

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(
          -1.0, 0.0), // Start from left (-1.0) instead of right (1.0)
      end: Offset.zero, // End at original position
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
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
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _controller.dispose();
    super.dispose();
  }

  // Add this to trigger animation when scrolled into view
  void _onScroll() {
    // You can add logic here to determine when to start animation
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
              MaterialPageRoute(
                builder: (context) => HomeScreen(),
              ),
            );
          },
          child: Image.asset(
            'assets/images/Furever_logo.png',
            height: 80,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(
                right: 16.0), // Adjust the value as needed
            child: IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                _scaffoldKey.currentState?.openEndDrawer();
              },
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.grey,
                ),
              ),
              accountName: Text('John Doe'),
              accountEmail: Text('johndoe@example.com'),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(),
                  ),
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
                  MaterialPageRoute(
                    builder: (context) => EventScreen(),
                  ),
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
                  MaterialPageRoute(
                    builder: (context) => DogScreen(),
                  ),
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
                  MaterialPageRoute(
                    builder: (context) => const DonationScreen(),
                  ),
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
                  MaterialPageRoute(
                    builder: (context) => const MerchScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                // TODO: Implement logout functionality
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
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

              // Quick Actions
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
                    Wrap(
                      spacing: 16, // horizontal spacing
                      runSpacing: 16, // vertical spacing
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
                          'Shope Here!',
                          'assets/images/home-4.png',
                          'Browse merches',
                          const Color.fromARGB(255, 255, 255, 255),
                          context,
                        ),
                        // _buildActionCard(
                        //   'Medical',
                        //   'assets/images/medical.png',
                        //   'Pet health services',
                        //   const Color.fromARGB(255, 188, 185, 185),
                        //   context,
                        // ),
                        // _buildActionCard(
                        //   'About',
                        //   'assets/images/medical.png',
                        //   'Learn about us',
                        //   const Color.fromARGB(255, 188, 185, 185),
                        //   context,
                        // ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'About Us',
                      style: TextStyle(
                        fontSize: 24,
                        color: Color(0xFF32649B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
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
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              _buildAnimatedMission(),
              const SizedBox(height: 20),
              _buildAnimatedValues(),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  color: Color(0xFF32649B),
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Location Info
                    Expanded(
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 10,
                            backgroundColor:
                                const Color.fromARGB(255, 46, 199, 255),
                            child: const Icon(Icons.location_on,
                                size: 13, color: Colors.white),
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
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white70,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Email Info
                    Expanded(
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 10,
                            backgroundColor:
                                const Color.fromARGB(255, 46, 199, 255),
                            child: const Icon(Icons.email,
                                size: 13, color: Colors.white),
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
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white70,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Phone Info
                    Expanded(
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 10,
                            backgroundColor:
                                const Color.fromARGB(255, 46, 199, 255),
                            child: const Icon(Icons.phone,
                                size: 13, color: Colors.white),
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
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white70,
                                  ),
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
              ),
            ],
          ),
        ),
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

  Widget _buildActionCard(String title, String imagePath, String subtitle,
      Color color, BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (title == 'Donate') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DonationScreen(),
            ),
          );
        } else if (title == 'Pet Adoption Day!') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventScreen(),
            ),
          );
        } else if (title == 'Want to Adopt?') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DogScreen(),
            ),
          );
        } else if (title == 'Adopted') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AdoptedDogsScreen(),
            ),
          );
        } else if (title == 'Medical Concerns?') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MedicalServicesScreen(),
            ),
          );
        } else if (title == 'Shope Here!') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MerchScreen(),
            ),
          );
        } else if (title == 'About') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AboutScreen(),
            ),
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
              // Right side - Image
              const SizedBox(width: 16),
              Image.asset(
                imagePath,
                width: 100,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
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
              children: [
                const Text(
                  'Our Mission',
                  style: TextStyle(
                    color: Color.fromARGB(255, 255, 180, 49),
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
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
                  Colors.black.withOpacity(0.1),
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
              children: [
                const Text(
                  'Our Values',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 46, 199, 255),
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 170),
                const Text(
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
}
