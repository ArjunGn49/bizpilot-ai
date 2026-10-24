import 'package:flutter_test/flutter_test.dart';
import 'package:bizpilotai/core/errors/result.dart';
import 'package:bizpilotai/core/errors/failure.dart';
import 'package:bizpilotai/features/customers/domain/entities/customer.dart';
import 'package:bizpilotai/features/customers/domain/repositories/customer_repository.dart';
import 'package:bizpilotai/features/customers/domain/use_cases/delete_customer_use_case.dart';
import 'package:bizpilotai/features/customers/domain/use_cases/get_customers_use_case.dart';
import 'package:bizpilotai/features/customers/domain/use_cases/search_customers_use_case.dart';

class FakeCustomerRepository extends Fake implements CustomerRepository {
  bool shouldFail = false;
  final List<Customer> mockDB = [
    Customer(
      id: 'c1', name: 'John Doe', phone: '1234567890', email: 'john@example.com',
      totalOutstanding: 0.0, isDeleted: false, createdAt: DateTime.now(), updatedAt: DateTime.now(),
    ),
    Customer(
      id: 'c2', name: 'Jane Smith', phone: '0987654321',
      totalOutstanding: 50.0, isDeleted: false, createdAt: DateTime.now(), updatedAt: DateTime.now(),
    )
  ];

  @override
  Future<Result<List<Customer>>> getCustomers() async {
    if (shouldFail) return const Result.failure(DatabaseFailure('DB Error'));
    return Result.success(mockDB);
  }

  @override
  Future<Result<void>> addCustomer(Customer customer) async {
    if (shouldFail) return const Result.failure(DatabaseFailure('DB Error'));
    return const Result.success(null);
  }

  @override
  Future<Result<void>> updateCustomer(Customer customer) async {
    if (shouldFail) return const Result.failure(DatabaseFailure('DB Error'));
    return const Result.success(null);
  }

  @override
  Future<Result<void>> deleteCustomer(String id) async {
    if (shouldFail) return const Result.failure(ValidationFailure('Cannot delete'));
    return const Result.success(null);
  }
}

void main() {
  late FakeCustomerRepository fakeRepo;

  setUp(() {
    fakeRepo = FakeCustomerRepository();
  });

  group('GetCustomersUseCase', () {
    test('Returns customer list successfully', () async {
      final useCase = GetCustomersUseCase(fakeRepo);
      final result = await useCase.call();
      
      expect(result, isA<Success<List<Customer>>>());
      expect((result as Success<List<Customer>>).data.length, 2);
    });

    test('Propagates failure', () async {
      fakeRepo.shouldFail = true;
      final useCase = GetCustomersUseCase(fakeRepo);
      final result = await useCase.call();
      
      expect(result, isA<FailureResult<List<Customer>>>());
    });
  });

  group('SearchCustomersUseCase', () {
    test('Filters returned customers locally by name or phone', () async {
      final useCase = SearchCustomersUseCase(fakeRepo);
      final result = await useCase.call('Jane');
      
      expect(result, isA<Success<List<Customer>>>());
      final items = (result as Success<List<Customer>>).data;
      expect(items.length, 1);
      expect(items.first.name, 'Jane Smith');
    });
  });

  group('DeleteCustomerUseCase', () {
    test('Propagates validation failure correctly', () async {
      fakeRepo.shouldFail = true;
      final useCase = DeleteCustomerUseCase(fakeRepo);
      final result = await useCase.call('c1');
      
      expect(result, isA<FailureResult<void>>());
      expect((result as FailureResult).failure, isA<ValidationFailure>());
    });
  });
}
