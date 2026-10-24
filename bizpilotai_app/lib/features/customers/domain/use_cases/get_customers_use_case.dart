import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bizpilotai/core/errors/result.dart';
import 'package:bizpilotai/features/customers/domain/entities/customer.dart';
import 'package:bizpilotai/features/customers/domain/repositories/customer_repository.dart';
import 'package:bizpilotai/features/customers/data/repositories/customer_repository_impl.dart';

final getCustomersUseCaseProvider = Provider<GetCustomersUseCase>((ref) {
  return GetCustomersUseCase(ref.watch(customerRepositoryProvider));
});

class GetCustomersUseCase {
  final CustomerRepository _repository;

  GetCustomersUseCase(this._repository);

  Future<Result<List<Customer>>> call() {
    return _repository.getCustomers();
  }
}
