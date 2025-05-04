import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminRescueReportsScreen extends StatelessWidget {
  const AdminRescueReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dog Rescue Reports'),
        backgroundColor: const Color(0xFF32649B),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('rescue_reports')
                .orderBy('createdAt', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final reports = snapshot.data!.docs;

          if (reports.isEmpty) {
            return const Center(child: Text('No rescue reports available'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index].data() as Map<String, dynamic>;
              final reportId = reports[index].id;

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      report['imageUrl'] ?? '',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[300],
                          child: const Icon(Icons.error),
                        );
                      },
                    ),
                  ),
                  title: Text('Location: ${report['address']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<DocumentSnapshot>(
                        future:
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(report['userId'])
                                .get(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data != null) {
                            final userData =
                                snapshot.data!.data() as Map<String, dynamic>?;
                            return Text(
                              'Email: ${userData?['email'] ?? 'Not available'}',
                            );
                          }
                          return const Text('Email: Loading...');
                        },
                      ),
                      Text('Landmark: ${report['landmark']}'),
                      Text('Reported: ${_formatDate(report['createdAt'])}'),
                      Text('Phone: ${report['phoneNumber'] ?? 'N/A'}'),
                    ],
                  ),
                  onTap: () => _showReportDetails(context, report, reportId),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(dynamic date) {
    try {
      if (date == null) return 'Date not available';

      if (date is Timestamp) {
        return DateFormat('MMM dd, yyyy hh:mm a').format(date.toDate());
      } else if (date is String) {
        return DateFormat('MMM dd, yyyy hh:mm a').format(DateTime.parse(date));
      } else {
        return 'Date not available';
      }
    } catch (e) {
      return 'Date not available';
    }
  }

  void _showReportDetails(
    BuildContext context,
    Map<String, dynamic> report,
    String reportId,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.8,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder:
                (context, scrollController) => Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Report Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            report['imageUrl'] ?? '',
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
                                color: Colors.grey[300],
                                child: const Icon(Icons.error, size: 50),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Report Details
                        _buildDetailSection(
                          'Location',
                          report['address'] ?? 'Not specified',
                        ),
                        _buildDetailSection(
                          'Landmark',
                          report['landmark'] ?? 'Not specified',
                        ),
                        _buildDetailSection(
                          'Report Date & Time',
                          _formatDate(report['createdAt']) ??
                              'Date not available',
                        ),
                        _buildDetailSection(
                          'Phone Number',
                          report['phoneNumber'] ?? 'Not specified',
                        ),
                      ],
                    ),
                  ),
                ),
          ),
    );
  }

  Widget _buildDetailSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF32649B),
            ),
          ),
          const SizedBox(height: 4),
          Text(content, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Future<void> _updateReportStatus(String reportId, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('rescue_reports')
          .doc(reportId)
          .update({
            'status': status,
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      print('Error updating report status: $e');
    }
  }
}
