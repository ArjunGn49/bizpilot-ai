import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_app/core/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory(setup: (rawDb) {
      rawDb.execute('PRAGMA foreign_keys = ON;');
    }));
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> seedDatabase() async {
    // A simple query to trigger onCreate migrations to run (inserts settings & categories)
    await db.customSelect('SELECT 1').get();

    // Insert Category separately to ensure referential integrity if foreign keys are enabled
    // This MUST be inserted before the Product that references it
    await db.into(db.categories).insert(CategoriesCompanion.insert(
      id: 'cat-1',
      name: 'Test Category',
      createdAt: 0,
      updatedAt: 0,
    ));

    // Insert Product
    await db.into(db.products).insert(ProductsCompanion.insert(
      id: 'prod-1',
      name: 'Test Product',
      sku: 'SKU-1',
      categoryId: 'cat-1',
      sellingPrice: 100.0,
      costPrice: 50.0,
      stockQuantity: const Value(10),
      createdAt: 0,
      updatedAt: 0,
    ));

    // Insert Customer
    await db.into(db.customers).insert(CustomersCompanion.insert(
      id: 'cust-1',
      name: 'Test Customer',
      phone: '1234567890',
      totalOutstanding: const Value(0.0),
      createdAt: 0,
      updatedAt: 0,
    ));
  }

  test('createInvoiceTx decrements stock and increments sequence', () async {
    await seedDatabase();

    const invoiceId = 'inv-1';
    final assignedNumber = await db.createInvoiceTx(
      invoice: InvoicesCompanion.insert(
        id: invoiceId,
        customerId: const Value('cust-1'),
        invoiceNumber: 0, // Gets overwritten inside tx by sequence
        subtotal: 200.0, // Match line totals
        total: 200.0,    // Match line totals
        balanceAmount: 200.0,
        paymentStatus: 'UNPAID',
        createdAt: 0,
        updatedAt: 0,
      ),
      items: [
        InvoiceItemsCompanion.insert(
          id: 'item-1',
          invoiceId: invoiceId,
          productId: 'prod-1',
          productName: 'Test Product',
          productSku: 'SKU-1',
          unitPrice: 100.0,
          quantity: 2,
          lineTotal: 200.0,
          createdAt: 0,
        )
      ],
      movements: [
        StockMovementsCompanion.insert(
          id: 'mov-1',
          productId: 'prod-1',
          type: 'OUT',
          quantity: -2,
          referenceId: const Value(invoiceId),
          createdAt: 0,
        )
      ],
    );

    // Default migration inserts '1000' for sequence, so first invoice is 1000
    expect(assignedNumber, 1000);

    // Verify settings sequence incremented
    final seqSetting = await (db.select(db.settings)..where((t) => t.key.equals('invoice_number_sequence'))).getSingle();
    expect(seqSetting.value, '1001');

    // Verify product stock decremented
    final updatedProduct = await (db.select(db.products)..where((t) => t.id.equals('prod-1'))).getSingle();
    expect(updatedProduct.stockQuantity, 8); // 10 initial + (-2) = 8
  });

  test('addPaymentTx exceeding total throws ArgumentError', () async {
    await seedDatabase();

    // Create an invoice manually for testing payment logic
    await db.into(db.invoices).insert(InvoicesCompanion.insert(
      id: 'inv-2',
      invoiceNumber: 1001,
      total: 100.0,
      subtotal: 100.0,
      balanceAmount: 100.0,
      paymentStatus: 'UNPAID',
      createdAt: 0,
      updatedAt: 0,
    ));

    await expectLater(
      db.addPaymentTx(PaymentsCompanion.insert(
        id: 'pay-1',
        invoiceId: 'inv-2',
        amount: 150.0, // Exceeds total of 100.0
        createdAt: 0,
      )),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('voidInvoiceTx restores stock and decrements customer outstanding', () async {
    await seedDatabase();

    // Setup an invoice directly
    const invoiceId = 'inv-3';
    await db.into(db.invoices).insert(InvoicesCompanion.insert(
      id: invoiceId,
      invoiceNumber: 1002,
      customerId: const Value('cust-1'),
      total: 100.0,
      subtotal: 100.0,
      balanceAmount: 100.0,
      paymentStatus: 'UNPAID',
      createdAt: 0,
      updatedAt: 0,
    ));

    // Give customer some initial outstanding balance
    await (db.update(db.customers)..where((t) => t.id.equals('cust-1'))).write(
      const CustomersCompanion(totalOutstanding: Value(100.0)),
    );

    // Void the invoice
    await db.voidInvoiceTx(invoiceId, [
      StockMovementsCompanion.insert(
        id: 'mov-2',
        productId: 'prod-1',
        type: 'IN',
        quantity: 2,
        reason: const Value('CORRECTION'),
        createdAt: 0,
      )
    ]);

    // Verify stock restored
    final updatedProduct = await (db.select(db.products)..where((t) => t.id.equals('prod-1'))).getSingle();
    expect(updatedProduct.stockQuantity, 12); // 10 initial + 2 = 12

    // Verify customer outstanding decremented
    final updatedCustomer = await (db.select(db.customers)..where((t) => t.id.equals('cust-1'))).getSingle();
    expect(updatedCustomer.totalOutstanding, 0.0); // 100 initial - 100 from void = 0
  });
}
