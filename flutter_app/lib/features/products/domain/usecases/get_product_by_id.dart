import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/core/errors/result.dart';
import 'package:flutter_app/features/products/domain/entities/product.dart';
import 'package:flutter_app/features/products/domain/repositories/product_repository.dart';
import 'package:flutter_app/features/products/data/repositories/product_repository_impl.dart';

final getProductByIdUseCaseProvider = Provider<GetProductById>((ref) {
  return GetProductById(ref.watch(productRepositoryProvider));
});

class GetProductById {
  final ProductRepository _repository;

  GetProductById(this._repository);

  Future<Result<Product>> call(String id) {
    return _repository.getProductById(id);
  }
}
