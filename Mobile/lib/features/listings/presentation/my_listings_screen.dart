import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Listings'),
      ),
      body: const Center(
        child: Text('My listings will be displayed here.'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/create-listing');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
