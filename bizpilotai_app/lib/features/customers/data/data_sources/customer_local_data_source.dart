import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bizpilotai/core/database/app_database.dart' as db;
import 'package:bizpilotai/core/database/database_provider.dart';

final customerLocalDataSourceProvider = Provider<CustomerLocalDataSource>((ref) {
  return CustomerLocalDataSource(ref.watch(databaseProvider));
});

class CustomerLocalDataSource {
  final db.AppDatabase _db;

  CustomerLocalDataSource(this._db);

  Future<List<db.Customer>> getCustomers() {
    return (_db.select(_db.customers)..where((t) => t.isDeleted.equals(0))).get();
  }

  Future<db.Customer> getCustomerById(String id) {
    return (_db.select(_db.customers)..where((t) => t.id.equals(id))).getSingle();
  }

  Future<void> insertCustomer(db.CustomersCompanion customer) {
    return _db.into(_db.customers).insert(customer);
  }

  Future<void> updateCustomer(db.CustomersCompanion customer) {
    return (_db.update(_db.customers)..where((t) => t.id.equals(customer.id.value))).write(customer);
  }

  Future<void> softDeleteCustomer(String id) async {
    // Check if customer has linked invoices (BI-004)
    final linkedInvoices = await (_db.select(_db.invoices)..where((t) => t.customerId.equals(id))).get();
    
    if (linkedInvoices.isNotEmpty) {
      throw StateError('Cannot delete a customer with linked invoices.');
    }

    await (_db.update(_db.customers)..where((t) => t.id.equals(id))).write(
      db.CustomersCompanion(
        isDeleted: const Value(1),
        deletedAt: Value(DateTime.now().millisecondsSinceEpoch),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  Stream<List<db.Customer>> watchCustomers() {
    return (_db.select(_db.customers)..where((t) => t.isDeleted.equals(0))).watch();
  }
}
