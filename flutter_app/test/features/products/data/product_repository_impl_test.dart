import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:flutter_app/core/database/app_database.dart' as db;
import 'package:flutter_app/features/products/data/datasources/product_local_datasource.dart';
import 'package:flutter_app/features/products/data/repositories/product_repository_impl.dart';
import 'package:flutter_app/features/products/domain/entities/product.dart';
import 'package:flutter_app/core/errors/result.dart';

void main() {
  late db.AppDatabase database;
  late ProductLocalDatasource datasource;
  late ProductRepositoryImpl repository;

  setUp(() {
    // Tests are using memory database without full foreign keys execution
    database = db.AppDatabase(NativeDatabase.memory());
    datasource = ProductLocalDatasource(database);
    repository = ProductRepositoryImpl(datasource);
  });

  tearDown(() async {
    await database.close();
  });

  test('addProduct and getProducts works via repository and DTO mappers', () async {
    final product = Product(
      id: 'p1',
      name: 'Test Product',
      sku: 'SKU123',
      categoryId: 'cat1',
      sellingPrice: 100.0,
      costPrice: 50.0,
      stockQuantity: 10,
      lowStockThreshold: 5,
      isDeleted: false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
    );
    
    // Add product
    final addResult = await repository.addProduct(product);
    expect(addResult, isA<Success<void>>());

    // Get products
    final getResult = await repository.getProducts();
    expect(getResult, isA<Success<List<Product>>>());
    final products = (getResult as Success<List<Product>>).data;
    expect(products.length, 1);
    expect(products.first.id, 'p1');
    expect(products.first.name, 'Test Product');
  });

  test('deleteProduct performs a soft delete and hides product from getProducts', () async {
    final product = Product(
      id: 'p2',
      name: 'Test Product 2',
      sku: 'SKU124',
      categoryId: 'cat1',
      sellingPrice: 100.0,
      costPrice: 50.0,
      stockQuantity: 10,
      lowStockThreshold: 5,
      isDeleted: false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
    );

    await repository.addProduct(product);
    
    // Perform soft delete
    final delResult = await repository.deleteProduct('p2');
    expect(delResult, isA<Success<void>>());

    // The item should no longer appear in getProducts query because it filters isDeleted == 0
    final getResult = await repository.getProducts();
    final products = (getResult as Success<List<Product>>).data;
    expect(products.isEmpty, true);
  });
}
