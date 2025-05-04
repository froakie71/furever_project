import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../bloc/donation/donation_bloc.dart';
import '../../bloc/donation/donation_event.dart';
import '../../bloc/donation/donation_state.dart';

class DonationDetailsScreen extends StatefulWidget {
  final String userId;
  final String email;
  final double totalAmount;

  const DonationDetailsScreen({
    super.key,
    required this.userId,
    required this.email,
    required this.totalAmount,
  });

  @override
  State<DonationDetailsScreen> createState() => _DonationDetailsScreenState();
}

class _DonationDetailsScreenState extends State<DonationDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DonationBloc>().add(
      LoadDonatorDetails(userId: widget.userId, email: widget.email),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donation History'),
        backgroundColor: const Color(0xFF32649B),
      ),
      body: Column(
        children: [
          // Donator info card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  widget.email,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Total Donations: ₱${widget.totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Donation history list
          Expanded(
            child: BlocBuilder<DonationBloc, DonationState>(
              builder: (context, state) {
                if (state is DonationLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is DonatorDetailsLoaded) {
                  if (state.donations.isEmpty) {
                    return const Center(
                      child: Text('No donation history available'),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.donations.length,
                    itemBuilder: (context, index) {
                      final donation = state.donations[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          children: [
                            if (donation['imageUrl'] != null)
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(8),
                                ),
                                child: Image.network(
                                  donation['imageUrl'],
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 200,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.error),
                                    );
                                  },
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '₱${donation['amount'].toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF32649B),
                                        ),
                                      ),
                                      Text(
                                        DateFormat(
                                          'MMM dd, yyyy hh:mm a',
                                        ).format(donation['timestamp']),
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }

                return const Center(child: Text('Something went wrong'));
              },
            ),
          ),
        ],
      ),
    );
  }
}
