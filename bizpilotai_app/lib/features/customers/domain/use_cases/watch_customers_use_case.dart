import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bizpilotai/features/customers/domain/entities/customer.dart';
import 'package:bizpilotai/features/customers/domain/repositories/customer_repository.dart';
import 'package:bizpilotai/features/customers/data/repositories/customer_repository_impl.dart';

final watchCustomersUseCaseProvider = Provider<WatchCustomersUseCase>((ref) {
  return WatchCustomersUseCase(ref.watch(customerRepositoryProvider));
});

class WatchCustomersUseCase {
  final CustomerRepository _repository;

  WatchCustomersUseCase(this._repository);

  Stream<List<Customer>> call() {
    return _repository.watchCustomers();
  }
}
