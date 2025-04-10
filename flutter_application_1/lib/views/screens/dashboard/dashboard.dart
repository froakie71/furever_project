// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight:
                MediaQuery.of(context).size.height -
                AppBar().preferredSize.height -
                MediaQuery.of(context).padding.top,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatCards(),
                const SizedBox(height: 24),
                _buildDogsChart(),
                const SizedBox(height: 24),
                _buildDonationsChart(),
                const SizedBox(height: 24),
                Container(
                  height: 200,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Clients Overview',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream:
                              FirebaseFirestore.instance
                                  .collection('users')
                                  .orderBy('createdAt')
                                  .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            final clients = snapshot.data!.docs;
                            final List<FlSpot> spots = [];

                            for (var i = 0; i < clients.length; i++) {
                              spots.add(
                                FlSpot(i.toDouble(), (i + 1).toDouble()),
                              );
                            }

                            return LineChart(
                              LineChartData(
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: true,
                                  horizontalInterval: 5,
                                  verticalInterval: 2,
                                  getDrawingHorizontalLine: (value) {
                                    return FlLine(
                                      color: Colors.grey.withOpacity(0.1),
                                      strokeWidth: 1,
                                    );
                                  },
                                ),
                                titlesData: FlTitlesData(
                                  rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  bottomTitles: AxisTitles(
                                    axisNameWidget: const Text('Time'),
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      interval: 2,
                                      reservedSize: 32,
                                      getTitlesWidget: (value, meta) {
                                        return Text(value.toInt().toString());
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    axisNameWidget: const Text('Clients'),
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      interval: 10,
                                      reservedSize: 40,
                                      getTitlesWidget: (value, meta) {
                                        if (value % 10 != 0) {
                                          return const SizedBox.shrink();
                                        }
                                        String text = value.toInt().toString();
                                        if (text.length > 3) {
                                          text = '${text.substring(0, 2)}..';
                                        }
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            right: 8,
                                          ),
                                          child: Text(
                                            text,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: spots,
                                    isCurved: true,
                                    color: Colors.purple,
                                    barWidth: 3,
                                    dotData: const FlDotData(show: false),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      color: Colors.purple.withOpacity(0.2),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String collection,
    IconData icon,
    Color color,
  ) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          collection == 'adoptions'
              ? FirebaseFirestore.instance
                  .collection(collection)
                  .where('status', isEqualTo: 'accepted')
                  .snapshots()
              : FirebaseFirestore.instance.collection(collection).snapshots(),
      builder: (context, snapshot) {
        int count = 0;
        if (snapshot.hasData) {
          if (collection == 'donations') {
            double total = 0;
            for (var doc in snapshot.data!.docs) {
              total += (doc.data() as Map<String, dynamic>)['amount'] as double;
            }
            return _buildStatCardContent(
              title,
              '₱${total.toStringAsFixed(0)}',
              icon,
              color,
            );
          } else {
            count = snapshot.data!.docs.length;
          }
        }
        return _buildStatCardContent(title, count.toString(), icon, color);
      },
    );
  }

  Widget _buildStatCardContent(
    String title,
    String count,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              count,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDogsChart() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('dogs').snapshots(),
      builder: (context, dogsSnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('adoptions')
                  .where('status', isEqualTo: 'accepted')
                  .snapshots(),
          builder: (context, adoptionsSnapshot) {
            if (!dogsSnapshot.hasData || !adoptionsSnapshot.hasData) {
              return const SizedBox(height: 250);
            }

            final totalDogs = dogsSnapshot.data!.docs.length;
            final adoptedDogs = adoptionsSnapshot.data!.docs.length;
            final availableDogs = totalDogs - adoptedDogs;

            return SizedBox(
              height: 250,
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dogs Status',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                            sections: [
                              PieChartSectionData(
                                value: availableDogs.toDouble(),
                                title: 'Available\n($availableDogs)',
                                color: Colors.blue,
                                radius: 100,
                                titleStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              PieChartSectionData(
                                value: adoptedDogs.toDouble(),
                                title: 'Adopted\n($adoptedDogs)',
                                color: Colors.green,
                                radius: 100,
                                titleStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
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

  Widget _buildDonationsChart() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('donations')
              .orderBy('timestamp', descending: true)
              .limit(7) // Last 7 days
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(height: 200);
        }

        final donations = snapshot.data!.docs;
        final Map<String, double> dailyTotals = {};
        double totalAmount = 0;

        // Group donations by day
        for (var donation in donations) {
          final data = donation.data() as Map<String, dynamic>;
          final date = (data['timestamp'] as Timestamp).toDate();
          final dayKey = '${date.day}/${date.month}';
          dailyTotals[dayKey] =
              (dailyTotals[dayKey] ?? 0) + (data['amount'] as num).toDouble();
          totalAmount += (data['amount'] as num).toDouble();
        }

        return Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Weekly Donations',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '₱${totalAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY:
                        dailyTotals.values.isEmpty
                            ? 1000
                            : dailyTotals.values.reduce(
                                  (a, b) => a > b ? a : b,
                                ) *
                                1.2,
                    barGroups:
                        dailyTotals.entries.map((e) {
                          return BarChartGroupData(
                            x: dailyTotals.keys.toList().indexOf(e.key),
                            barRods: [
                              BarChartRodData(
                                toY: e.value,
                                color: Colors.green,
                                width: 16,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          );
                        }).toList(),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= 0 &&
                                value.toInt() < dailyTotals.length) {
                              return Text(
                                dailyTotals.keys.toList()[value.toInt()],
                                style: const TextStyle(fontSize: 10),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }

  Widget _buildStatCards() {
    return SizedBox(
      height: 120, // Increased height to accommodate more cards
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildStatCard('Total Dogs', 'dogs', Icons.pets, Colors.blue),
          _buildStatCard('Adopted Dogs', 'adoptions', Icons.home, Colors.green),
          _buildStatCard('Total Users', 'users', Icons.people, Colors.purple),
          _buildStatCard(
            'Event Participants',
            'event_registrations',
            Icons.event,
            Colors.orange,
          ),
          _buildStatCard(
            'Total Donators',
            'donations',
            Icons.volunteer_activism,
            Colors.red,
          ),
        ],
      ),
    );
  }
}
