import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bizpilotai/features/products/domain/entities/product.dart';
import 'package:bizpilotai/features/products/domain/repositories/product_repository.dart';
import 'package:bizpilotai/features/products/data/repositories/product_repository_impl.dart';

final watchLowStockProductsUseCaseProvider = Provider<WatchLowStockProductsUseCase>((ref) {
  return WatchLowStockProductsUseCase(ref.watch(productRepositoryProvider));
});

class WatchLowStockProductsUseCase {
  final ProductRepository _repository;

  WatchLowStockProductsUseCase(this._repository);

  Stream<List<Product>> call() {
    return _repository.watchLowStockProducts();
  }
}
