import 'package:flutter/material.dart';
import 'package:flutter_application_1_user/views/screens/adopted_dogs_screen.dart';
import 'package:flutter_application_1_user/views/screens/dog_screen.dart';
import 'package:flutter_application_1_user/views/screens/donation_details_screen.dart';
import 'package:flutter_application_1_user/views/screens/event_screen.dart';
import 'package:flutter_application_1_user/views/screens/home_screen.dart';
import 'package:flutter_application_1_user/views/screens/merch_screen.dart';
import 'package:flutter_application_1_user/views/widgets/shared_drawer.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    return Column(
      children: [
        // Top 5 Donators Container
        Container(
          padding: const EdgeInsets.all(25),
          color: Colors.orange.shade50,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Top 5 Donators 🏆',
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
                itemCount: topDonators.length > 5 ? 5 : topDonators.length,
                itemBuilder: (context, index) {
                  final donator = topDonators[index];
                  return _buildDonatorCard(donator, index, true);
                },
              ),
            ],
          ),
        ),

        // All Donators Section
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'All Donators',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('donations')
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // Group donations by user and calculate totals
                    Map<String, Map<String, dynamic>> userDonations = {};

                    for (var doc in snapshot.data!.docs) {
                      final data = doc.data() as Map<String, dynamic>;
                      final userId = data['userId'] as String;
                      final amount = (data['amount'] as num).toDouble();
                      final email =
                          data['userEmail'] as String? ??
                          'Anonymous'; // Changed from email to userEmail

                      if (!userDonations.containsKey(userId)) {
                        userDonations[userId] = {
                          'email': email,
                          'total': amount,
                          'userId': userId,
                        };
                      } else {
                        userDonations[userId]!['total'] =
                            (userDonations[userId]!['total'] as double) +
                            amount;
                      }
                    }

                    // Convert to list and sort
                    final sortedDonators =
                        userDonations.values.toList()..sort(
                          (a, b) => (b['total'] as double).compareTo(
                            a['total'] as double,
                          ),
                        );

                    return sortedDonators.isEmpty
                        ? const Center(
                          child: Text(
                            'No donations yet',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                        : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: sortedDonators.length,
                          itemBuilder: (context, index) {
                            final donator = sortedDonators[index];
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: Colors.grey.shade100,
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: Colors.grey.shade800,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                donator['email'] as String,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                '₱${(donator['total'] as double).toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          },
                        );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDonatorCard(
    Map<String, dynamic> donator,
    int index,
    bool isTopFive,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape:
          isTopFive
              ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.orange.shade300, width: 2),
              )
              : null,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor:
              isTopFive ? Colors.orange.shade100 : Colors.grey.shade100,
          child: Text(
            '${index + 1}',
            style: TextStyle(
              color: isTopFive ? Colors.orange.shade800 : Colors.grey.shade800,
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
            if (isTopFive) _getBadge(index),
            if (isTopFive) const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () {
          if (isTopFive) {
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
              _donationBloc
                ..add(LoadDonations())
                ..add(LoadTopDonators());
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Only top 5 donors can view detailed donation history',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.orange,
              ),
            );
          }
        },
      ),
    );
  }

  void _showDonatorDetails(BuildContext context, Map<String, dynamic> donator) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                // Donor info header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        donator['email'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF32649B),
                        ),
                      ),
                      Text(
                        'Total Donations: ₱${donator['total'].toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                // Donation history
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream:
                        FirebaseFirestore.instance
                            .collection('donations')
                            .where('userId', isEqualTo: donator['userId'])
                            .orderBy('timestamp', descending: true)
                            .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final donations = snapshot.data!.docs;

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: donations.length,
                        itemBuilder: (context, index) {
                          final donation =
                              donations[index].data() as Map<String, dynamic>;
                          final timestamp = donation['timestamp'] as Timestamp;
                          final date = timestamp.toDate();

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.payments_outlined,
                                  color: Colors.orange.shade800,
                                ),
                              ),
                              title: Text(
                                '₱${donation['amount'].toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                DateFormat(
                                  'MMM dd, yyyy - hh:mm a',
                                ).format(date),
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              trailing:
                                  donation['proofUrl'] != null
                                      ? IconButton(
                                        icon: const Icon(Icons.image),
                                        onPressed: () {
                                          // Show proof of donation image
                                          showDialog(
                                            context: context,
                                            builder:
                                                (context) => Dialog(
                                                  child: Container(
                                                    width: 300,
                                                    height: 300,
                                                    decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                        image: NetworkImage(
                                                          donation['proofUrl'],
                                                        ),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                          );
                                        },
                                      )
                                      : null,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _showNotTopFiveMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Only top 5 donors can view detailed donation history',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
