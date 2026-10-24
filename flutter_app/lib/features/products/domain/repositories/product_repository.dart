import 'package:flutter_app/core/errors/result.dart';
import 'package:flutter_app/features/products/domain/entities/product.dart';
import 'package:flutter_app/features/products/domain/entities/category.dart';

abstract class ProductRepository {
  Future<Result<List<Product>>> getProducts();
  Future<Result<Product>> getProductById(String id);
  Future<Result<void>> addProduct(Product product);
  Future<Result<void>> updateProduct(Product product);
  Future<Result<void>> deleteProduct(String id);
  Stream<List<Product>> watchProducts();
  Stream<List<Product>> watchLowStockProducts();
  
  // Handled here as part of Product Aggregate management
  Future<Result<List<Category>>> getCategories();
}
