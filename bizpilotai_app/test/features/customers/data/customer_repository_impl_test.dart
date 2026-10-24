import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:bizpilotai/core/database/app_database.dart' as db;
import 'package:bizpilotai/features/customers/data/data_sources/customer_local_data_source.dart';
import 'package:bizpilotai/features/customers/data/repositories/customer_repository_impl.dart';
import 'package:bizpilotai/features/customers/domain/entities/customer.dart';
import 'package:bizpilotai/core/errors/result.dart';
import 'package:bizpilotai/core/errors/failure.dart';

void main() {
  late db.AppDatabase database;
  late CustomerLocalDataSource datasource;
  late CustomerRepositoryImpl repository;

  setUp(() {
    database = db.AppDatabase(NativeDatabase.memory(setup: (rawDb) {
      rawDb.execute('PRAGMA foreign_keys = ON;');
    }));
    datasource = CustomerLocalDataSource(database);
    repository = CustomerRepositoryImpl(datasource);
  });

  tearDown(() async {
    await database.close();
  });

  test('addCustomer and getCustomers works via repository and DTO mappers', () async {
    final customer = Customer(
      id: 'c1',
      name: 'Test Customer',
      phone: '1234567890',
      totalOutstanding: 0.0,
      isDeleted: false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
    );
    
    // Add customer
    final addResult = await repository.addCustomer(customer);
    expect(addResult, isA<Success<void>>());

    // Get customers
    final getResult = await repository.getCustomers();
    expect(getResult, isA<Success<List<Customer>>>());
    final customers = (getResult as Success<List<Customer>>).data;
    expect(customers.length, 1);
    expect(customers.first.id, 'c1');
    expect(customers.first.name, 'Test Customer');
  });

  test('addCustomer maps unique constraint violation to ValidationFailure', () async {
    final customer1 = Customer(
      id: 'c1', name: 'Cust 1', phone: '1234567890', totalOutstanding: 0.0,
      isDeleted: false, createdAt: DateTime.now(), updatedAt: DateTime.now(),
    );
    
    final customer2 = Customer(
      id: 'c2', name: 'Cust 2', phone: '1234567890', totalOutstanding: 0.0, // Same phone
      isDeleted: false, createdAt: DateTime.now(), updatedAt: DateTime.now(),
    );
    
    await repository.addCustomer(customer1);
    final addResult2 = await repository.addCustomer(customer2);
    
    expect(addResult2, isA<FailureResult<void>>());
    final failure = (addResult2 as FailureResult<void>).failure;
    expect(failure, isA<ValidationFailure>());
    expect(failure.message, 'A customer with this phone number already exists.');
  });

  test('deleteCustomer blocks deletion if invoices are linked (BI-004)', () async {
    // 1. Setup seed data
    await database.customSelect('SELECT 1').get(); // Trigger migrations
    
    final customer = Customer(
      id: 'c1', name: 'Cust 1', phone: '1234567890', totalOutstanding: 0.0,
      isDeleted: false, createdAt: DateTime.now(), updatedAt: DateTime.now(),
    );
    await repository.addCustomer(customer);
    
    // 2. Insert a linked invoice manually
    await database.into(database.invoices).insert(db.InvoicesCompanion.insert(
      id: 'inv1',
      invoiceNumber: 999,
      customerId: const drift.Value('c1'),
      subtotal: 10.0,
      total: 10.0,
      balanceAmount: 10.0,
      paymentStatus: 'UNPAID',
      createdAt: 0,
      updatedAt: 0,
    ));

    // 3. Attempt to delete
    final delResult = await repository.deleteCustomer('c1');
    
    expect(delResult, isA<FailureResult<void>>());
    final failure = (delResult as FailureResult<void>).failure;
    expect(failure, isA<ValidationFailure>());
    expect(failure.message, 'Cannot delete a customer with linked invoices.');
  });

  test('deleteCustomer performs soft delete when no invoices linked', () async {
    final customer = Customer(
      id: 'c2', name: 'Cust 2', phone: '0987654321', totalOutstanding: 0.0,
      isDeleted: false, createdAt: DateTime.now(), updatedAt: DateTime.now(),
    );
    await repository.addCustomer(customer);
    
    final delResult = await repository.deleteCustomer('c2');
    expect(delResult, isA<Success<void>>());

    final getResult = await repository.getCustomers();
    final customers = (getResult as Success<List<Customer>>).data;
    expect(customers.isEmpty, true);
  });
}
