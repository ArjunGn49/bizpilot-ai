import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bizpilotai/features/customers/domain/entities/customer.dart';
import 'package:bizpilotai/features/customers/domain/use_cases/add_customer_use_case.dart';
import 'package:bizpilotai/features/customers/domain/use_cases/update_customer_use_case.dart';
import 'package:bizpilotai/features/customers/domain/use_cases/delete_customer_use_case.dart';

final customerControllerProvider = NotifierProvider.autoDispose<CustomerController, AsyncValue<void>>(
  CustomerController.new,
);

class CustomerController extends AutoDisposeNotifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<void> addCustomer(Customer customer) async {
    state = const AsyncValue.loading();
    final result = await ref.read(addCustomerUseCaseProvider).call(customer);
    result.when(
      success: (_) {
        state = const AsyncValue.data(null);
      },
      failure: (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
      },
    );
  }

  Future<void> updateCustomer(Customer customer) async {
    state = const AsyncValue.loading();
    final result = await ref.read(updateCustomerUseCaseProvider).call(customer);
    result.when(
      success: (_) {
        state = const AsyncValue.data(null);
      },
      failure: (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
      },
    );
  }

  Future<void> deleteCustomer(String id) async {
    state = const AsyncValue.loading();
    final result = await ref.read(deleteCustomerUseCaseProvider).call(id);
    result.when(
      success: (_) {
        state = const AsyncValue.data(null);
      },
      failure: (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
      },
    );
  }
}
