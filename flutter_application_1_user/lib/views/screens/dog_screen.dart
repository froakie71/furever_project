import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1_user/bloc/adoption/adoption_bloc.dart';
import 'package:flutter_application_1_user/bloc/adoption/adoption_event.dart';
import 'package:flutter_application_1_user/bloc/adoption/adoption_state.dart';
import 'package:flutter_application_1_user/models/dog_model.dart';
import 'package:flutter_application_1_user/views/screens/home_screen.dart';
import 'package:flutter_application_1_user/views/widgets/shared_drawer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DogScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DogScreen({super.key});

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
      endDrawer: const SharedDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Available Dogs',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF32649B),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.filter_list),
                      onPressed: () {
                        // TODO: Implement filtering
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        // TODO: Implement search
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('dogs')
                      .orderBy(
                        'createdAt',
                        descending: true,
                      ) // Add sorting by creation date
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No dogs available for adoption'),
                  );
                }

                final dogs =
                    snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      // If status is missing, treat as available
                      if (!data.containsKey('status')) {
                        data['status'] = 'available';
                      }
                      data['id'] = doc.id;
                      return Dog.fromFirestore(doc);
                    }).toList();

                // Filter available dogs after getting the data
                final availableDogs =
                    dogs
                        .where(
                          (dog) =>
                              dog.status == 'available' || dog.status.isEmpty,
                        )
                        .toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: availableDogs.length,
                  itemBuilder: (context, index) {
                    final dog = availableDogs[index];
                    return _buildDogCard(context, dog);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDogCard(BuildContext context, Dog dog) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showDogDetails(context, dog),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                  child: Container(
                    height: 300,
                    width: double.infinity,
                    child: Image.network(
                      dog.imageUrl,
                      fit: BoxFit.cover,
                      cacheHeight: 400,
                      cacheWidth: 600,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            color: const Color(0xFF32649B),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          color: Colors.grey[300],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 40,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Unable to load image',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (dog.status == 'adopted' || dog.status == 'pending')
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusBadgeColor(dog.status),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getStatusBadgeText(
                          dog.status,
                          dog.adoptedBy, // Pass the adoptedBy value directly
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dog.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dog.breed,
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildInfoChip(
                        dog.gender == 'Male' ? Icons.male : Icons.female,
                        dog.gender,
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(Icons.straighten, dog.size),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed:
                        (dog.status == 'adopted' || dog.status == 'pending')
                            ? null
                            : () => _showAdoptionForm(context, dog),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getButtonColor(dog.status),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      disabledBackgroundColor: _getDisabledButtonColor(
                        dog.status,
                      ),
                    ),
                    child: Text(_getButtonText(dog.status)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAdoptionForm(BuildContext context, Dog dog) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to adopt a dog')),
      );
      return;
    }

    // Show confirmation dialog first
    final shouldProceed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Adoption'),
          content: const Text(
            'Are you sure you want to start the adoption process?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Proceed'),
            ),
          ],
        );
      },
    );

    if (shouldProceed != true || !context.mounted) return;

    // Updated: Use RequestAdoption event
    context.read<AdoptionBloc>().add(
      RequestAdoption(userId: currentUser.uid, dogId: dog.id),
    );

    // Show processing dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => BlocListener<AdoptionBloc, AdoptionState>(
            listener: (context, state) {
              if (state is AdoptionSuccess) {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Close dog details
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Adoption request submitted successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const AlertDialog(
              content: Center(child: CircularProgressIndicator()),
            ),
          ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildMedicalRecords(String medicalRecords) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Medical Records',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            medicalRecords.isEmpty
                ? 'No medical records available'
                : medicalRecords,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  void _showDogDetails(BuildContext context, Dog dog) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85, // Increased height for more space
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    dog.imageUrl,
                    // Using constraints instead of fixed height
                    height: MediaQuery.of(context).size.height * 0.35, // Adaptive height based on screen size
                    width: double.infinity,
                    fit: BoxFit.contain, // Changed to contain to show the full image
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          color: const Color(0xFF32649B),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: const Icon(Icons.error),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  dog.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  dog.breed,
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildInfoChip(
                      dog.gender == 'Male' ? Icons.male : Icons.female,
                      dog.gender,
                    ),
                    _buildInfoChip(Icons.straighten, dog.size),
                  ],
                ),
                const SizedBox(height: 24),
                _buildMedicalRecords(dog.medicalRecords),
                const SizedBox(height: 24),
                const Text(
                  'Description',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  dog.description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                // SizedBox(
                //   width: double.infinity,
                //   child: ElevatedButton(
                //     onPressed: () {
                //       Navigator.pop(context);
                //       _showAdoptionForm(context, dog);
                //     },
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: Colors.orange,
                //       foregroundColor: Colors.white,
                //       padding: const EdgeInsets.symmetric(vertical: 16),
                //     ),
                //     child: const Text('Adopt Me'),
                //   ),
                // ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getStatusBadgeColor(String status) {
    switch (status) {
      case 'adopted':
        return Colors.black54;
      case 'pending':
        return Colors.orange.withOpacity(0.8);
      default:
        return Colors.green;
    }
  }

  String _getStatusBadgeText(String status, String? userEmail) {
    switch (status) {
      case 'adopted':
        return 'Adopted${userEmail != null ? ' by $userEmail' : ''}';
      case 'pending':
        return 'Ongoing Adoption Process';
      default:
        return 'Available';
    }
  }

  Color _getButtonColor(String status) {
    switch (status) {
      case 'adopted':
        return Colors.grey;
      case 'pending':
        return Colors.orange.shade300;
      default:
        return Colors.orange;
    }
  }

  Color _getDisabledButtonColor(String status) {
    switch (status) {
      case 'adopted':
        return Colors.grey.shade300;
      case 'pending':
        return Colors.orange.shade200;
      default:
        return Colors.grey.shade300;
    }
  }

  String _getButtonText(String status) {
    switch (status) {
      case 'adopted':
        return 'Already Adopted';
      case 'pending':
        return 'Ongoing Adoption Process';
      default:
        return 'Adopt Me';
    }
  }
}
