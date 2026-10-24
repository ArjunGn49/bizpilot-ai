import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bizpilotai/features/products/domain/entities/product.dart';
import 'package:bizpilotai/features/products/domain/use_cases/watch_products_use_case.dart';
import 'package:bizpilotai/features/products/domain/use_cases/watch_low_stock_products_use_case.dart';

final productsProvider = StreamProvider.autoDispose<List<Product>>((ref) {
  return ref.watch(watchProductsUseCaseProvider).call();
});

final lowStockProductsProvider = StreamProvider.autoDispose<List<Product>>((ref) {
  return ref.watch(watchLowStockProductsUseCaseProvider).call();
});

final productDetailProvider = StreamProvider.autoDispose.family<Product?, String>((ref, id) {
  return ref.watch(watchProductsUseCaseProvider).call().map((products) {
    try {
      return products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  });
});
