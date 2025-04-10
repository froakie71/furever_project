import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdoptedDogsScreen extends StatelessWidget {
  const AdoptedDogsScreen({super.key});

  void _showDogDetailsModal(
    BuildContext context,
    Map<String, dynamic> adoptionData,
  ) {
    final adoptionDate = (adoptionData['submittedAt'] as Timestamp).toDate();

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
                // Dog Image
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(25),
                  ),
                  child: Image.network(
                    adoptionData['dogImageUrl'],
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          height: 250,
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.pets,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Dog Name and Status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              adoptionData['dogName'],
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    size: 16,
                                    color: Colors.green,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Adopted',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Adopter Information Section
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Adopter Information',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ListTile(
                                leading: const Icon(
                                  Icons.email,
                                  color: Colors.orange,
                                ),
                                title: const Text('Email'),
                                subtitle: Text(adoptionData['userEmail']),
                                contentPadding: EdgeInsets.zero,
                              ),
                              ListTile(
                                leading: const Icon(
                                  Icons.calendar_today,
                                  color: Colors.orange,
                                ),
                                title: const Text('Adoption Date'),
                                subtitle: Text(
                                  DateFormat(
                                    'MMMM dd, yyyy',
                                  ).format(adoptionDate),
                                ),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Dog Details Section - Enhanced
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.orange.shade200,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.pets,
                                    color: Colors.orange.shade700,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Dog Information',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              // Basic Information
                              if (adoptionData['dogBreed'] != null)
                                ListTile(
                                  leading: const Icon(
                                    Icons.pets,
                                    color: Colors.grey,
                                  ),
                                  title: const Text('Breed'),
                                  subtitle: Text(adoptionData['dogBreed']),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              if (adoptionData['dogAge'] != null)
                                ListTile(
                                  leading: const Icon(
                                    Icons.cake,
                                    color: Colors.grey,
                                  ),
                                  title: const Text('Age'),
                                  subtitle: Text(
                                    '${adoptionData['dogAge']} years old',
                                  ),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              if (adoptionData['dogHeight'] != null)
                                ListTile(
                                  leading: const Icon(
                                    Icons.height,
                                    color: Colors.grey,
                                  ),
                                  title: const Text('Height'),
                                  subtitle: Text(
                                    '${adoptionData['dogHeight']} cm',
                                  ),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              if (adoptionData['dogWeight'] != null)
                                ListTile(
                                  leading: const Icon(
                                    Icons.monitor_weight,
                                    color: Colors.grey,
                                  ),
                                  title: const Text('Weight'),
                                  subtitle: Text(
                                    '${adoptionData['dogWeight']} kg',
                                  ),
                                  contentPadding: EdgeInsets.zero,
                                ),

                              // Medical Records Section
                              if (adoptionData['medicalRecords'] != null) ...[
                                const Divider(height: 30),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.medical_services,
                                      color: Colors.orange.shade700,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Medical Records',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (adoptionData['medicalRecords']['vaccinations'] !=
                                          null)
                                        ListTile(
                                          leading: const Icon(
                                            Icons.vaccines,
                                            color: Colors.blue,
                                          ),
                                          title: const Text('Vaccinations'),
                                          subtitle: Text(
                                            adoptionData['medicalRecords']['vaccinations']
                                                .join(', '),
                                          ),
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                      if (adoptionData['medicalRecords']['lastCheckup'] !=
                                          null)
                                        ListTile(
                                          leading: const Icon(
                                            Icons.calendar_today,
                                            color: Colors.blue,
                                          ),
                                          title: const Text('Last Checkup'),
                                          subtitle: Text(
                                            DateFormat('MMMM dd, yyyy').format(
                                              (adoptionData['medicalRecords']['lastCheckup']
                                                      as Timestamp)
                                                  .toDate(),
                                            ),
                                          ),
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                      if (adoptionData['medicalRecords']['conditions'] !=
                                          null)
                                        ListTile(
                                          leading: const Icon(
                                            Icons.medical_information,
                                            color: Colors.blue,
                                          ),
                                          title: const Text(
                                            'Medical Conditions',
                                          ),
                                          subtitle: Text(
                                            adoptionData['medicalRecords']['conditions']
                                                .join(', '),
                                          ),
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                      if (adoptionData['medicalRecords']['notes'] !=
                                          null)
                                        ListTile(
                                          leading: const Icon(
                                            Icons.note,
                                            color: Colors.blue,
                                          ),
                                          title: const Text('Medical Notes'),
                                          subtitle: Text(
                                            adoptionData['medicalRecords']['notes'],
                                          ),
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adopted Dogs'),
        backgroundColor: Colors.orange,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Stats Card
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('adoptions')
                    .where(
                      'status',
                      isEqualTo: 'accepted',
                    ) // Changed from 'approved' to 'accepted'
                    .snapshots(),
            builder: (context, snapshot) {
              int totalAdoptions =
                  snapshot.hasData ? snapshot.data!.docs.length : 0;
              return Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade300, Colors.orange.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.pets, color: Colors.white, size: 32),
                    const SizedBox(width: 8),
                    Text(
                      'Total Adoptions: $totalAdoptions',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Adoptions List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('adoptions')
                      .where(
                        'status',
                        isEqualTo: 'accepted',
                      ) // Changed from 'approved' to 'accepted'
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.orange),
                  );
                }

                final adoptions = snapshot.data?.docs ?? [];

                if (adoptions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.pets,
                          size: 80,
                          color: Colors.orange.shade300,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No adopted dogs yet',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Sort by submittedAt instead of approvedDate
                final sortedAdoptions = List.from(adoptions);
                sortedAdoptions.sort((a, b) {
                  final aDate = (a['submittedAt'] as Timestamp).toDate();
                  final bDate = (b['submittedAt'] as Timestamp).toDate();
                  return bDate.compareTo(aDate);
                });

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sortedAdoptions.length,
                  itemBuilder: (context, index) {
                    final adoptionData =
                        sortedAdoptions[index].data() as Map<String, dynamic>;
                    final adoptionDate =
                        (adoptionData['submittedAt'] as Timestamp).toDate();

                    return GestureDetector(
                      onTap: () => _showDogDetailsModal(context, adoptionData),
                      child: Card(
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(15),
                              ),
                              child: Image.network(
                                adoptionData['dogImageUrl'], // Direct from adoptions collection
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 200,
                                    color: Colors.grey.shade200,
                                    child: const Icon(
                                      Icons.pets,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
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
                                        adoptionData['dogName'], // Direct from adoptions collection
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade100,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(
                                              Icons.check_circle,
                                              size: 16,
                                              color: Colors.green,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'Adopted',
                                              style: TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: Colors.orange.shade100,
                                        child: const Icon(Icons.person),
                                      ),
                                      const SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Adopted by: ${adoptionData['userEmail']}', // Direct from adoptions collection
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            'on ${DateFormat('MMMM dd, yyyy').format(adoptionDate)}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
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
    );
  }
}
