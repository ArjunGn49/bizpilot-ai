import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bizpilotai/features/products/domain/entities/product.dart';
import 'package:bizpilotai/features/products/domain/repositories/product_repository.dart';
import 'package:bizpilotai/features/products/data/repositories/product_repository_impl.dart';

final watchProductsUseCaseProvider = Provider<WatchProductsUseCase>((ref) {
  return WatchProductsUseCase(ref.watch(productRepositoryProvider));
});

class WatchProductsUseCase {
  final ProductRepository _repository;

  WatchProductsUseCase(this._repository);

  Stream<List<Product>> call() {
    return _repository.watchProducts();
  }
}
