import 'package:flutter/material.dart';
import 'package:flutter_application_1_user/bloc/schedule_checkup/schedule_checkup_bloc.dart';
import 'package:flutter_application_1_user/bloc/schedule_checkup/schedule_checkup_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ScheduleCheckupModal extends StatefulWidget {
  final String dogId;
  final String userId;

  const ScheduleCheckupModal({
    super.key,
    required this.dogId,
    required this.userId,
  });

  @override
  State<ScheduleCheckupModal> createState() => _ScheduleCheckupModalState();
}

class _ScheduleCheckupModalState extends State<ScheduleCheckupModal> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final TextEditingController _descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ScheduleCheckupBloc>().add(
      LoadScheduleCheckup(widget.dogId, widget.userId),
    );
  }

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('hh:mm a').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('schedule_checkup')
              .where('dogId', isEqualTo: widget.dogId)
              .where('userId', isEqualTo: widget.userId)
              .limit(1)
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          // No checkup scheduled: show the form
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Schedule Checkup',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 16),
                FutureBuilder<DocumentSnapshot>(
                  future:
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(widget.userId)
                          .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircleAvatar(
                        radius: 32,
                        child: CircularProgressIndicator(),
                      );
                    }
                    final userData =
                        snapshot.data?.data() as Map<String, dynamic>?;
                    final photoUrl = userData?['photoUrl'] as String?;
                    final displayName =
                        userData?['username'] ?? userData?['email'] ?? '';
                    return CircleAvatar(
                      radius: 32,
                      backgroundImage:
                          (photoUrl != null && photoUrl.isNotEmpty)
                              ? NetworkImage(photoUrl)
                              : null,
                      child:
                          (photoUrl == null || photoUrl.isEmpty)
                              ? Text(
                                  displayName.isNotEmpty
                                      ? displayName[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                    );
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  minLines: 1,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedDate == null
                            ? 'No date chosen'
                            : 'Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}',
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedDate = picked;
                          });
                        }
                      },
                      child: const Text('Choose Date'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedTime == null
                            ? 'No time chosen'
                            : 'Time: ${_formatTime(_selectedTime!)}',
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _selectedTime ?? TimeOfDay.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedTime = picked;
                          });
                        }
                      },
                      child: const Text('Choose Time'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_selectedDate == null || _selectedTime == null || _descController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all fields')),
                      );
                      return;
                    }
                    
                    // Combine date and time
                    final dateTime = DateTime(
                      _selectedDate!.year,
                      _selectedDate!.month,
                      _selectedDate!.day,
                      _selectedTime!.hour,
                      _selectedTime!.minute,
                    );
                    
                    context.read<ScheduleCheckupBloc>().add(
                      AddOrUpdateScheduleCheckup(
                        widget.dogId,
                        widget.userId,
                        dateTime,
                        _descController.text,
                      ),
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          );
        } else {
          // There is a checkup scheduled
          final checkup = docs.first.data() as Map<String, dynamic>;
          final status = checkup['status'] ?? 'pending';
          _descController.text = checkup['description'] ?? '';
          _selectedDate = (checkup['date'] as Timestamp).toDate();

          if (status == 'approved') {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: const [
                  Icon(Icons.verified, color: Colors.green),
                  SizedBox(width: 8),
                  Text(
                    'Approved by Admin',
                    style: TextStyle(color: Colors.green),
                  ),
                ],
              ),
            );
          } else if (status == 'pending') {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: const Text('Pending approval...'),
            );
          } else {
            // fallback
            return const SizedBox.shrink();
          }
        }
      },
    );
  }
}
