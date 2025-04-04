import 'package:flutter/material.dart';
import 'package:flutter_application_1_user/theme/app_theme.dart';
import 'package:flutter_application_1_user/widgets/shared_drawer.dart';
import 'medical_services_screen.dart';

class AdoptedDogsScreen extends StatefulWidget {
  const AdoptedDogsScreen({super.key});

  @override
  State<AdoptedDogsScreen> createState() => _AdoptedDogsScreenState();
}

class _AdoptedDogsScreenState extends State<AdoptedDogsScreen> {
  List<Map<String, dynamic>> _adoptedDogs = [];
  bool _sortByNewest = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Initialize with sample data
    _adoptedDogs = [
      {
        'name': 'Max',
        'breed': 'Golden Retriever',
        'adoptionDate': '2024-03-15',
        'image': 'assets/images/dog1.jpg',
        'vetVisits': 3,
      },
      {
        'name': 'Luna',
        'breed': 'Labrador',
        'adoptionDate': '2023-12-20',
        'image': 'assets/images/dog2.jpg',
        'vetVisits': 5,
      },
      // Add more sample data as needed
    ];
    _sortDogs('newest'); // Initial sort
  }

  void _sortDogs(String value) {
    setState(() {
      _sortByNewest = value == 'newest';
      _adoptedDogs.sort((a, b) {
        DateTime dateA = DateTime.parse(a['adoptionDate']);
        DateTime dateB = DateTime.parse(b['adoptionDate']);
        return _sortByNewest ? dateB.compareTo(dateA) : dateA.compareTo(dateB);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer:  SharedDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFF32649B),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        // Remove title and add it to actions
        title: const Text('My Adopted Dogs'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Image.asset(
              'assets/images/Furever_logo.png',
              height: 40, // Adjusted height to fit better in the AppBar
            ),
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
          // Header with filter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'My Adopted Dogs',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF32649B),
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.filter_list),
                onSelected: _sortDogs,
                itemBuilder:
                    (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'newest',
                        child: Text('Sort by Newest'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'oldest',
                        child: Text('Sort by Oldest'),
                      ),
                    ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Stats Container
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 185, 80),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('2', 'Dogs\nAdopted'),
                _buildStatItem('2', 'Years as\nAdopter'),
                _buildStatItem('12', 'Vet Visits\nMade'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Display cards
          ..._adoptedDogs.map(
            (dog) => Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(dog['image']),
                    ),
                    title: Text(
                      dog['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(dog['breed']),
                        Text(
                          'Adopted on: ${dog['adoptionDate']}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton.icon(
                          icon: const Icon(
                            Icons.medical_services,
                            color: Colors.white,
                          ),
                          label: const Text('Medical Records'),
                          onPressed: () {
                            _showMedicalRecords(context, 0);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xFF32649B),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        TextButton.icon(
                          icon: const Icon(
                            Icons.calendar_today,
                            color: Colors.white,
                          ),
                          label: const Text('Schedule Checkup'),
                          onPressed: () {
                            // Handle schedule checkup action
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color.fromARGB(
                              255,
                              240,
                              163,
                              47,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pop(context); // Return to home
          // TODO: Navigate to available dogs screen
        },
        backgroundColor: Colors.orange,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Adopt Another',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  void _showMedicalRecords(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(16),
            height: MediaQuery.of(context).size.height * 0.6, // Set height
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_adoptedDogs[index]['name']}\'s Medical Records',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView(
                    children: [
                      _buildMedicalRecord(
                        date: 'Mar 15, 2024',
                        procedure: 'First Vaccination',
                        notes: 'DHPP vaccine administered',
                      ),
                      _buildMedicalRecord(
                        date: 'Feb 20, 2024',
                        procedure: 'Initial Checkup',
                        notes: 'General health assessment - All healthy',
                      ),
                      _buildMedicalRecord(
                        date: 'Feb 10, 2024',
                        procedure: 'Deworming',
                        notes: 'Preventive deworming treatment',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMedicalRecord({
    required String date,
    required String procedure,
    required String notes,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(
        procedure,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(notes),
          const SizedBox(height: 4),
          Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
      leading: const CircleAvatar(
        backgroundColor: Colors.orange,
        child: Icon(Icons.medical_services, color: Colors.white, size: 20),
      ),
    );
  }
}
