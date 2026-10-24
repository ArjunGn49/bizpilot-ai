import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bizpilotai/core/errors/failure.dart';
import 'package:bizpilotai/core/errors/result.dart';
import 'package:bizpilotai/features/products/domain/entities/product.dart';
import 'package:bizpilotai/features/products/domain/entities/category.dart';
import 'package:bizpilotai/features/products/domain/repositories/product_repository.dart';
import 'package:bizpilotai/features/products/data/data_sources/product_local_data_source.dart';
import 'package:bizpilotai/features/products/data/dto/product_dto.dart';
import 'package:bizpilotai/features/products/data/dto/category_dto.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(ref.watch(productLocalDataSourceProvider));
});

class ProductRepositoryImpl implements ProductRepository {
  final ProductLocalDataSource _local;

  ProductRepositoryImpl(this._local);

  @override
  Future<Result<List<Product>>> getProducts() async {
    try {
      final dtos = await _local.getProducts();
      return Result.success(dtos.map((d) => d.toDomain()).toList());
    } catch (e) {
      return Result.failure(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<Product>> getProductById(String id) async {
    try {
      final dto = await _local.getProductById(id);
      return Result.success(dto.toDomain());
    } catch (e) {
      return Result.failure(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> addProduct(Product product) async {
    try {
      await _local.insertProduct(product.toTableCompanion());
      return const Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> updateProduct(Product product) async {
    try {
      await _local.updateProduct(product.toTableCompanion());
      return const Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteProduct(String id) async {
    try {
      await _local.softDeleteProduct(id);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseFailure(e.toString()));
    }
  }

  @override
  Stream<List<Product>> watchProducts() {
    return _local.watchProducts().map((list) => list.map((d) => d.toDomain()).toList());
  }

  @override
  Stream<List<Product>> watchLowStockProducts() {
    return _local.watchLowStockProducts().map((list) => list.map((d) => d.toDomain()).toList());
  }

  @override
  Future<Result<List<Category>>> getCategories() async {
    try {
      final dtos = await _local.getCategories();
      return Result.success(dtos.map((d) => d.toDomain()).toList());
    } catch (e) {
      return Result.failure(DatabaseFailure(e.toString()));
    }
  }
}
