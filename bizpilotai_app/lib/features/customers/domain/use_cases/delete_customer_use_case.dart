import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bizpilotai/core/errors/result.dart';
import 'package:bizpilotai/features/customers/domain/repositories/customer_repository.dart';
import 'package:bizpilotai/features/customers/data/repositories/customer_repository_impl.dart';

final deleteCustomerUseCaseProvider = Provider<DeleteCustomerUseCase>((ref) {
  return DeleteCustomerUseCase(ref.watch(customerRepositoryProvider));
});

class DeleteCustomerUseCase {
  final CustomerRepository _repository;

  DeleteCustomerUseCase(this._repository);

  Future<Result<void>> call(String id) {
    return _repository.deleteCustomer(id);
  }
}
