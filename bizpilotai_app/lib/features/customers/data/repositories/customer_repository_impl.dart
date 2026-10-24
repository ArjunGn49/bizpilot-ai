import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bizpilotai/core/errors/failure.dart';
import 'package:bizpilotai/core/errors/result.dart';
import 'package:bizpilotai/features/customers/domain/entities/customer.dart';
import 'package:bizpilotai/features/customers/domain/repositories/customer_repository.dart';
import 'package:bizpilotai/features/customers/data/data_sources/customer_local_data_source.dart';
import 'package:bizpilotai/features/customers/data/dto/customer_dto.dart';

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepositoryImpl(ref.watch(customerLocalDataSourceProvider));
});

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerLocalDataSource _local;

  CustomerRepositoryImpl(this._local);

  @override
  Future<Result<List<Customer>>> getCustomers() async {
    try {
      final dtos = await _local.getCustomers();
      return Result.success(dtos.map((d) => d.toDomain()).toList());
    } catch (e) {
      return Result.failure(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<Customer>> getCustomerById(String id) async {
    try {
      final dto = await _local.getCustomerById(id);
      return Result.success(dto.toDomain());
    } catch (e) {
      return Result.failure(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> addCustomer(Customer customer) async {
    try {
      await _local.insertCustomer(customer.toTableCompanion());
      return const Result.success(null);
    } catch (e) {
      // Drift throws when a UNIQUE constraint (like phone number) is violated
      if (e.toString().contains('UNIQUE constraint failed')) {
        return const Result.failure(ValidationFailure('A customer with this phone number already exists.'));
      }
      return Result.failure(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> updateCustomer(Customer customer) async {
    try {
      await _local.updateCustomer(customer.toTableCompanion());
      return const Result.success(null);
    } catch (e) {
      if (e.toString().contains('UNIQUE constraint failed')) {
        return const Result.failure(ValidationFailure('A customer with this phone number already exists.'));
      }
      return Result.failure(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteCustomer(String id) async {
    try {
      await _local.softDeleteCustomer(id);
      return const Result.success(null);
    } catch (e) {
      if (e is StateError) {
        return Result.failure(ValidationFailure(e.message)); // Covers BI-004 logic
      }
      return Result.failure(DatabaseFailure(e.toString()));
    }
  }

  @override
  Stream<List<Customer>> watchCustomers() {
    return _local.watchCustomers().map((list) => list.map((d) => d.toDomain()).toList());
  }
}
