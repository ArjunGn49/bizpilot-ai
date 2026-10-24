import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bizpilotai/features/products/domain/entities/product.dart';
import 'package:bizpilotai/features/products/domain/use_cases/add_product_use_case.dart';
import 'package:bizpilotai/features/products/domain/use_cases/update_product_use_case.dart';
import 'package:bizpilotai/features/products/domain/use_cases/delete_product_use_case.dart';

final productControllerProvider = NotifierProvider.autoDispose<ProductController, AsyncValue<void>>(
  ProductController.new,
);

class ProductController extends AutoDisposeNotifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<void> addProduct(Product product) async {
    state = const AsyncValue.loading();
    final result = await ref.read(addProductUseCaseProvider).call(product);
    result.when(
      success: (_) {
        state = const AsyncValue.data(null);
      },
      failure: (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
      },
    );
  }

  Future<void> updateProduct(Product product) async {
    state = const AsyncValue.loading();
    final result = await ref.read(updateProductUseCaseProvider).call(product);
    result.when(
      success: (_) {
        state = const AsyncValue.data(null);
      },
      failure: (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
      },
    );
  }

  Future<void> deleteProduct(String id) async {
    state = const AsyncValue.loading();
    final result = await ref.read(deleteProductUseCaseProvider).call(id);
    result.when(
      success: (_) {
        state = const AsyncValue.data(null);
      },
      failure: (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
      },
    );
  }
}
