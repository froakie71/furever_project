import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1_user/bloc/event_registration/event_registration_bloc.dart';
import 'package:flutter_application_1_user/bloc/event_registration/event_registration_event.dart';
import 'package:flutter_application_1_user/bloc/event_registration/event_registration_state.dart';
import 'package:flutter_application_1_user/views/screens/adopted_dogs_screen.dart';
import 'package:flutter_application_1_user/views/screens/dog_screen.dart';
import 'package:flutter_application_1_user/views/screens/donation_screen.dart';
import 'package:flutter_application_1_user/views/screens/home_screen.dart';
import 'package:flutter_application_1_user/views/screens/merch_screen.dart';
import 'package:flutter_application_1_user/views/screens/participated_events_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'medical_services_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1_user/models/event_model.dart';
import 'package:flutter_application_1_user/views/widgets/shared_drawer.dart';

class EventScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  EventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Load registered events when screen is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<EventRegistrationBloc>().state;
      if (state is! RegisteredEventsLoaded) {
        context.read<EventRegistrationBloc>().add(CheckRegisteredEvents());
      }
    });

    return BlocBuilder<EventRegistrationBloc, EventRegistrationState>(
      builder: (context, registrationState) {
        Set<String> registeredEventIds = {};
        if (registrationState is RegisteredEventsLoaded) {
          registeredEventIds = registrationState.registeredEventIds;
        }

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
              IconButton(
                icon: const Icon(Icons.event_available),
                onPressed: () async {
                  context.read<EventRegistrationBloc>().add(
                    LoadParticipatedEvents(),
                  );
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => BlocProvider.value(
                            value: context.read<EventRegistrationBloc>(),
                            child: const ParticipatedEventsScreen(),
                          ),
                    ),
                  );
                  // Refresh the registration status when returning
                  if (context.mounted) {
                    context.read<EventRegistrationBloc>().add(
                      CheckRegisteredEvents(),
                    );
                  }
                },
              ),
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
          endDrawer: const SharedDrawer(),
          body: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('events')
                    .orderBy('date')
                    .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No events available'));
              }

              final events =
                  snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return Event.fromFirestore(data, doc.id);
                  }).toList();

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: events.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return const Padding(
                      padding: EdgeInsets.only(bottom: 15),
                      child: Text(
                        'Upcoming Events',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF32649B),
                        ),
                      ),
                    );
                  }

                  final event = events[index - 1];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    color: const Color.fromARGB(255, 22, 79, 139),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 200,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                            image: DecorationImage(
                              image: NetworkImage(event.imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade100,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '${event.date.day} ${_getMonth(event.date.month)}',
                                      style: TextStyle(
                                        color: Colors.orange.shade800,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade100,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      event.time,
                                      style: TextStyle(
                                        color: Colors.blue.shade800,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                event.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    event.location,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                event.description,
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: BlocConsumer<
                                      EventRegistrationBloc,
                                      EventRegistrationState
                                    >(
                                      listener: (context, state) {
                                        if (state is EventRegistrationSuccess) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Successfully registered for the event!',
                                              ),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        }
                                      },
                                      builder: (context, state) {
                                        final isRegistered =
                                            state is RegisteredEventsLoaded &&
                                            state.registeredEventIds.contains(
                                              event.id,
                                            );

                                        return ElevatedButton(
                                          onPressed:
                                              isRegistered
                                                  ? null
                                                  : () {
                                                    context
                                                        .read<
                                                          EventRegistrationBloc
                                                        >()
                                                        .add(
                                                          RegisterForEvent(
                                                            event.id,
                                                          ),
                                                        );
                                                  },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                isRegistered
                                                    ? Colors.grey
                                                    : const Color(0xFF32649B),
                                            foregroundColor: Colors.white,
                                          ),
                                          child: Text(
                                            isRegistered
                                                ? 'Registered'
                                                : 'Register',
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  String _getMonth(int month) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return months[month - 1];
  }

  void _registerForEvent(BuildContext context, Event event) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to register for events')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('event_registrations').add({
        'eventId': event.id,
        'eventTitle': event.title,
        'userId': currentUser.uid,
        'userEmail': currentUser.email,
        'registeredAt': FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully registered for the event!'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error registering for event: $e')),
        );
      }
    }
  }
}
