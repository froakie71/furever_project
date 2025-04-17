import 'package:flutter/material.dart';
import 'package:flutter_application_1/views/screens/ProcessAdoption/bloc/adoption_bloc.dart';
import 'package:flutter_application_1/views/screens/ProcessAdoption/bloc/adoption_event.dart';
import 'package:flutter_application_1/views/screens/ProcessAdoption/bloc/adoption_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/shared_drawer.dart';

class ProcessAdoptionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Process Adoptions'),
        backgroundColor: const Color(0xFF32649B),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('adoptions')
                .where('status', isEqualTo: 'pending')
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final adoptions = snapshot.data?.docs ?? [];

          if (adoptions.isEmpty) {
            return const Center(child: Text('No pending adoptions'));
          }

          return ListView.builder(
            itemCount: adoptions.length,
            itemBuilder: (context, index) {
              final adoption = adoptions[index].data() as Map<String, dynamic>;
              final adoptionId = adoptions[index].id;
              final dogId = adoption['dogId'] as String;
              final userId = adoption['userId'] as String;

              return FutureBuilder<DocumentSnapshot>(
                future:
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const Card(
                      child: ListTile(title: Text('Loading user data...')),
                    );
                  }

                  final userData =
                      userSnapshot.data?.data() as Map<String, dynamic>?;

                  return FutureBuilder<DocumentSnapshot>(
                    future:
                        FirebaseFirestore.instance
                            .collection('dogs')
                            .doc(dogId)
                            .get(),
                    builder: (context, dogSnapshot) {
                      if (!dogSnapshot.hasData) {
                        return const Card(
                          child: ListTile(title: Text('Loading dog data...')),
                        );
                      }

                      final dogData =
                          dogSnapshot.data?.data() as Map<String, dynamic>?;

                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Dog Image
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      dogData?['imageUrl'] ?? '',
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (_, __, ___) => Container(
                                            width: 100,
                                            height: 100,
                                            color: Colors.grey[300],
                                            child: const Icon(Icons.pets),
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Dog and User Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          dogData?['name'] ?? 'Unknown Dog',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Breed: ${dogData?['breed'] ?? 'Unknown'}',
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Adopter Information:',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'Name: ${userData?['fullName'] ?? 'Unknown'}',
                                        ),
                                        Text(
                                          'Email: ${userData?['email'] ?? 'Unknown'}',
                                        ),
                                        Text(
                                          'Phone: ${userData?['phone'] ?? 'Unknown'}',
                                        ),
                                        Text(
                                          'Submitted: ${_formatDate(adoption['submittedAt'])}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed:
                                        () => _handleAdoptionDecision(
                                          context,
                                          adoptionId,
                                          dogId,
                                          true,
                                        ),
                                    child: const Text(
                                      'Decline',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  ElevatedButton(
                                    onPressed:
                                        () => _handleAdoptionDecision(
                                          context,
                                          adoptionId,
                                          dogId,
                                          false,
                                        ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                    ),
                                    child: const Text(
                                      'Approve',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Unknown date';
    if (date is Timestamp) {
      final DateTime dateTime = date.toDate();
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    }
    return 'Invalid date';
  }

  void _handleAdoptionDecision(
    BuildContext context,
    String adoptionId,
    String dogId,
    bool isDeclined,
  ) async {
    try {
      // Create an overlay entry for the loading indicator
      OverlayState? overlay = Overlay.of(context);
      OverlayEntry? loadingOverlay;

      loadingOverlay = OverlayEntry(
        builder:
            (context) => Material(
              color: Colors.black54,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const CircularProgressIndicator(),
                ),
              ),
            ),
      );

      // Show loading overlay
      overlay.insert(loadingOverlay);

      // Get adoption document to fetch userId and dogName
      final adoptionDoc =
          await FirebaseFirestore.instance
              .collection('adoptions')
              .doc(adoptionId)
              .get();
      final adoptionData = adoptionDoc.data() as Map<String, dynamic>;
      final userId = adoptionData['userId'];
      final dogDoc =
          await FirebaseFirestore.instance.collection('dogs').doc(dogId).get();
      final dogData = dogDoc.data() as Map<String, dynamic>;
      final dogName = dogData['name'] ?? 'the dog';
      final dogImage = dogData['imageUrl'] ?? null;

      // Add adoption status update event
      context.read<AdoptionBloc>().add(
        UpdateAdoptionStatus(
          adoptionId: adoptionId,
          dogId: dogId,
          isDeclined: isDeclined,
        ),
      );

      // Listen for state changes
      await for (final state in context.read<AdoptionBloc>().stream) {
        if (state is AdoptionSuccess) {
          // Create notification for the user
          await FirebaseFirestore.instance.collection('notifications').add({
            'userId': userId,
            'dogName': dogName,
            'dogImage': dogImage, // <-- Add this line
            'message':
                isDeclined
                    ? 'Your adoption request for $dogName was declined.'
                    : 'Your adoption request for $dogName was approved!',
            'timestamp': FieldValue.serverTimestamp(),
            'isRead': false,
            'type': 'adoption',
            'status': isDeclined ? 'declined' : 'approved',
          });

          loadingOverlay.remove();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isDeclined
                      ? 'Adoption declined successfully'
                      : 'Adoption approved successfully',
                ),
                backgroundColor: isDeclined ? Colors.red : Colors.green,
              ),
            );
          }
          break;
        } else if (state is AdoptionError) {
          loadingOverlay.remove();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
          break;
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error processing adoption: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
