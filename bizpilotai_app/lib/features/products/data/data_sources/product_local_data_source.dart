import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bizpilotai/core/database/app_database.dart' as db;
import 'package:bizpilotai/core/database/database_provider.dart';

final productLocalDataSourceProvider = Provider<ProductLocalDataSource>((ref) {
  return ProductLocalDataSource(ref.watch(databaseProvider));
});

class ProductLocalDataSource {
  final db.AppDatabase _db;

  ProductLocalDataSource(this._db);

  Future<List<db.Category>> getCategories() {
    return _db.select(_db.categories).get();
  }

  Future<List<db.Product>> getProducts() {
    return (_db.select(_db.products)..where((t) => t.isDeleted.equals(0))).get();
  }

  Future<db.Product> getProductById(String id) {
    return (_db.select(_db.products)..where((t) => t.id.equals(id))).getSingle();
  }

  Future<void> insertProduct(db.ProductsCompanion product) {
    return _db.into(_db.products).insert(product);
  }

  Future<void> updateProduct(db.ProductsCompanion product) {
    return (_db.update(_db.products)..where((t) => t.id.equals(product.id.value))).write(product);
  }

  Future<void> softDeleteProduct(String id) {
    return (_db.update(_db.products)..where((t) => t.id.equals(id))).write(
      db.ProductsCompanion(
        isDeleted: const Value(1),
        deletedAt: Value(DateTime.now().millisecondsSinceEpoch),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  Stream<List<db.Product>> watchProducts() {
    return (_db.select(_db.products)..where((t) => t.isDeleted.equals(0))).watch();
  }

  Stream<List<db.Product>> watchLowStockProducts() {
    return (_db.select(_db.products)
      ..where((t) => t.isDeleted.equals(0) & t.stockQuantity.isSmallerOrEqual(t.lowStockThreshold)))
      .watch();
  }
}
