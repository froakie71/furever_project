import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user_donations.dart';
import 'package:intl/intl.dart';

class DonationDetailsScreen extends StatelessWidget {
  final UserDonations userDonations;

  const DonationDetailsScreen({super.key, required this.userDonations});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Donation History'),
        backgroundColor: const Color(0xFF32649B),
      ),
      body: Column(
        children: [
          // Donator info card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    userDonations.userEmail,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total Donations: ₱${NumberFormat('#,##0.00').format(userDonations.totalAmount)}',
                    style: const TextStyle(
                      fontSize: 20,
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
                  child: ListTile(
                    title: Text(
                      '₱${NumberFormat('#,##0.00').format(double.parse(donation.amount))}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF32649B),
                      ),
                    ),
                    subtitle: Text(
                      DateFormat('MMMM dd, yyyy').format(donation.date),
                    ),
                    trailing:
                        donation.imageUrl.isNotEmpty
                            ? IconButton(
                              icon: const Icon(Icons.image),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder:
                                      (context) => Dialog(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Image.network(
                                              donation.imageUrl,
                                              fit: BoxFit.cover,
                                            ),
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(context),
                                              child: const Text('Close'),
                                            ),
                                          ],
                                        ),
                                      ),
                                );
                              },
                            )
                            : null,
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
