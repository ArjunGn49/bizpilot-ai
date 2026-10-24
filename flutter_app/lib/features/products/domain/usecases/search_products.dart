import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/core/errors/result.dart';
import 'package:flutter_app/features/products/domain/entities/product.dart';
import 'package:flutter_app/features/products/domain/repositories/product_repository.dart';
import 'package:flutter_app/features/products/data/repositories/product_repository_impl.dart';

final searchProductsUseCaseProvider = Provider<SearchProducts>((ref) {
  return SearchProducts(ref.watch(productRepositoryProvider));
});

class SearchProducts {
  final ProductRepository _repository;

  SearchProducts(this._repository);

  Future<Result<List<Product>>> call(String query) async {
    // In Phase 1, we pull all products and filter locally for simplicity.
    // As datasets grow, this could move down to a full text DB query via Drift.
    final result = await _repository.getProducts();
    return result.when(
      success: (products) {
        final lowerQuery = query.toLowerCase();
        final filtered = products.where((p) {
          return p.name.toLowerCase().contains(lowerQuery) || 
                 p.sku.toLowerCase().contains(lowerQuery) ||
                 (p.barcode != null && p.barcode!.toLowerCase().contains(lowerQuery));
        }).toList();
        return Result.success(filtered);
      },
      failure: (failure) => Result.failure(failure),
    );
  }
}
