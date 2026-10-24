import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:bizpilotai/core/database/app_database.dart' as db;
import 'package:bizpilotai/features/invoices/data/data_sources/invoice_local_data_source.dart';
import 'package:bizpilotai/features/invoices/data/repositories/invoice_repository_impl.dart';
import 'package:bizpilotai/features/invoices/domain/entities/invoice.dart';
import 'package:bizpilotai/features/invoices/domain/entities/payment.dart';
import 'package:bizpilotai/features/invoices/domain/entities/invoice_item.dart';
import 'package:bizpilotai/core/errors/result.dart';
import 'package:bizpilotai/core/errors/failure.dart';

void main() {
  late db.AppDatabase database;
  late InvoiceLocalDataSource datasource;
  late InvoiceRepositoryImpl repository;

  setUp(() {
    database = db.AppDatabase(NativeDatabase.memory(setup: (rawDb) {
      rawDb.execute('PRAGMA foreign_keys = ON;');
    }));
    datasource = InvoiceLocalDataSource(database);
    repository = InvoiceRepositoryImpl(datasource);
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> seedDependentData() async {
    await database.customSelect('SELECT 1').get(); // Trigger migrations

    // Seed Category and Product to fulfill FK constraints for Invoice Items
    await database
        .into(database.categories)
        .insert(db.CategoriesCompanion.insert(
          id: 'cat1',
          name: 'Cat 1',
          createdAt: 0,
          updatedAt: 0,
        ));
    await database.into(database.products).insert(db.ProductsCompanion.insert(
          id: 'prod1',
          name: 'Prod 1',
          sku: 'SKU1',
          categoryId: 'cat1',
          sellingPrice: 100.0,
          costPrice: 50.0,
          stockQuantity: const drift.Value(10),
          createdAt: 0,
          updatedAt: 0,
        ));
    // Seed Customer for Invoice
    await database.into(database.customers).insert(db.CustomersCompanion.insert(
          id: 'cust1',
          name: 'Cust 1',
          phone: '1234567890',
          totalOutstanding: const drift.Value(0.0),
          createdAt: 0,
          updatedAt: 0,
        ));
  }

  test(
      'createInvoice securely manages stock decrement and outputs correctly mapped DTOs',
      () async {
    await seedDependentData();

    final testInvoice = Invoice(
      id: 'inv1',
      invoiceNumber: 0,
      customerId: 'cust1',
      subtotal: 100.0,
      discountAmount: 0.0,
      discountType: 'FLAT',
      taxAmount: 0.0,
      taxType: 'FLAT',
      total: 100.0,
      paidAmount: 100.0,
      balanceAmount: 0.0,
      paymentStatus: 'PAID',
      status: 'ACTIVE',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      items: [
        InvoiceItem(
          id: 'item1',
          invoiceId: 'inv1',
          productId: 'prod1',
          productName: 'Prod 1',
          productSku: 'SKU1',
          unitPrice: 100.0,
          quantity: 2,
          lineTotal: 200.0,
          createdAt: DateTime.now(),
        )
      ],
    );

    final payment = Payment(
      id: 'pay1',
      invoiceId: 'inv1',
      amount: 100.0,
      method: 'CASH',
      createdAt: DateTime.now(),
    );

    final createResult = await repository
        .createInvoice(invoice: testInvoice, initialPayments: [payment]);
    expect(createResult, isA<Success<int>>());
    expect((createResult as Success<int>).data, 1000); // Base seq

    final getResult = await repository.getInvoiceById('inv1');
    expect(getResult, isA<Success<Invoice>>());

    final storedInvoice = (getResult as Success<Invoice>).data;
    expect(storedInvoice.items.length, 1);
    expect(storedInvoice.payments.length, 1);
    expect(storedInvoice.payments.first.amount, 100.0);

    // Verify product stock drops behind the scenes successfully
    final updatedProduct = await (database.select(database.products)
          ..where((t) => t.id.equals('prod1')))
        .getSingle();
    expect(updatedProduct.stockQuantity, 8);
  });

  test('voidInvoice reinstates stock and traps duplicate void calls', () async {
    await seedDependentData();

    final testInvoice = Invoice(
      id: 'inv2',
      invoiceNumber: 0,
      customerId: 'cust1',
      subtotal: 100.0,
      discountAmount: 0.0,
      discountType: 'FLAT',
      taxAmount: 0.0,
      taxType: 'FLAT',
      total: 100.0,
      paidAmount: 0.0,
      balanceAmount: 100.0,
      paymentStatus: 'UNPAID',
      status: 'ACTIVE',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      items: [
        InvoiceItem(
          id: 'item2',
          invoiceId: 'inv2',
          productId: 'prod1',
          productName: 'Prod 1',
          productSku: 'SKU1',
          unitPrice: 100.0,
          quantity: 2,
          lineTotal: 200.0,
          createdAt: DateTime.now(),
        )
      ],
    );

    await repository.createInvoice(invoice: testInvoice, initialPayments: []);

    // First Void - Success
    final voidResult1 = await repository.voidInvoice('inv2');
    expect(voidResult1, isA<Success<void>>());

    final updatedProduct = await (database.select(database.products)
          ..where((t) => t.id.equals('prod1')))
        .getSingle();
    expect(updatedProduct.stockQuantity, 10); // Restored from 8 -> 10

    // Second Void - Fails with Validation
    final voidResult2 = await repository.voidInvoice('inv2');
    expect(voidResult2, isA<FailureResult<void>>());
    expect((voidResult2 as FailureResult).failure, isA<ValidationFailure>());
  });

  test('addPayment traps overpayment exceeding invoice balance (BI-005)',
      () async {
    await seedDependentData();

    final testInvoice = Invoice(
      id: 'inv3',
      invoiceNumber: 0,
      customerId: 'cust1',
      subtotal: 100.0,
      discountAmount: 0.0,
      discountType: 'FLAT',
      taxAmount: 0.0,
      taxType: 'FLAT',
      total: 100.0,
      paidAmount: 0.0,
      balanceAmount: 100.0,
      paymentStatus: 'UNPAID',
      status: 'ACTIVE',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      items: [],
    );

    await repository.createInvoice(invoice: testInvoice, initialPayments: []);

    // Attempting payment exceeding invoice total (150 > 100)
    final overpayment = Payment(
      id: 'pay_over',
      invoiceId: 'inv3',
      amount: 150.0,
      method: 'CASH',
      createdAt: DateTime.now(),
    );

    final result = await repository.addPayment(overpayment);
    expect(result, isA<FailureResult<void>>());
    expect((result as FailureResult).failure, isA<ValidationFailure>());
  });

  test(
      'createInvoice rolls back completely when an invalid foreign key item is inserted',
      () async {
    await seedDependentData();

    final invalidInvoice = Invoice(
      id: 'inv_fail',
      invoiceNumber: 0,
      customerId: 'cust1',
      subtotal: 100.0,
      discountAmount: 0.0,
      discountType: 'FLAT',
      taxAmount: 0.0,
      taxType: 'FLAT',
      total: 100.0,
      paidAmount: 0.0,
      balanceAmount: 100.0,
      paymentStatus: 'UNPAID',
      status: 'ACTIVE',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      items: [
        InvoiceItem(
          id: 'item_invalid',
          invoiceId: 'inv_fail',
          productId: 'non_existent_prod',
          productName: 'Ghost Prod',
          productSku: 'GHOST',
          unitPrice: 100.0,
          quantity: 1,
          lineTotal: 100.0,
          createdAt: DateTime.now(),
        )
      ],
    );

    final result = await repository
        .createInvoice(invoice: invalidInvoice, initialPayments: []);
    expect(result, isA<FailureResult<int>>());

    // Verify invoice row was NOT created due to transaction rollback
    final allInvoices = await database.select(database.invoices).get();
    expect(allInvoices.any((i) => i.id == 'inv_fail'), isFalse);
  });
}
