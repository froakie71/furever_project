import 'package:flutter/material.dart';
import 'package:flutter_application_1/views/screens/ProcessAdoption/bloc/adoption_bloc.dart';
import 'package:flutter_application_1/views/screens/ProcessAdoption/bloc/adoption_event.dart';
import 'package:flutter_application_1/views/screens/ProcessAdoption/bloc/adoption_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../widgets/shared_drawer.dart';

class ProcessAdoptionScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  ProcessAdoptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdoptionBloc()..add(LoadPendingAdoptions()),
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: const Color(0xFF32649B),
          automaticallyImplyLeading: false,
          title: Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 40,
                  child: Image.asset(
                    'assets/images/Furever_logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.pets, color: Colors.white);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Process Adoptions',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            ),
          ],
        ),
        endDrawer: const SharedDrawer(),
        body: BlocBuilder<AdoptionBloc, AdoptionState>(
          builder: (context, state) {
            if (state is AdoptionLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is AdoptionError) {
              return Center(child: Text('Error: ${state.message}'));
            }

            if (state is AdoptionLoaded) {
              if (state.adoptions.isEmpty) {
                return const Center(child: Text('No pending adoptions'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.adoptions.length,
                itemBuilder: (context, index) {
                  final adoption = state.adoptions[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  adoption['dogImageUrl'] ?? '',
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 100,
                                      height: 100,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.pets),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Dog: ${adoption['dogName']}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Adopter: ${adoption['userEmail']}',
                                      style: const TextStyle(fontSize: 16),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'Status: Pending',
                                      style: TextStyle(
                                        color: Colors.orange[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    context.read<AdoptionBloc>().add(
                                      AcceptAdoption(
                                        adoptionId: adoption['id'],
                                        dogId: adoption['dogId'],
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                  icon: const Icon(Icons.check),
                                  label: const Text('Accept'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    context.read<AdoptionBloc>().add(
                                      DeclineAdoption(
                                        adoptionId: adoption['id'],
                                        dogId: adoption['dogId'],
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                  icon: const Icon(Icons.close),
                                  label: const Text('Decline'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
