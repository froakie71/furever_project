// ignore_for_file: avoid_types_as_parameter_names

import 'package:flutter/material.dart';
import 'package:flutter_application_1/views/screens/Donations/donation_details_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'bloc/donator_bloc.dart';
import 'bloc/donator_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TopDonatorsScreen extends StatelessWidget {
  const TopDonatorsScreen({super.key});

  Future<String> _getUsernameFromId(String userId) async {
    try {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();

      if (userDoc.exists) {
        final userData = userDoc.data();
        // First try to get username
        final username = userData?['username'] as String?;
        if (username != null && username.isNotEmpty) {
          return username;
        }
        // If no username, use email without domain
        final email = userData?['email'] as String?;
        if (email != null && email.isNotEmpty) {
          return email.split('@')[0];
        }
      }
      return 'Anonymous';
    } catch (e) {
      debugPrint('Error fetching username: $e');
      return 'Anonymous';
    }
  }



  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DonatorBloc, DonatorState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Top 5 Donators'),
            backgroundColor: const Color(0xFF32649B),
          ),
          body: Column(
            children: [
              // Total all donations card
              if (state is DonatorSuccess)
                Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          'Total Donations',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₱${NumberFormat('#,##0.00').format(state.userDonations.fold(0.0, (sum, user) => sum + user.totalAmount))}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF32649B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Top 5 Users list
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (state is DonatorLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is DonatorError) {
                      return Center(child: Text(state.message));
                    }
                    if (state is DonatorSuccess) {
                      // Sort by total amount and take top 5
                      final topDonators =
                          List.from(state.userDonations)
                            ..sort(
                              (a, b) => b.totalAmount.compareTo(a.totalAmount),
                            )
                            ..take(5);

                      return ListView.builder(
                        itemCount:
                            topDonators.length > 5 ? 5 : topDonators.length,
                        itemBuilder: (context, index) {
                          final userDonation = topDonators[index];

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: FutureBuilder<String>(
                              future: _getUsernameFromId(userDonation.userId),
                              builder: (context, snapshot) {
                                final username = snapshot.data ?? 'Loading...';

                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: _getLeaderColor(index),
                                    child: _getLeaderIcon(index),
                                  ),
                                  title: Text(
                                    username,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${userDonation.donations.length} donations',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  trailing: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '₱${NumberFormat('#,##0.00').format(userDonation.totalAmount)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF32649B),
                                        ),
                                      ),
                                      Text(
                                        'Rank #${index + 1}',
                                        style: TextStyle(
                                          color: _getLeaderColor(index),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => DonationDetailsScreen(
                                              userDonations: userDonation,
                                            ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          );
                        },
                      );
                    }
                    return const Center(child: Text('No donations yet'));
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getLeaderColor(int index) {
    switch (index) {
      case 0:
        return Colors.amber; // Gold
      case 1:
        return Colors.grey[400]!; // Silver
      case 2:
        return Colors.brown[300]!; // Bronze
      default:
        return Colors.blue[100]!;
    }
  }

  Widget _getLeaderIcon(int index) {
    switch (index) {
      case 0:
        return const Icon(Icons.emoji_events, color: Colors.white);
      case 1:
        return const Icon(Icons.workspace_premium, color: Colors.white);
      case 2:
        return const Icon(Icons.military_tech, color: Colors.white);
      default:
        return Text(
          '${index + 1}',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        );
    }
  }
}
