import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bizpilotai/features/products/domain/entities/category.dart';
import 'package:bizpilotai/features/products/domain/use_cases/get_categories_use_case.dart';

final categoriesProvider = FutureProvider.autoDispose<List<Category>>((ref) async {
  final result = await ref.watch(getCategoriesUseCaseProvider).call();
  return result.when(
    success: (categories) => categories,
    failure: (failure) => throw Exception(failure.message),
  );
});
