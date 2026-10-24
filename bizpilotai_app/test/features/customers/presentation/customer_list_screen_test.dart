import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bizpilotai/features/customers/domain/entities/customer.dart';
import 'package:bizpilotai/features/customers/presentation/providers/customers_provider.dart';
import 'package:bizpilotai/features/customers/presentation/screens/customer_list_screen.dart';

void main() {
  final List<Customer> mockCustomers = [
    Customer(
      id: 'c1', name: 'John Doe', phone: '1234567890',
      totalOutstanding: 0.0, isDeleted: false, createdAt: DateTime.now(), updatedAt: DateTime.now(),
    ),
    Customer(
      id: 'c2', name: 'Jane Smith', phone: '0987654321',
      totalOutstanding: 150.0, isDeleted: false, createdAt: DateTime.now(), updatedAt: DateTime.now(),
    ),
  ];

  testWidgets('Renders a list of customers', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          customersProvider.overrideWith((ref) => Stream.value(mockCustomers)),
        ],
        child: const MaterialApp(
          home: CustomerListScreen(),
        ),
      ),
    );

    // Initial Loading State
    await tester.pump();

    expect(find.text('John Doe'), findsOneWidget);
    expect(find.text('Jane Smith'), findsOneWidget);
    
    // Validating UI highlights outstanding balances visually.
    expect(find.text('\$0.00'), findsOneWidget);
    expect(find.text('\$150.00'), findsOneWidget);
  });

  testWidgets('Shows empty state when no customers exist', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          customersProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: const MaterialApp(
          home: CustomerListScreen(),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('No customers found. Add one!'), findsOneWidget);
  });
}
