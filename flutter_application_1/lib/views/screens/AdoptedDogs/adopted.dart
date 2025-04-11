import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdoptedDogsScreen extends StatelessWidget {
  const AdoptedDogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adoption Statistics'),
        backgroundColor: const Color(0xFF32649B),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')  // Changed to users collection
            .snapshots(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Total Adoptions Card (keep existing code)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF32649B),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.people, color: Colors.white, size: 32),
                    const SizedBox(width: 8),
                    Text(
                      'Total Users: ${userSnapshot.data!.docs.length}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Users List with their adoption count
              Expanded(
                child: FutureBuilder<List<MapEntry<DocumentSnapshot, int>>>(
                  future: _getSortedUsers(userSnapshot.data!.docs),
                  builder: (context, sortedSnapshot) {
                    if (!sortedSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: sortedSnapshot.data!.length,
                      itemBuilder: (context, index) {
                        final userDoc = sortedSnapshot.data![index].key;
                        final adoptionCount = sortedSnapshot.data![index].value;
                        final userData = userDoc.data() as Map<String, dynamic>;
                        final userEmail = userData['email'] ?? 'Unknown Email';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF32649B),
                              child: Text(
                                userEmail.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              userData['fullName'] ?? userEmail,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              '$adoptionCount ${adoptionCount == 1 ? 'dog' : 'dogs'} adopted',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () => _showUserAdoptedDogs(context, userDoc.id, userData),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<List<MapEntry<DocumentSnapshot, int>>> _getSortedUsers(List<DocumentSnapshot> users) async {
    List<MapEntry<DocumentSnapshot, int>> usersWithCount = [];
    
    for (var user in users) {
      final count = await FirebaseFirestore.instance
          .collection('adoptions')
          .where('userId', isEqualTo: user.id)
          .where('status', isEqualTo: 'approved')
          .get()
          .then((snap) => snap.docs.length);
          
      if (count > 0) {  // Only add users who have adoptions
        usersWithCount.add(MapEntry(user, count));
      }
    }
    
    // Sort by count in descending order
    usersWithCount.sort((a, b) => b.value.compareTo(a.value));
    return usersWithCount;
  }

  void _showUserAdoptedDogs(BuildContext context, String userId, Map<String, dynamic> userData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                userData['fullName'] ?? userData['email'] ?? 'Unknown User',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF32649B),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('adoptions')
                    .where('userId', isEqualTo: userId)
                    .where('status', isEqualTo: 'approved')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final adoption = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                      final adoptionDate = adoption['approvedAt'] != null
                          ? (adoption['approvedAt'] as Timestamp).toDate()
                          : (adoption['submittedAt'] as Timestamp).toDate();

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('dogs')
                            .doc(adoption['dogId'])
                            .get(),
                        builder: (context, dogSnapshot) {
                          if (!dogSnapshot.hasData) {
                            return const Card(
                              child: ListTile(
                                title: Text('Loading...'),
                              ),
                            );
                          }

                          final dogData = dogSnapshot.data!.data() as Map<String, dynamic>;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  dogData['imageUrl'] ?? '',
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.pets),
                                  ),
                                ),
                              ),
                              title: Text(
                                dogData['name'] ?? 'Unknown Dog',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                'Adopted on ${DateFormat('MMM dd, yyyy').format(adoptionDate)}',
                              ),
                            ),
                          );
                        },
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
}
