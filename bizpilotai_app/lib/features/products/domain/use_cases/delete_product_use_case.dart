import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bizpilotai/core/errors/result.dart';
import 'package:bizpilotai/features/products/domain/repositories/product_repository.dart';
import 'package:bizpilotai/features/products/data/repositories/product_repository_impl.dart';

final deleteProductUseCaseProvider = Provider<DeleteProductUseCase>((ref) {
  return DeleteProductUseCase(ref.watch(productRepositoryProvider));
});

class DeleteProductUseCase {
  final ProductRepository _repository;

  DeleteProductUseCase(this._repository);

  Future<Result<void>> call(String id) {
    return _repository.deleteProduct(id);
  }
}
