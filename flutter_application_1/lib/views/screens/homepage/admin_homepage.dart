// lib/views/admin_home_view.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/views/screens/AdoptedDogs/adopted.dart';
import 'package:flutter_application_1/views/screens/Clients/clients.dart';
import 'package:flutter_application_1/views/screens/Dogs/dogslist.dart';
import 'package:flutter_application_1/views/screens/DonationList/donationlist.dart';
import 'package:flutter_application_1/views/screens/Donations/donations.dart';
import 'package:flutter_application_1/views/screens/Events/eventlist.dart';
import 'package:flutter_application_1/views/screens/Merch/merch_screen.dart';
import 'package:flutter_application_1/views/screens/authentication/bloc/auth_bloc.dart';
import 'package:flutter_application_1/views/screens/authentication/bloc/auth_event.dart';
import 'package:flutter_application_1/views/screens/authentication/login/admin_signin_view.dart';
import 'package:flutter_application_1/views/screens/dashboard/dashboard.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminHomeView extends StatelessWidget {
  const AdminHomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Homepage'),
        backgroundColor: Colors.blue[900],
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            16,
            16,
            50,
          ), // Added bottom padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatCards(),
              const SizedBox(height: 24), // Increased spacing
              _buildClientGrowthChart(),
              const SizedBox(height: 16),
              _buildAdoptionChart(),
              const SizedBox(height: 16),
              _buildEventParticipationChart(),
              const SizedBox(height: 16),
              _buildMerchandiseSalesChart(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCards() {
    return SizedBox(
      height: 220, // Reduced height
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, userSnapshot) {
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('dogs').snapshots(),
            builder: (context, dogsSnapshot) {
              return GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.8, // Increased for better visibility
                mainAxisSpacing: 8, // Reduced spacing
                crossAxisSpacing: 8, // Reduced spacing
                children: [
                  // First row
                  _buildSingleStatCard(
                    'Total Clients',
                    userSnapshot.hasData
                        ? '${userSnapshot.data!.docs.length}'
                        : '0',
                    Icons.people,
                    Colors.teal,
                  ),
                  _buildSingleStatCard(
                    'Available Dogs',
                    dogsSnapshot.hasData
                        ? '${dogsSnapshot.data!.docs.length}'
                        : '0',
                    Icons.pets,
                    Colors.blue,
                  ),
                  // Second row
                  StreamBuilder<QuerySnapshot>(
                    stream:
                        FirebaseFirestore.instance
                            .collection('events')
                            .snapshots(),
                    builder: (context, eventsSnapshot) {
                      return _buildSingleStatCard(
                        'Events',
                        eventsSnapshot.hasData
                            ? '${eventsSnapshot.data!.docs.length}'
                            : '0',
                        Icons.event,
                        Colors.orange,
                      );
                    },
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream:
                        FirebaseFirestore.instance
                            .collection('merch')
                            .snapshots(),
                    builder: (context, productsSnapshot) {
                      return _buildSingleStatCard(
                        'Products',
                        productsSnapshot.hasData
                            ? '${productsSnapshot.data!.docs.length}'
                            : '0',
                        Icons.shopping_bag,
                        Colors.purple,
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // Update the card style
  Widget _buildSingleStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdoptionChart() {
    return SizedBox(
      height: 280,
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Monthly Adoptions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: BarChart(
                  BarChartData(
                    // Implement bar chart data for adoptions
                    // ...
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventParticipationChart() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('events').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final events = snapshot.data!.docs;
        final List<PieChartSectionData> sections = [];

        double totalParticipants = 0;
        for (var event in events) {
          final eventData = event.data() as Map<String, dynamic>;
          final eventName = eventData['eventName'] ?? 'Unnamed Event';
          final participants = eventData['participants']?.length ?? 0;
          totalParticipants += participants;

          if (participants > 0) {
            sections.add(
              PieChartSectionData(
                value: participants.toDouble(),
                title: '$eventName\n($participants)',
                color:
                    Colors.primaries[sections.length % Colors.primaries.length],
                radius: 80,
                titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                showTitle: true,
                badgeWidget: Text(
                  '$participants',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }
        }

        return SizedBox(
          height: 280,
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Event Participation',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child:
                        sections.isEmpty
                            ? const Center(
                              child: Text('No event participation data'),
                            )
                            : PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 0,
                                sections: sections,
                                pieTouchData: PieTouchData(enabled: true),
                              ),
                            ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: StreamBuilder<DocumentSnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('admins')
                      .doc(FirebaseAuth.instance.currentUser?.uid)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data?.exists == true) {
                  final adminData =
                      snapshot.data?.data() as Map<String, dynamic>?;
                  final adminName = adminData?['name'] ?? 'Admin User';
                  return Text(
                    adminName,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  );
                }
                return Text(
                  'Admin User',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                );
              },
            ),
            accountEmail: Text(
              FirebaseAuth.instance.currentUser?.email ?? '',
              style: const TextStyle(color: Colors.white),
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Colors.blue),
            ),
            decoration: const BoxDecoration(color: Colors.blue),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              // Stay on home page
            },
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DashboardScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.event),
            title: const Text('Events'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EventScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.pets),
            title: const Text('Dogs'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DogsListScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Adopted'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdoptedDogsScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Clients'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ClientsView()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.monetization_on),
            title: const Text('Donations'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TopDonatorsScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('Donation List'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DonationListScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: const Text('Merchandise'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MerchScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              _handleLogout(context);
            },
          ),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    context.read<AuthBloc>().add(SignOutRequested());

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => AdminSignInView()),
      (route) => false,
    );
  }

  Widget _buildMerchandiseSalesChart() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('merch').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final products = snapshot.data!.docs;
        final List<PieChartSectionData> sections = [];

        double totalSales = 0;
        for (var product in products) {
          final productData = product.data() as Map<String, dynamic>;
          final productName = productData['name'] ?? 'Unnamed Product';
          final sales = productData['sales'] ?? 0;
          final price = productData['price'] ?? 0;
          final productSales = (sales * price).toDouble();
          totalSales += productSales;

          if (productSales > 0) {
            sections.add(
              PieChartSectionData(
                value: productSales,
                title: '$productName\n₱${productSales.toStringAsFixed(0)}',
                color:
                    Colors.primaries[sections.length % Colors.primaries.length],
                radius: 80,
                titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                showTitle: true,
                badgeWidget: Text(
                  '₱${productSales.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }
        }

        return SizedBox(
          height: 280,
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Merchandise Sales',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Total: ₱${totalSales.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child:
                        sections.isEmpty
                            ? const Center(child: Text('No sales data'))
                            : PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 0,
                                sections: sections,
                                pieTouchData: PieTouchData(enabled: true),
                              ),
                            ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildClientGrowthChart() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('users')
              .orderBy('createdAt')
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data!.docs;
        final Map<String, int> monthlyUsers = {};

        for (var user in users) {
          final userData = user.data() as Map<String, dynamic>;
          final createdAt = (userData['createdAt'] as Timestamp).toDate();
          final monthKey = '${createdAt.year}-${createdAt.month}';
          monthlyUsers[monthKey] = (monthlyUsers[monthKey] ?? 0) + 1;
        }

        final sortedMonths = monthlyUsers.keys.toList()..sort();
        final List<BarChartGroupData> barGroups = [];

        for (int i = 0; i < sortedMonths.length; i++) {
          barGroups.add(
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: monthlyUsers[sortedMonths[i]]!.toDouble(),
                  color: Colors.teal,
                  width: 16,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          );
        }

        // Fixed height container
        return Container(
          height: 280, // Reduced from 300
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Client Growth',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16), // Reduced from 24
                  Expanded(
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY:
                            monthlyUsers.values
                                .reduce((a, b) => a > b ? a : b)
                                .toDouble() *
                            1.2,
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() >= 0 &&
                                    value.toInt() < sortedMonths.length) {
                                  final parts = sortedMonths[value.toInt()]
                                      .split('-');
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      '${parts[1]}/${parts[0].substring(2)}',
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(fontSize: 11),
                                );
                              },
                            ),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(show: false),
                        barGroups: barGroups,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
