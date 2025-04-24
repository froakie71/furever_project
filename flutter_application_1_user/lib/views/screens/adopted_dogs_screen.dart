import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1_user/bloc/schedule_checkup/schedule_checkup_bloc.dart';
import 'package:flutter_application_1_user/views/screens/dog_screen.dart';
import 'package:flutter_application_1_user/views/screens/donation_screen.dart';
import 'package:flutter_application_1_user/views/screens/event_screen.dart';
import 'package:flutter_application_1_user/views/screens/merch_screen.dart';
import 'package:flutter_application_1_user/views/widgets/shared_drawer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_1_user/views/widgets/schedule_checkup_modal.dart';

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
        .where(
          'status',
          isEqualTo: 'approved',
        ) // Changed from 'accepted' to 'approved'
        .snapshots()
        .asyncMap((adoptionsSnapshot) async {
          final adoptedDogs = <Map<String, dynamic>>[];

          for (var adoption in adoptionsSnapshot.docs) {
            try {
              final adoptionData = adoption.data();
              if (adoptionData == null) continue;

              // Get dog details
              final dogDoc =
                  await FirebaseFirestore.instance
                      .collection('dogs')
                      .doc(adoptionData['dogId'])
                      .get();

              if (!dogDoc.exists || dogDoc.data() == null) continue;

              final dogData = dogDoc.data()!;

              // Include all relevant dog and adoption data
              adoptedDogs.add({
                'id': adoption.id,
                'dogId': adoptionData['dogId'],
                'dogName':
                    dogData['name'] ??
                    'Unknown', // Changed to use dog's actual name
                'imageUrl': dogData['imageUrl'] ?? '',
                'breed': dogData['breed'] ?? 'Unknown',
                'adoptionDate':
                    adoptionData['approvedAt'] ??
                    adoptionData['submittedAt'], // Use approval date
                'vetVisits': dogData['vetVisits'] ?? 0,
                'userEmail': currentUser.email ?? 'Unknown',
                'status': adoptionData['status'] ?? 'approved',
                'medicalRecords':
                    dogData['medicalRecords'] ?? '', // Changed from {} to ''
              });
            } catch (e) {
              debugPrint('Error processing adoption document: $e');
              continue;
            }
          }

          // Sort the dogs
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
      child: InkWell(
        // Add this InkWell
        onTap: () => _showDogDetails(context, dog),
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
                    label: Text('Schedule Checkup'),
                    icon: Icon(Icons.calendar_today),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder:
                            (_) => BlocProvider.value(
                              value: context.read<ScheduleCheckupBloc>(),
                              child: ScheduleCheckupModal(
                                dogId: dog['dogId'],
                                userId: FirebaseAuth.instance.currentUser!.uid,
                              ),
                            ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
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

  void _showDogDetails(BuildContext context, Map<String, dynamic> dog) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                // Dog Image
                Container(
                  height: 200,
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      dog['imageUrl'],
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) => Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.pets, size: 50),
                          ),
                    ),
                  ),
                ),
                // Dog Info
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dog['dogName'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF32649B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow('Breed', dog['breed']),
                        _buildInfoRow(
                          'Adoption Date',
                          _formatDate(dog['adoptionDate']),
                        ),
                        _buildInfoRow('Status', dog['status']),
                        _buildInfoRow(
                          'Vet Visits',
                          '${dog['vetVisits']} visits',
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Medical Records',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF32649B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._buildMedicalRecordsList(dog['medicalRecords']),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // Replace the existing _buildMedicalRecordsList method with:
  List<Widget> _buildMedicalRecordsList(dynamic medicalRecords) {
    if (medicalRecords is String) {
      // Handle medical records as text
      return [
        Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicalRecords.isEmpty
                      ? 'No medical records available'
                      : medicalRecords,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ];
    }

    // Fallback for empty or invalid records
    return [
      Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: const ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.orange,
            child: Icon(Icons.medical_services, color: Colors.white),
          ),
          title: Text('Medical Records'),
          subtitle: Text('No records available'),
        ),
      ),
    ];
  }
}
