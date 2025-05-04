// lib/views/admin_home_view.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/views/screens/authentication/bloc/auth_bloc.dart';
import 'package:flutter_application_1/views/screens/authentication/bloc/auth_event.dart';
import 'package:flutter_application_1/views/screens/authentication/login/admin_signin_view.dart';
import 'package:flutter_application_1/views/widgets/shared_drawer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';

// Helper class for bar chart data
class _EventBarData {
  final String eventName;
  final int participants;
  _EventBarData(this.eventName, this.participants);
}

class AdminHomeView extends StatelessWidget {
  const AdminHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Homepage'),
        backgroundColor: Colors.blue[900],
      ),
      drawer: SharedDrawer(),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCards() {
    return SizedBox(
      height: 220,
      child: GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3, // Changed to 3 columns
        childAspectRatio: 1.5,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) => _buildSingleStatCard(
              'Total Users',
              snapshot.hasData ? '${snapshot.data!.docs.length}' : '0',
              Icons.people,
              Colors.teal,
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('adoptions')
                .where('status', isEqualTo: 'approved')
                .snapshots(),
            builder: (context, snapshot) => _buildSingleStatCard(
              'Adoptions',
              snapshot.hasData ? '${snapshot.data!.docs.length}' : '0',
              Icons.pets,
              Colors.green,
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('dogs')
                .where('status', isEqualTo: 'available')
                .snapshots(),
            builder: (context, snapshot) => _buildSingleStatCard(
              'Available Dogs',
              snapshot.hasData ? '${snapshot.data!.docs.length}' : '0',
              Icons.pets,
              Colors.blue,
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('events').snapshots(),
            builder: (context, snapshot) => _buildSingleStatCard(
              'Events',
              snapshot.hasData ? '${snapshot.data!.docs.length}' : '0',
              Icons.event,
              Colors.orange,
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('donations').snapshots(),
            builder: (context, snapshot) {
              double total = 0;
              if (snapshot.hasData) {
                for (var doc in snapshot.data!.docs) {
                  total +=
                      (doc.data() as Map<String, dynamic>)['amount'] as double;
                }
              }
              return _buildSingleStatCard(
                'Donations',
                '₱${total.toStringAsFixed(0)}',
                Icons.volunteer_activism,
                Colors.purple,
              );
            },
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('merch').snapshots(),
            builder: (context, snapshot) => _buildSingleStatCard(
              'Products',
              snapshot.hasData ? '${snapshot.data!.docs.length}' : '0',
              Icons.shopping_bag,
              Colors.red,
            ),
          ),
        ],
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
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('adoptions')
          .where('status', isEqualTo: 'approved')
          .snapshots(), // Removed orderBy to avoid index requirement
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 280,
          ); // Return empty space instead of loading indicator
        }

        final adoptions = snapshot.data!.docs;
        final Map<String, int> monthlyAdoptions = {};

        // Group adoptions by month
        for (var adoption in adoptions) {
          final data = adoption.data() as Map<String, dynamic>;
          if (data['approvedAt'] != null) {
            final date = (data['approvedAt'] as Timestamp).toDate();
            final monthKey = '${date.year}-${date.month}';
            monthlyAdoptions[monthKey] = (monthlyAdoptions[monthKey] ?? 0) + 1;
          }
        }

        // If no data, return empty container with same height
        if (monthlyAdoptions.isEmpty) {
          return SizedBox(
            height: 280,
            child: Card(
              elevation: 4,
              child: Center(
                child: Text(
                  'No adoption data available',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),
          );
        }

        final sortedMonths = monthlyAdoptions.keys.toList()..sort();
        final List<BarChartGroupData> barGroups = [];

        for (int i = 0; i < sortedMonths.length; i++) {
          barGroups.add(
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: monthlyAdoptions[sortedMonths[i]]!.toDouble(),
                  color: Colors.green,
                  width: 16,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          );
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
                        'Monthly Adoptions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Total: ${adoptions.length}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: monthlyAdoptions.values
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
                                  final parts =
                                      sortedMonths[value.toInt()].split('-');
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

  Widget _buildEventParticipationChart() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('event_registrations')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 280,
            child: Card(
              elevation: 4,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        final registrations = snapshot.data!.docs;
        final Map<String, int> eventParticipants = {};

        // Count participants per event
        for (var registration in registrations) {
          final data = registration.data() as Map<String, dynamic>;
          final eventId = data['eventId'] as String;
          eventParticipants[eventId] = (eventParticipants[eventId] ?? 0) + 1;
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('events').snapshots(),
          builder: (context, eventsSnapshot) {
            if (!eventsSnapshot.hasData) {
              return const SizedBox(
                height: 280,
                child: Card(
                  elevation: 4,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            }

            final events = eventsSnapshot.data!.docs;
            double totalParticipants = 0;
            final List<_EventBarData> barData = <_EventBarData>[];

            for (var event in events) {
              final eventData = event.data() as Map<String, dynamic>;
              final eventId = event.id;
              final eventName = eventData['title'] ?? 'Unnamed Event';
              final participants = eventParticipants[eventId] ?? 0;
              totalParticipants += participants;
              if (participants > 0) {
                barData.add(_EventBarData(eventName, participants));
              }
            }

            // Sort by participants descending
            barData.sort((a, b) => b.participants.compareTo(a.participants));

            // Responsive height for mobile
            final double chartHeight = (barData.length * 36.0).clamp(180, 400);
            final double barWidth =
                MediaQuery.of(context).size.width < 400 ? 14 : 20;
            final double fontSize =
                MediaQuery.of(context).size.width < 400 ? 12 : 14;

            return SizedBox(
              height: chartHeight + 60,
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Event Participation',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.orange.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'Total: ${totalParticipants.toInt()}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: barData.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.event_busy,
                                      size: 40,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'No event participation data',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.center,
                                  maxY: barData.isNotEmpty
                                      ? (barData
                                              .map((e) => e.participants)
                                              .reduce((a, b) => a > b ? a : b) *
                                          1.2)
                                      : 10,
                                  barTouchData: BarTouchData(
                                    enabled: true,
                                    touchTooltipData: BarTouchTooltipData(
                                      getTooltipColor: (group) =>
                                          Colors.blueGrey,
                                      getTooltipItem:
                                          (group, groupIndex, rod, rodIndex) {
                                        return BarTooltipItem(
                                          '${barData[group.x.toInt()].eventName}\n',
                                          TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: fontSize + 2,
                                          ),
                                          children: [
                                            TextSpan(
                                              text:
                                                  'Participants: ${rod.toY.toInt()}',
                                              style: TextStyle(
                                                color: Colors.yellow,
                                                fontSize: fontSize,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                  titlesData: FlTitlesData(
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 120,
                                        getTitlesWidget: (value, meta) {
                                          if (value.toInt() >= 0 &&
                                              value.toInt() < barData.length) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 4),
                                              child: Text(
                                                barData[value.toInt()]
                                                    .eventName,
                                                style: TextStyle(
                                                    fontSize: fontSize,
                                                    fontWeight:
                                                        FontWeight.w500),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            );
                                          }
                                          return const Text('');
                                        },
                                      ),
                                    ),
                                    rightTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    topTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 32,
                                        getTitlesWidget: (value, meta) {
                                          return Text(
                                            value.toInt().toString(),
                                            style: TextStyle(
                                                fontSize: fontSize - 2),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  gridData: FlGridData(
                                      show: true, drawHorizontalLine: true),
                                  barGroups: [
                                    for (int i = 0; i < barData.length; i++)
                                      BarChartGroupData(
                                        x: i,
                                        barRods: [
                                          BarChartRodData(
                                            toY: barData[i]
                                                .participants
                                                .toDouble(),
                                            color: Colors.orange,
                                            width: barWidth,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            rodStackItems: [],
                                            fromY: 0,
                                          ),
                                        ],
                                        barsSpace: 8,
                                      ),
                                  ],
                                  groupsSpace: 12,
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
      },
    );
  }

  void _handleLogout(BuildContext context) {
    context.read<AuthBloc>().add(SignOutRequested());

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => AdminSignInView()),
      (route) => false,
    );
  }

  Widget _buildClientGrowthChart() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
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
        return SizedBox(
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
                        maxY: monthlyUsers.values
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
                                  final parts =
                                      sortedMonths[value.toInt()].split('-');
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
