import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bizpilotai/core/errors/result.dart';
import 'package:bizpilotai/features/customers/domain/entities/customer.dart';
import 'package:bizpilotai/features/customers/domain/repositories/customer_repository.dart';
import 'package:bizpilotai/features/customers/data/repositories/customer_repository_impl.dart';

final updateCustomerUseCaseProvider = Provider<UpdateCustomerUseCase>((ref) {
  return UpdateCustomerUseCase(ref.watch(customerRepositoryProvider));
});

class UpdateCustomerUseCase {
  final CustomerRepository _repository;

  UpdateCustomerUseCase(this._repository);

  Future<Result<void>> call(Customer customer) {
    return _repository.updateCustomer(customer);
  }
}
