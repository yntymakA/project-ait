import 'package:flutter/material.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inbox'),
      ),
      body: ListView.builder(
        itemCount: 0, // Placeholder
        itemBuilder: (context, index) {
          return const ListTile(
            title: Text('Chat with ...'),
            subtitle: Text('Last message snippet'),
          );
        },
      ),
    );
  }
}
