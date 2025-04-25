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
  bool _isPickingImage = false; // Add this flag

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
    if (_isPickingImage) return; // Prevent multiple calls
    setState(() {
      _isPickingImage = true;
    });
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } finally {
      setState(() {
        _isPickingImage = false;
      });
    }
  }

  Future<String> _getUserDisplayName(String userId) async {
    try {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();

      if (userDoc.exists && userDoc.data() != null) {
        final userData = userDoc.data()!;
        // First try to get username
        final username = userData['username'] as String?;
        if (username != null && username.isNotEmpty) {
          return username;
        }
        // If no username, use email
        final email = userData['email'] as String?;
        if (email != null && email.isNotEmpty) {
          return email;
        }
      }
      return 'Anonymous';
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      return 'Anonymous';
    }
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
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('donations').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        Map<String, Map<String, dynamic>> userDonations = {};

        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final userId = data['userId'] as String;
          final amount = (data['amount'] as num).toDouble();

          if (!userDonations.containsKey(userId)) {
            userDonations[userId] = {'userId': userId, 'total': amount};
          } else {
            userDonations[userId]!['total'] += amount;
          }
        }

        final sortedDonators =
            userDonations.values.toList()..sort(
              (a, b) => (b['total'] as double).compareTo(a['total'] as double),
            );

        return Column(
          children: [
            // Top 5 Section
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.orange.shade50,
              child: Column(
                children: [
                  const Text(
                    'Top 5 Donators 🏆',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 255, 133, 33),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount:
                        sortedDonators.length > 5 ? 5 : sortedDonators.length,
                    itemBuilder: (context, index) {
                      final donator = sortedDonators[index];
                      return FutureBuilder<String>(
                        future: _getUsernameFromId(donator['userId']),
                        builder: (context, usernameSnapshot) {
                          final username =
                              usernameSnapshot.data ?? 'Loading...';

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
                            trailing: Text(
                              '₱${(donator['total'] as double).toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () => _showDonatorDetails(context, donator),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            // All Donators Section
            Container(
              margin: const EdgeInsets.all(16),
              height: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'All Donators (${sortedDonators.length})',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: sortedDonators.length,
                      itemBuilder: (context, index) {
                        final donator = sortedDonators[index];
                        return FutureBuilder<String>(
                          future: _getUsernameFromId(donator['userId']),
                          builder: (context, usernameSnapshot) {
                            final username =
                                usernameSnapshot.data ?? 'Loading...';

                            return ListTile(
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
                              title: Text(username),
                              trailing: Text(
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
      },
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
                // Donor info header with profile image
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Add profile image
                      StreamBuilder<DocumentSnapshot>(
                        stream:
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(donator['userId'])
                                .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData &&
                              snapshot.data?.data() != null) {
                            final userData =
                                snapshot.data!.data() as Map<String, dynamic>;
                            return Column(
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Colors.grey[200],
                                  backgroundImage:
                                      userData['profileImage'] != null
                                          ? NetworkImage(
                                            userData['profileImage'],
                                          )
                                          : null,
                                  child:
                                      userData['profileImage'] == null
                                          ? const Icon(
                                            Icons.person,
                                            size: 40,
                                            color: Colors.grey,
                                          )
                                          : null,
                                ),
                                const SizedBox(height: 8),
                                FutureBuilder<String>(
                                  future: _getUserDisplayName(
                                    donator['userId'],
                                  ),
                                  builder: (context, snapshot) {
                                    final displayName =
                                        snapshot.data ?? 'Loading...';
                                    return Text(
                                      displayName,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF32649B),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            );
                          }
                          return Column(
                            children: [
                              const CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.grey,
                                child: Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              FutureBuilder<String>(
                                future: _getUserDisplayName(donator['userId']),
                                builder: (context, snapshot) {
                                  final displayName =
                                      snapshot.data ?? 'Loading...';
                                  return Text(
                                    displayName,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF32649B),
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 8),
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
                // Rest of the donation history section remains the same...
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    // Remove the orderBy to avoid requiring an index
                    stream:
                        FirebaseFirestore.instance
                            .collection('donations')
                            .where('userId', isEqualTo: donator['userId'])
                            .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text('No donation history available'),
                        );
                      }

                      final donations = snapshot.data!.docs;
                      donations.sort((a, b) {
                        final timestampA =
                            (a.data() as Map<String, dynamic>)['timestamp']
                                as Timestamp;
                        final timestampB =
                            (b.data() as Map<String, dynamic>)['timestamp']
                                as Timestamp;
                        return timestampB.compareTo(
                          timestampA,
                        ); // Sort descending
                      });

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: donations.length,
                        itemBuilder: (context, index) {
                          final donation =
                              donations[index].data() as Map<String, dynamic>;
                          final timestamp = donation['timestamp'] as Timestamp;
                          final date = timestamp.toDate();
                          final proofUrl =
                              donation['imageUrl']
                                  as String?; // Changed from proofImageUrl to imageUrl

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
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
                                ),
                                if (proofUrl != null &&
                                    proofUrl.isNotEmpty) ...[
                                  const Divider(),
                                  Container(
                                    width: double.infinity,
                                    height: 300,
                                    margin: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.shade200,
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        proofUrl,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (
                                          context,
                                          child,
                                          loadingProgress,
                                        ) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value:
                                                  loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                      : null,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ],
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

  // Add this helper method to show proof images
  void _showProofImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
    );
  }

  // Add this method to show full-screen image:
  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.zero,
            child: Stack(
              fit: StackFit.loose,
              children: [
                InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value:
                              loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Future<String> _getUsernameFromId(String userId) async {
    try {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();

      if (userDoc.exists && userDoc.data() != null) {
        final userData = userDoc.data()!;
        // First try to get username
        final username = userData['username'] as String?;
        if (username != null && username.isNotEmpty) {
          return username;
        }
        // Then try email
        final email = userData['email'] as String?;
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
}
