import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'bloc/donation_bloc.dart';
import 'bloc/donation_event.dart';
import 'bloc/donation_state.dart';
import 'donation_details_screen.dart';

class DonationListScreen extends StatelessWidget {
  const DonationListScreen({super.key});

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
    return BlocProvider(
      create: (context) => DonationBloc()..add(LoadDonations()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Donation List'),
          backgroundColor: const Color(0xFF32649B),
        ),
        body: BlocBuilder<DonationBloc, DonationState>(
          builder: (context, state) {
            if (state is DonationLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is DonationError) {
              return Center(child: Text(state.message));
            }
            if (state is DonationSuccess) {
              return ListView.builder(
                itemCount: state.donations.length,
                itemBuilder: (context, index) {
                  final donation = state.donations[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: FutureBuilder<String>(
                      future: _getUsernameFromId(donation.userId),
                      builder: (context, snapshot) {
                        final username = snapshot.data ?? 'Loading...';
                        return ListTile(
                          title: Text(
                            username,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Total Donations: ₱${NumberFormat('#,##0.00').format(donation.totalAmount)}',
                          ),
                          trailing: Text(
                            '${donation.donations.length} donations',
                            style: const TextStyle(color: Color(0xFF32649B)),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => DonationDetailsScreen(
                                      userDonations: donation,
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
            return const Center(child: Text('No donations found'));
          },
        ),
      ),
    );
  }
}
