import 'package:flutter/material.dart';
import 'package:furever_home/views/screens/adopted_dogs_screen.dart';
import 'package:furever_home/views/screens/dog_screen.dart';
import 'package:furever_home/views/screens/donation_screen.dart';
import 'package:furever_home/views/screens/event_screen.dart';
import 'package:furever_home/views/screens/merch_screen.dart';
import 'package:furever_home/views/screens/home_screen.dart';


class MedicalServicesScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar:AppBar(
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
            padding: const EdgeInsets.only(right: 16.0), // Adjust the value as needed
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Emergency Contact Card
          Card(
            color: Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.red.shade100,
                        child: const Icon(
                          Icons.emergency,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Emergency Hotline',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('24/7 Veterinary Support'),
                          ],
                        ),
                      ),
                      const Text('+63 917 123 4567'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),

          // Available Services Section
          const Text(
            'Frequently Asked Questions',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
        ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            ExpansionTile(
              title: const Text(
                'How often should I feed my dog?',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              children: const [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Adult dogs should typically be fed twice a day, while puppies need 3-4 meals daily. The amount depends on size, age, and activity level. Consult your vet for specific recommendations.',
                  ),
                ),
              ],
            ),
            ExpansionTile(
              title: const Text(
                'How often should my dog visit the vet?',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              children: const [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Adult dogs should have annual check-ups, while puppies need multiple visits for vaccinations. Senior dogs (7+ years) should visit twice yearly.',
                  ),
                ),
              ],
            ),
            ExpansionTile(
              title: const Text(
                'What vaccinations does my dog need?',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              children: const [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Core vaccinations include: Rabies, Distemper, Parvovirus, and Hepatitis. Additional vaccines may be recommended based on lifestyle and location.',
                  ),
                ),
              ],
            ),
            ExpansionTile(
              title: const Text(
                'How often should I groom my dog?',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              children: const [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Brush your dog 1-2 times weekly, bathe every 4-8 weeks depending on coat type. Nail trimming needed every 2-4 weeks, and dental care should be done daily.',
                  ),
                ),
              ],
            ),
            ExpansionTile(
              title: const Text(
                'How much exercise does my dog need?',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              children: const [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Most dogs need 30-60 minutes of exercise daily. Working and high-energy breeds may need more. Exercise needs vary by age, breed, and health status.',
                  ),
                ),
              ],
            ),
          ],
        ),  
        ],
      ),
    );
  }

  
}
