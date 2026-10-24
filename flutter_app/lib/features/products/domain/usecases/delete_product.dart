import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/core/errors/result.dart';
import 'package:flutter_app/features/products/domain/repositories/product_repository.dart';
import 'package:flutter_app/features/products/data/repositories/product_repository_impl.dart';

final deleteProductUseCaseProvider = Provider<DeleteProduct>((ref) {
  return DeleteProduct(ref.watch(productRepositoryProvider));
});

class DeleteProduct {
  final ProductRepository _repository;

  DeleteProduct(this._repository);

  Future<Result<void>> call(String id) {
    return _repository.deleteProduct(id);
  }
}
