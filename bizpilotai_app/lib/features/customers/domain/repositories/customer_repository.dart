import 'package:bizpilotai/core/errors/result.dart';
import 'package:bizpilotai/features/customers/domain/entities/customer.dart';

abstract class CustomerRepository {
  Future<Result<List<Customer>>> getCustomers();
  Future<Result<Customer>> getCustomerById(String id);
  Future<Result<void>> addCustomer(Customer customer);
  Future<Result<void>> updateCustomer(Customer customer);
  Future<Result<void>> deleteCustomer(String id);
  Stream<List<Customer>> watchCustomers();
}
