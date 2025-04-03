import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
                  validator: (value) =>
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
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter an amount' : null,
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
    return BlocProvider(
      create: (context) => DonatorBloc(),
      child: BlocListener<DonatorBloc, DonatorState>(
        listener: (context, state) {
          if (state is DonatorSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Donator added successfully')),
            );
          } else if (state is DonatorError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Top Donators'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                final donators = [
                  {
                    'name': 'Maria Santos',
                    'amount': '₱50,000',
                    'icon': Icons.star
                  },
                  {
                    'name': 'John Smith',
                    'amount': '₱35,000',
                    'icon': Icons.person_outline
                  },
                  {
                    'name': 'Anna Garcia',
                    'amount': '₱25,000',
                    'icon': Icons.volunteer_activism
                  },
                  {
                    'name': 'Luis Cruz',
                    'amount': '₱20,000',
                    'icon': Icons.thumb_up
                  },
                  {
                    'name': 'Sarah Lee',
                    'amount': '₱18,000',
                    'icon': Icons.favorite
                  },
                ];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
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
                      donators[index]['name'].toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      donators[index]['amount'].toString(),
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: Icon(
                      donators[index]['icon'] as IconData,
                      color: Colors.orange,
                    ),
                  ),
                );
              },
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddDonatorDialog(context),
            backgroundColor: Colors.orange,
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
