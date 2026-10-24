import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/features/products/domain/entities/product.dart';
import 'package:flutter_app/features/products/domain/repositories/product_repository.dart';
import 'package:flutter_app/features/products/data/repositories/product_repository_impl.dart';

final watchProductsUseCaseProvider = Provider<WatchProducts>((ref) {
  return WatchProducts(ref.watch(productRepositoryProvider));
});

class WatchProducts {
  final ProductRepository _repository;

  WatchProducts(this._repository);

  Stream<List<Product>> call() {
    return _repository.watchProducts();
  }
}
