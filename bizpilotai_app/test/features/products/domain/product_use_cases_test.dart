import 'package:flutter_test/flutter_test.dart';
import 'package:bizpilotai/core/errors/result.dart';
import 'package:bizpilotai/core/errors/failure.dart';
import 'package:bizpilotai/features/products/domain/entities/product.dart';
import 'package:bizpilotai/features/products/domain/repositories/product_repository.dart';
import 'package:bizpilotai/features/products/domain/use_cases/get_products_use_case.dart';
import 'package:bizpilotai/features/products/domain/use_cases/search_products_use_case.dart';

class FakeProductRepository extends Fake implements ProductRepository {
  bool shouldFail = false;
  final List<Product> mockDB = [
    Product(
      id: 'p1', name: 'iPhone 15', sku: 'IP15', categoryId: 'c1',
      sellingPrice: 999.0, costPrice: 800.0, stockQuantity: 10, lowStockThreshold: 5,
      isDeleted: false, createdAt: DateTime.now(), updatedAt: DateTime.now(),
    ),
    Product(
      id: 'p2', name: 'Galaxy S24', sku: 'GS24', categoryId: 'c1',
      sellingPrice: 899.0, costPrice: 700.0, stockQuantity: 8, lowStockThreshold: 5,
      isDeleted: false, createdAt: DateTime.now(), updatedAt: DateTime.now(),
    )
  ];

  @override
  Future<Result<List<Product>>> getProducts() async {
    if (shouldFail) return const Result.failure(DatabaseFailure('DB Error'));
    return Result.success(mockDB);
  }

  @override
  Future<Result<void>> addProduct(Product product) async {
    if (shouldFail) return const Result.failure(DatabaseFailure('DB Error'));
    return const Result.success(null);
  }

  @override
  Future<Result<void>> updateProduct(Product product) async {
    if (shouldFail) return const Result.failure(DatabaseFailure('DB Error'));
    return const Result.success(null);
  }

  @override
  Future<Result<void>> deleteProduct(String id) async {
    if (shouldFail) return const Result.failure(DatabaseFailure('DB Error'));
    return const Result.success(null);
  }
}

void main() {
  late FakeProductRepository fakeRepo;

  setUp(() {
    fakeRepo = FakeProductRepository();
  });

  group('GetProducts UseCase', () {
    test('Returns product list successfully', () async {
      final useCase = GetProductsUseCase(fakeRepo);
      final result = await useCase.call();
      
      expect(result, isA<Success<List<Product>>>());
      expect((result as Success<List<Product>>).data.length, 2);
    });

    test('Propagates failure', () async {
      fakeRepo.shouldFail = true;
      final useCase = GetProductsUseCase(fakeRepo);
      final result = await useCase.call();
      
      expect(result, isA<FailureResult<List<Product>>>());
    });
  });

  group('SearchProducts UseCase', () {
    test('Filters returned products locally by name or sku', () async {
      final useCase = SearchProductsUseCase(fakeRepo);
      final result = await useCase.call('Galaxy');
      
      expect(result, isA<Success<List<Product>>>());
      final items = (result as Success<List<Product>>).data;
      expect(items.length, 1);
      expect(items.first.name, 'Galaxy S24');
    });
  });
}
