import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_1/views/screens/Dogs/add_dog_screen.dart';
import 'package:flutter_application_1/views/screens/Dogs/bloc/dog_bloc.dart';
import 'package:flutter_application_1/views/screens/Dogs/bloc/dog_event.dart';
import 'package:flutter_application_1/views/screens/Dogs/bloc/dog_state.dart';

class DogsListScreen extends StatelessWidget {
  const DogsListScreen({super.key});

  void _showDeleteConfirmation(BuildContext context, String dogId) {
    showDialog(
      context: context,
      barrierDismissible: false, // User must tap a button to dismiss the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.warning, color: Colors.red),
              const SizedBox(width: 8),
              const Text('Delete Dog'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete this dog?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                'This action cannot be undone. All data associated with this dog will be permanently removed from the system.',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<DogBloc>().add(DeleteDog(dogId: dogId));
                Navigator.of(context).pop();
                // Show a temporary confirmation message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Dog deleted successfully'),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
  

  void _showDogDetails(BuildContext context, Map<String, dynamic> dog) {
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
          color: Colors.white, // Set background to fully white
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.35,
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: dog['imageUrl'] != null && dog['imageUrl'].toString().isNotEmpty
                      ? Image.network(
                          dog['imageUrl'].toString(),
                          fit: BoxFit.contain,
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
                            print('Image error in details view: $error');
                            return Container(
                              height: 250,
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
                        )
                      : Center(
                          child: Icon(
                            Icons.photo_library,
                            size: 40,
                            color: Colors.grey[600],
                          ),
                        ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  dog['name'] ?? 'Unnamed',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  dog['breed'] ?? 'Unknown breed',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildDetailChip(
                      dog['gender'] == 'Male' ? Icons.male : Icons.female,
                      dog['gender'] ?? 'Unknown',
                    ),
                    _buildDetailChip(
                      Icons.straighten,
                      dog['size'] ?? 'Unknown size',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildMedicalRecords(dog['medicalRecords']),
                const SizedBox(height: 24),
                const Text(
                  'Description',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  dog['description'] ?? 'No description available',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildMedicalRecords(dynamic medicalRecords) {
    final recordsText = medicalRecords != null && medicalRecords.toString().isNotEmpty
        ? medicalRecords.toString()
        : 'No medical records available';
        
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
            recordsText,
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
  
  Widget _buildDetailChip(IconData icon, String label) {
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
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DogBloc(),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Dogs List')),
          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('dogs')
                .where('status', isNotEqualTo: 'adopted') // Filter out adopted dogs
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                print('Firestore Error: ${snapshot.error}');
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final dogs = snapshot.data!.docs;
              print('Number of dogs fetched: ${dogs.length}');

              if (dogs.isEmpty) {
                return const Center(child: Text('No dogs available'));
              }

              // Debug print first dog data
              if (dogs.isNotEmpty) {
                final firstDog = dogs.first.data() as Map<String, dynamic>;
                print('First dog data: $firstDog');
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: dogs.length,
                itemBuilder: (context, index) {
                  final dog = dogs[index].data() as Map<String, dynamic>;

                  return BlocListener<DogBloc, DogState>(
                    listener: (context, state) {
                      if (state is DogDeleted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Dog deleted successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else if (state is DogError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: ${state.message}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 16),
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
                                    child: dog['imageUrl'] != null && dog['imageUrl'].toString().isNotEmpty
                                      ? Image.network(
                                          dog['imageUrl'].toString(),
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
                                            print('Image error: $error');
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
                                        )
                                      : Center(
                                          child: Icon(
                                            Icons.photo_library,
                                            size: 40,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _showDeleteConfirmation(
                                        context,
                                        dogs[index].id,
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
                                  dog['name'] ?? 'Unnamed',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  dog['breed'] ?? 'Unknown breed',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Gender and Size Row
                                Row(
                                  children: [
                                    Icon(
                                      dog['gender'] == 'Male' ? Icons.male : Icons.female,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      dog['gender'] ?? 'Unknown',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                    const SizedBox(width: 16),
                                    Icon(
                                      Icons.straighten,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      dog['size'] ?? 'Unknown size',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),
                                // View Details Button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () => _showDogDetails(context, dog),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('View Details'),
                                  ),
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
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AddDogScreen(),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }




  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'adopted':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'available':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
