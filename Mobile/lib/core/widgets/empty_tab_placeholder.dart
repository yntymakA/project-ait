import 'package:flutter/material.dart';

class EmptyTabPlaceholder extends StatelessWidget {
  final String title;

  const EmptyTabPlaceholder({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text('$title - Coming soon...'),
      ),
    );
  }
}
