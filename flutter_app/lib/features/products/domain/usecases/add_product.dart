import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/core/errors/result.dart';
import 'package:flutter_app/features/products/domain/entities/product.dart';
import 'package:flutter_app/features/products/domain/repositories/product_repository.dart';
import 'package:flutter_app/features/products/data/repositories/product_repository_impl.dart';

final addProductUseCaseProvider = Provider<AddProduct>((ref) {
  return AddProduct(ref.watch(productRepositoryProvider));
});

class AddProduct {
  final ProductRepository _repository;

  AddProduct(this._repository);

  Future<Result<void>> call(Product product) {
    return _repository.addProduct(product);
  }
}
