import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/core/errors/result.dart';
import 'package:flutter_app/features/products/domain/entities/category.dart';
import 'package:flutter_app/features/products/domain/repositories/product_repository.dart';
import 'package:flutter_app/features/products/data/repositories/product_repository_impl.dart';

final getCategoriesUseCaseProvider = Provider<GetCategories>((ref) {
  return GetCategories(ref.watch(productRepositoryProvider));
});

class GetCategories {
  final ProductRepository _repository;

  GetCategories(this._repository);

  Future<Result<List<Category>>> call() {
    return _repository.getCategories();
  }
}
