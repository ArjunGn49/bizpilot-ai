import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bizpilotai/core/errors/result.dart';
import 'package:bizpilotai/features/customers/domain/entities/customer.dart';
import 'package:bizpilotai/features/customers/domain/repositories/customer_repository.dart';
import 'package:bizpilotai/features/customers/data/repositories/customer_repository_impl.dart';

final searchCustomersUseCaseProvider = Provider<SearchCustomersUseCase>((ref) {
  return SearchCustomersUseCase(ref.watch(customerRepositoryProvider));
});

class SearchCustomersUseCase {
  final CustomerRepository _repository;

  SearchCustomersUseCase(this._repository);

  Future<Result<List<Customer>>> call(String query) async {
    final result = await _repository.getCustomers();
    return result.when(
      success: (customers) {
        final lowerQuery = query.toLowerCase();
        final filtered = customers.where((c) {
          return c.name.toLowerCase().contains(lowerQuery) || 
                 c.phone.toLowerCase().contains(lowerQuery) ||
                 (c.email != null && c.email!.toLowerCase().contains(lowerQuery));
        }).toList();
        return Result.success(filtered);
      },
      failure: (failure) => Result.failure(failure),
    );
  }
}
