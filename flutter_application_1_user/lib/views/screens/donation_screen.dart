import 'package:flutter/material.dart';
import 'package:flutter_application_1_user/views/screens/adopted_dogs_screen.dart';
import 'package:flutter_application_1_user/views/screens/dog_screen.dart';
import 'package:flutter_application_1_user/views/screens/donation_details_screen.dart';
import 'package:flutter_application_1_user/views/screens/event_screen.dart';
import 'package:flutter_application_1_user/views/screens/home_screen.dart';
import 'package:flutter_application_1_user/views/screens/merch_screen.dart';
import 'package:flutter_application_1_user/views/widgets/shared_drawer.dart';
import 'package:intl/intl.dart';
import 'medical_services_screen.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/donation/donation_bloc.dart';
import '../../bloc/donation/donation_event.dart';
import '../../bloc/donation/donation_state.dart';

class DonationScreen extends StatefulWidget {
  const DonationScreen({super.key});

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final _amountController = TextEditingController();
  late final DonationBloc _donationBloc;

  @override
  void initState() {
    super.initState();
    _donationBloc = context.read<DonationBloc>();
    // Load initial states
    _donationBloc
      ..add(LoadDonations())
      ..add(LoadTopDonators());
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: const Color(0xFF32649B),
        automaticallyImplyLeading: false,
        title: InkWell(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
          child: Image.asset('assets/images/Furever_logo.png', height: 80),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(
              right: 16.0,
            ), // Adjust the value as needed
            child: IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                _scaffoldKey.currentState?.openEndDrawer();
              },
            ),
          ),
        ],
      ),
      endDrawer: SharedDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          _donationBloc
            ..add(LoadDonations())
            ..add(LoadTopDonators());
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              BlocBuilder<DonationBloc, DonationState>(
                builder: (context, state) {
                  // Top Donators Section
                  if (state is TopDonatorsLoaded) {
                    return _buildTopDonators(state.topDonators);
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 16),
              // Donation Form Section
              BlocBuilder<DonationBloc, DonationState>(
                builder: (context, state) {
                  return _buildDonationForm(context, state);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDonationSummary(DonationSuccess state) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            'Total Donations: ₱${state.totalAmount.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Number of donations: ${state.userDonations.length}',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationForm(BuildContext context, DonationState state) {
    return Container(
      alignment: Alignment.center,
      width: 350,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 133, 192, 255),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Make a Donation',
              style: TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child:
                        _imageFile != null
                            ? ClipOval(
                              child: Image.file(
                                _imageFile!,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            )
                            : const Icon(
                              Icons.pets,
                              size: 50,
                              color: Colors.grey,
                            ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: InkWell(
                        onTap: _pickImage,
                        child: const Icon(
                          Icons.add_a_photo,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Text(
                  '₱',
                  style: TextStyle(fontSize: 20, color: Color(0xFF32649B)),
                ),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter amount';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    context.read<DonationBloc>().add(
                      SubmitDonation(
                        amount: double.parse(_amountController.text),
                        imageFile: _imageFile,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF32649B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  state is DonationSuccess && state.userDonations.isNotEmpty
                      ? 'Donate Again'
                      : 'Submit Donation',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTopDonator(int index) {
    final donators = [
      'Maria Santos',
      'John Smith',
      'Anna Garcia',
      'Luis Cruz',
      'Sarah Lee',
    ];
    return donators[index];
  }

  String _getDonationAmount(int index) {
    final amounts = ['₱50,000', '₱35,000', '₱25,000', '₱20,000', '₱18,000'];
    return amounts[index];
  }

  Widget _getBadge(int index) {
    final badges = [
      {'icon': Icons.stars, 'color': Colors.amber},
      {'icon': Icons.workspace_premium, 'color': Colors.grey},
      {'icon': Icons.volunteer_activism, 'color': Colors.brown},
      {'icon': Icons.thumb_up, 'color': Colors.blue},
      {'icon': Icons.favorite, 'color': Colors.pink},
    ];

    return Icon(
      badges[index]['icon'] as IconData,
      color: badges[index]['color'] as Color,
    );
  }

  Widget _buildTopDonators(List<Map<String, dynamic>> topDonators) {
    return Container(
      padding: const EdgeInsets.all(25),
      color: Colors.orange.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Top Donators 📈',
            style: TextStyle(
              color: Color.fromARGB(255, 255, 133, 33),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: topDonators.length,
            itemBuilder: (context, index) {
              final donator = topDonators[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange.shade100,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    donator['email'] ?? 'Anonymous',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '₱${donator['total'].toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _getBadge(index),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => BlocProvider.value(
                              value: _donationBloc,
                              child: DonationDetailsScreen(
                                userId: donator['userId'],
                                email: donator['email'],
                                totalAmount: donator['total'],
                              ),
                            ),
                      ),
                    ).then((_) {
                      // Refresh states after navigation completes
                      _donationBloc
                        ..add(LoadDonations())
                        ..add(LoadTopDonators());
                    });
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
