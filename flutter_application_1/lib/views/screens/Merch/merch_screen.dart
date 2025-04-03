import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter_application_1/views/screens/Merch/add_merch_screen.dart';
import 'package:flutter_application_1/views/screens/Merch/bloc/merch_bloc.dart';
import 'package:flutter_application_1/views/screens/Merch/bloc/merch_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MerchScreen extends StatelessWidget {
  const MerchScreen({super.key});

  Future<void> _launchUrl(BuildContext context, String url) async {
    try {
      if (await canLaunchUrlString(url)) {
        await launchUrlString(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error launching URL: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Merchandise'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddMerchScreen()),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<MerchBloc, MerchState>(
        builder: (context, state) {
          if (state is MerchLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is MerchLoaded) {
            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: state.merch.length,
              itemBuilder: (context, index) {
                final merch = state.merch[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 4,
                  ),
                  child: ExpansionTile(
                    leading: Hero(
                      tag: merch.id ?? merch.imageUrl,
                      child: CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(merch.imageUrl),
                        backgroundColor: Colors.grey[200],
                      ),
                    ),
                    title: Text(
                      merch.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      merch.category,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Description:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              merch.description,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 16),
                            InkWell(
                              onTap: () => _launchUrl(context, merch.url),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(
                                      Icons.shopping_cart,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Buy Now',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No merchandise found',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
