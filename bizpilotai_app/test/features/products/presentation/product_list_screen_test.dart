import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bizpilotai/features/products/domain/entities/product.dart';
import 'package:bizpilotai/features/products/presentation/providers/products_provider.dart';
import 'package:bizpilotai/features/products/presentation/screens/product_list_screen.dart';

void main() {
  final List<Product> mockProducts = [
    Product(
      id: 'p1', name: 'Mock iPhone', sku: 'IP1', categoryId: 'c1',
      sellingPrice: 1000.0, costPrice: 800.0, stockQuantity: 10, lowStockThreshold: 5,
      isDeleted: false, createdAt: DateTime.now(), updatedAt: DateTime.now(),
    ),
    Product(
      id: 'p2', name: 'Mock Charger', sku: 'CHG1', categoryId: 'c2',
      sellingPrice: 20.0, costPrice: 5.0, stockQuantity: 2, lowStockThreshold: 10,
      isDeleted: false, createdAt: DateTime.now(), updatedAt: DateTime.now(),
    ),
  ];

  testWidgets('Renders a list of products', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productsProvider.overrideWith((ref) => Stream.value(mockProducts)),
        ],
        child: const MaterialApp(
          home: ProductListScreen(),
        ),
      ),
    );

    // Initial Loading State
    await tester.pump();

    expect(find.text('Mock iPhone'), findsOneWidget);
    expect(find.text('Mock Charger'), findsOneWidget);
    
    // Validating UI highlights low stock visually.
    expect(find.text('10'), findsOneWidget);
    expect(find.text('2'), findsOneWidget); // Is flagged as low stock (2 < 10)
  });

  testWidgets('Shows empty state when no products exist', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productsProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: const MaterialApp(
          home: ProductListScreen(),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('No products found. Add one!'), findsOneWidget);
  });
}
