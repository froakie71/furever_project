import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1_user/views/screens/dog_screen.dart';
import 'package:flutter_application_1_user/views/screens/donation_screen.dart';
import 'package:flutter_application_1_user/views/screens/event_screen.dart';
import 'package:flutter_application_1_user/views/screens/merch_screen.dart';
import 'package:flutter_application_1_user/views/widgets/shared_drawer.dart';
import 'medical_services_screen.dart';

class AdoptedDogsScreen extends StatefulWidget {
  const AdoptedDogsScreen({super.key});

  @override
  State<AdoptedDogsScreen> createState() => _AdoptedDogsScreenState();
}

class _AdoptedDogsScreenState extends State<AdoptedDogsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _sortByNewest = true;

  Stream<List<Map<String, dynamic>>> _getAdoptedDogs() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return Stream.value([]);

    return FirebaseFirestore.instance
        .collection('adoptions')
        .where('userId', isEqualTo: currentUser.uid)
        .where('status', isEqualTo: 'accepted')
        .snapshots()
        .asyncMap((adoptionsSnapshot) async {
          final adoptedDogs = <Map<String, dynamic>>[];

          for (var adoption in adoptionsSnapshot.docs) {
            try {
              final adoptionData = adoption.data();
              if (adoptionData == null) {
                continue;
              }

              // Get dog details
              final dogDoc =
                  await FirebaseFirestore.instance
                      .collection('dogs')
                      .doc(adoptionData['dogId'])
                      .get();

              if (!dogDoc.exists || dogDoc.data() == null) {
                continue;
              }

              final dogData = dogDoc.data()!;

              adoptedDogs.add({
                'id': adoption.id,
                'dogId': adoptionData['dogId'],
                'dogName': adoptionData['dogName'] ?? 'Unknown',
                'imageUrl': adoptionData['dogImageUrl'] ?? '',
                'breed': dogData['breed'] ?? 'Unknown',
                'adoptionDate': adoptionData['submittedAt'] as Timestamp,
                'vetVisits': dogData['vetVisits'] ?? 0,
                'userEmail': adoptionData['userEmail'] ?? 'Unknown',
                'status': adoptionData['status'] ?? 'accepted',
              });
            } catch (e) {
              debugPrint('Error processing adoption document: $e');
              continue;
            }
          }

          if (_sortByNewest) {
            adoptedDogs.sort(
              (a, b) => (b['adoptionDate'] as Timestamp).compareTo(
                a['adoptionDate'] as Timestamp,
              ),
            );
          } else {
            adoptedDogs.sort(
              (a, b) => (a['adoptionDate'] as Timestamp).compareTo(
                b['adoptionDate'] as Timestamp,
              ),
            );
          }

          return adoptedDogs;
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: const Color(0xFF32649B),
        automaticallyImplyLeading: false,
        title: Image.asset('assets/images/Furever_logo.png', height: 80),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
      ),
      endDrawer: SharedDrawer(),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _getAdoptedDogs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final adoptedDogs = snapshot.data ?? [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
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
                  PopupMenuButton<bool>(
                    icon: const Icon(Icons.filter_list),
                    onSelected: (bool value) {
                      setState(() => _sortByNewest = value);
                    },
                    itemBuilder:
                        (context) => [
                          const PopupMenuItem(
                            value: true,
                            child: Text('Sort by Newest'),
                          ),
                          const PopupMenuItem(
                            value: false,
                            child: Text('Sort by Oldest'),
                          ),
                        ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 185, 80),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      adoptedDogs.length.toString(),
                      'Dogs\nAdopted',
                    ),
                    _buildStatItem(
                      _calculateAdoptionYears(adoptedDogs),
                      'Years as\nAdopter',
                    ),
                    _buildStatItem(
                      _calculateTotalVetVisits(adoptedDogs).toString(),
                      'Vet Visits\nMade',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ...adoptedDogs.map((dog) => _buildDogCard(dog)).toList(),
            ],
          );
        },
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

  // Update the _calculateAdoptionYears method to handle Timestamp
  String _calculateAdoptionYears(List<Map<String, dynamic>> dogs) {
    if (dogs.isEmpty) return '0';
    final firstAdoption = dogs
        .map((d) => (d['adoptionDate'] as Timestamp).toDate())
        .reduce((a, b) => a.isBefore(b) ? a : b);
    return ((DateTime.now().difference(firstAdoption).inDays / 365))
        .toStringAsFixed(1);
  }

  int _calculateTotalVetVisits(List<Map<String, dynamic>> dogs) {
    return dogs.fold(0, (sum, dog) => sum + (dog['vetVisits'] as int));
  }

  // Update the _buildDogCard method to use the proper date format
  Widget _buildDogCard(Map<String, dynamic> dog) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(dog['imageUrl']),
              onBackgroundImageError: (_, __) => const Icon(Icons.error),
            ),
            title: Text(
              dog['dogName'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dog['breed']),
                Text(
                  'Adopted on: ${_formatDate(dog['adoptionDate'])}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.medical_services),
                  label: const Text('Medical Records'),
                  onPressed: () => _showMedicalRecords(context, dog),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF32649B),
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Schedule Checkup'),
                  onPressed: () {
                    // Implement checkup scheduling
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Update the _formatDate method to handle Timestamp
  String _formatDate(dynamic date) {
    if (date is Timestamp) {
      final DateTime dateTime = date.toDate();
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    }
    return 'Date not available';
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

  void _showMedicalRecords(BuildContext context, Map<String, dynamic> dog) {
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
                  '${dog['dogName']}\'s Medical Records',
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
