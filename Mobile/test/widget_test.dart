import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marketplace_app/main.dart'; // Adjust import as necessary
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('App starts', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MarketplaceApp()));
    // Let animation finish
    await tester.pumpAndSettle();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
