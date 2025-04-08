import 'package:flutter/material.dart';
import 'package:flutter_application_1/views/screens/Donations/donation_details_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'bloc/donator_bloc.dart';
import 'bloc/donator_event.dart';
import 'bloc/donator_state.dart';

class TopDonatorsScreen extends StatelessWidget {
  const TopDonatorsScreen({super.key});

  void _showAddDonatorDialog(BuildContext context) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Donator'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  validator:
                      (value) =>
                          value?.isEmpty ?? true ? 'Please enter a name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixText: '₱',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator:
                      (value) =>
                          value?.isEmpty ?? true
                              ? 'Please enter an amount'
                              : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  context.read<DonatorBloc>().add(
                    AddDonator(
                      name: nameController.text,
                      amount: amountController.text,
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DonatorBloc, DonatorState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Donations Summary'),
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
                          'Total All Donations',
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

              // Users list
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
                      return ListView.builder(
                        itemCount: state.userDonations.length,
                        itemBuilder: (context, index) {
                          final userDonation = state.userDonations[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFFFFE0B2),
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                userDonation.userEmail,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${userDonation.donations.length} donations',
                                style: const TextStyle(color: Colors.grey),
                              ),
                              trailing: Text(
                                '₱${NumberFormat('#,##0.00').format(userDonation.totalAmount)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF32649B),
                                ),
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
}
