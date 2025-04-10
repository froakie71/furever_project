import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'bloc/donation_bloc.dart';
import 'bloc/donation_event.dart';
import 'bloc/donation_state.dart';
import 'donation_details_screen.dart';

class DonationListScreen extends StatelessWidget {
  const DonationListScreen({super.key});

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
                    child: ListTile(
                      title: Text(
                        donation.userEmail,
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
