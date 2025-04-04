import 'package:flutter/material.dart';
import 'package:flutter_application_1_user/theme/app_theme.dart';
import 'package:flutter_application_1_user/widgets/shared_drawer.dart';

class MedicalServicesScreen extends StatelessWidget {
   MedicalServicesScreen({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer:  SharedDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFF32649B),
        title: const Text('Medical Services'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Image.asset('assets/images/Furever_logo.png', height: 40),
          ),
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Emergency Contact Card
          Card(
            color: Colors.red.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.red.shade100,
                        child: const Icon(Icons.emergency, color: Colors.red),
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
                                color: Color(0xFF32649B),
                              ),
                            ),
                            Text(
                              '24/7 Veterinary Support',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.phone, color: Colors.white),
                        label: const Text(
                          '+63 917 123 4567',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        onPressed: () {
                          // Add phone call functionality
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Available Services Section
          const Text(
            'Available Services',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF32649B),
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildServiceCard(
                'Vaccination',
                Icons.vaccines,
                'Protect your pet',
                const Color(0xFF32649B),
              ),
              _buildServiceCard(
                'Check-up',
                Icons.health_and_safety,
                'Regular wellness',
                const Color.fromARGB(255, 240, 163, 47),
              ),
              _buildServiceCard(
                'Surgery',
                Icons.medical_services,
                'Special procedures',
                const Color(0xFF32649B),
              ),
              _buildServiceCard(
                'Dental Care',
                Icons.cleaning_services,
                'Oral health',
                const Color.fromARGB(255, 240, 163, 47),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(
    String title,
    IconData icon,
    String description,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: color, width: 4)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
