import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/features/products/domain/entities/product.dart';
import 'package:flutter_app/features/products/domain/repositories/product_repository.dart';
import 'package:flutter_app/features/products/data/repositories/product_repository_impl.dart';

final watchLowStockProductsUseCaseProvider = Provider<WatchLowStockProducts>((ref) {
  return WatchLowStockProducts(ref.watch(productRepositoryProvider));
});

class WatchLowStockProducts {
  final ProductRepository _repository;

  WatchLowStockProducts(this._repository);

  Stream<List<Product>> call() {
    return _repository.watchLowStockProducts();
  }
}
