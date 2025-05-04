import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserSearchDelegate extends SearchDelegate<String> {
  final List<DocumentSnapshot> users;
  final bool showAdoptionsOnly;

  UserSearchDelegate({required this.users, this.showAdoptionsOnly = false});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildSearchResults();
  }

  Widget buildSearchResults() {
    final results =
        users.where((user) {
          final userData = user.data() as Map<String, dynamic>;
          final email = userData['email']?.toString().toLowerCase() ?? '';
          final name = userData['fullName']?.toString().toLowerCase() ?? '';
          final searchTerm = query.toLowerCase();

          return email.contains(searchTerm) || name.contains(searchTerm);
        }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final userData = results[index].data() as Map<String, dynamic>;
        return ListTile(
          leading: CircleAvatar(
            child: Text((userData['email'] ?? '?')[0].toUpperCase()),
          ),
          title: Text(userData['fullName'] ?? 'No Name'),
          subtitle: Text(userData['email'] ?? ''),
          onTap: () => close(context, results[index].id),
        );
      },
    );
  }
}
