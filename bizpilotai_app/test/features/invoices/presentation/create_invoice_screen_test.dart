import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bizpilotai/features/invoices/presentation/screens/create_invoice_screen.dart';
import 'package:bizpilotai/features/products/domain/entities/product.dart';
import 'package:bizpilotai/features/products/presentation/providers/products_provider.dart';
import 'package:bizpilotai/features/customers/domain/entities/customer.dart';
import 'package:bizpilotai/features/customers/presentation/providers/customers_provider.dart';

void main() {
  final testProducts = [
    Product(
      id: 'p1',
      name: 'iPhone 15',
      sku: 'IP15',
      categoryId: 'c1',
      sellingPrice: 80000.0,
      costPrice: 70000.0,
      stockQuantity: 5,
      lowStockThreshold: 2,
      isDeleted: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Product(
      id: 'p2',
      name: 'USB-C Cable',
      sku: 'CABLE1',
      categoryId: 'c1',
      sellingPrice: 1000.0,
      costPrice: 500.0,
      stockQuantity: 0,
      lowStockThreshold: 1,
      isDeleted: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  final testCustomers = [
    Customer(
      id: 'cust1',
      name: 'John Doe',
      phone: '9876543210',
      totalOutstanding: 0.0,
      isDeleted: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  Widget buildSubject() {
    return ProviderScope(
      overrides: [
        productsProvider.overrideWith((ref) => Stream.value(testProducts)),
        customersProvider.overrideWith((ref) => Stream.value(testCustomers)),
      ],
      child: const MaterialApp(
        home: CreateInvoiceScreen(),
      ),
    );
  }

  testWidgets('CreateInvoiceScreen renders empty cart state initially',
      (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('Create POS Invoice'), findsOneWidget);
    expect(find.text('No products in invoice cart.'), findsOneWidget);
    expect(find.text('Add Product'), findsOneWidget);
  });

  testWidgets('Shows error when submitting empty cart', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    final saveButton = find.text('Save & Issue Tax Invoice');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(find.text('Please add at least one product item to the invoice.'),
        findsOneWidget);
  });

  testWidgets('Adds product to cart and calculates total correctly',
      (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    // Open Add Product Dialog
    await tester.tap(find.text('Add Product'));
    await tester.pumpAndSettle();

    expect(find.text('Select Product to Add'), findsOneWidget);
    expect(find.text('iPhone 15'), findsOneWidget);

    // Tap product to add to cart
    await tester.tap(find.text('iPhone 15'));
    await tester.pumpAndSettle();

    // Cart should now display iPhone 15
    expect(find.text('Invoice Line Items (1)'), findsOneWidget);
    expect(find.text('iPhone 15'), findsOneWidget);
    expect(find.text('Subtotal:'), findsOneWidget);
    expect(find.text('₹80,000.00'), findsWidgets);
  });
}
