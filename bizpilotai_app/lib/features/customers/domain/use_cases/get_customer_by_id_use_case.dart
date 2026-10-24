import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bizpilotai/core/errors/result.dart';
import 'package:bizpilotai/features/customers/domain/entities/customer.dart';
import 'package:bizpilotai/features/customers/domain/repositories/customer_repository.dart';
import 'package:bizpilotai/features/customers/data/repositories/customer_repository_impl.dart';

final getCustomerByIdUseCaseProvider = Provider<GetCustomerByIdUseCase>((ref) {
  return GetCustomerByIdUseCase(ref.watch(customerRepositoryProvider));
});

class GetCustomerByIdUseCase {
  final CustomerRepository _repository;

  GetCustomerByIdUseCase(this._repository);

  Future<Result<Customer>> call(String id) {
    return _repository.getCustomerById(id);
  }
}
