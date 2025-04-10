import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/user_donations.dart';

class DonationDetailsScreen extends StatelessWidget {
  final UserDonations userDonations;

  const DonationDetailsScreen({super.key, required this.userDonations});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Donation History - ${userDonations.userEmail}'),
        backgroundColor: const Color(0xFF32649B),
      ),
      body: Column(
        children: [
          // Total donations card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Total Donations',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₱${NumberFormat('#,##0.00').format(userDonations.totalAmount)}',
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

          // Donation history list
          Expanded(
            child: ListView.builder(
              itemCount: userDonations.donations.length,
              itemBuilder: (context, index) {
                final donation = userDonations.donations[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          '₱${NumberFormat('#,##0.00').format(double.parse(donation.amount))}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF32649B),
                          ),
                        ),
                        subtitle: Text(
                          'Donated on: ${DateFormat('MMM dd, yyyy').format(donation.date)}',
                        ),
                      ),
                      if (donation.imageUrl.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Image.network(
                            donation.imageUrl,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
