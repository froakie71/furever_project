import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1_user/widgets/shared_drawer.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';

class DonationScreen extends StatefulWidget {
  const DonationScreen({super.key});

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _uploadImage() async {
    try {
      final permissionStatus = await Permission.storage.request();

      if (permissionStatus.isGranted) {
        final XFile? pickedFile = await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1800,
          maxHeight: 1800,
        );

        if (pickedFile != null) {
          setState(() {
            _image = File(pickedFile.path);
          });
        }
      } else {
        throw Exception('Storage permission denied');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar(e.toString());
    }
  }

  Future<void> _submitDonation() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showErrorSnackBar('Please sign in to make a donation');
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? receiptUrl;
      if (_image != null) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final ref = FirebaseStorage.instance.ref().child(
          'donation_receipts/${user.uid}_$timestamp.jpg',
        );

        await ref.putFile(_image!);
        receiptUrl = await ref.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('donations').add({
        'userId': user.uid,
        'userEmail': user.email,
        'amount': double.parse(_amountController.text),
        'receiptUrl': receiptUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Donation submitted successfully!')),
        );
        _amountController.clear();
        setState(() => _image = null);
      }
    } catch (e) {
      _showErrorSnackBar('Error submitting donation: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer:  SharedDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFF32649B),
        title: const Text('Donate'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Donators Section with StreamBuilder
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.orange.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Top Donators',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF32649B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  StreamBuilder<QuerySnapshot>(
                    stream:
                        FirebaseFirestore.instance
                            .collection('donations')
                            .where('status', isEqualTo: 'approved')
                            .orderBy('amount', descending: true)
                            .limit(5)
                            .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final donations = snapshot.data?.docs ?? [];

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: donations.length,
                        itemBuilder: (context, index) {
                          final donation =
                              donations[index].data() as Map<String, dynamic>;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
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
                              title: Text(donation['userEmail'] ?? 'Anonymous'),
                              subtitle: Text(
                                NumberFormat.currency(
                                  symbol: '₱',
                                  decimalDigits: 2,
                                ).format(donation['amount'] ?? 0),
                              ),
                              trailing: _getBadge(index),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            // Donation Form
            Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Make a Donation',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF32649B),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // ... Rest of your existing form UI with updated styles
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF32649B),
                                width: 2,
                              ),
                            ),
                            child:
                                _image != null
                                    ? ClipOval(
                                      child: Image.file(
                                        _image!,
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                    : const Icon(
                                      Icons.receipt_long,
                                      size: 50,
                                      color: Color(0xFF32649B),
                                    ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              backgroundColor: const Color.fromARGB(
                                255,
                                240,
                                163,
                                47,
                              ),
                              radius: 18,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.add_a_photo,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                onPressed: _uploadImage,
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
                        prefixIcon: const Icon(
                          Icons.attach_money,
                          color: Color(0xFF32649B),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF32649B),
                            width: 2,
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter amount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid amount';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitDonation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            240,
                            163,
                            47,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child:
                            _isLoading
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : const Text(
                                  'Submit Donation',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Keep your existing helper methods
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
}
