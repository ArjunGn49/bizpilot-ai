import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_app/core/security/secure_key_store.dart';
import 'database_opener.dart';

part 'app_database.g.dart';

class Users extends Table {
  TextColumn get id => text()(); // Firebase UID
  TextColumn get email => text()();
  TextColumn get businessName => text()();
  TextColumn get businessPhone => text().nullable()();
  TextColumn get businessAddress => text().nullable()();
  TextColumn get currencySymbol => text().withDefault(const Constant('₹'))();
  TextColumn get taxLabel => text().withDefault(const Constant('GST'))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class Categories extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get name => text().unique()();
  TextColumn get color => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  TextColumn get syncStatus => text().withDefault(const Constant('PENDING'))();

  @override
  Set<Column> get primaryKey => {id};
}

// Defect 5: Add table indexes as specified in docs/08_Database_Design.md
@TableIndex(name: 'idx_products_sku', columns: {#sku})
@TableIndex(name: 'idx_products_barcode', columns: {#barcode})
@TableIndex(name: 'idx_products_category', columns: {#categoryId})
@TableIndex(name: 'idx_products_low_stock', columns: {#stockQuantity, #lowStockThreshold})
class Products extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get name => text()();
  TextColumn get sku => text().unique()();
  TextColumn get barcode => text().nullable()();
  TextColumn get serialNumber => text().nullable()();
  TextColumn get imei => text().nullable()();
  TextColumn get categoryId => text().references(Categories, #id)();
  RealColumn get sellingPrice => real()();
  RealColumn get costPrice => real()();
  IntColumn get stockQuantity => integer().withDefault(const Constant(0))();
  IntColumn get lowStockThreshold => integer().withDefault(const Constant(0))();
  IntColumn get isDeleted => integer().withDefault(const Constant(0))();
  IntColumn get deletedAt => integer().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  TextColumn get syncStatus => text().withDefault(const Constant('PENDING'))();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'idx_stock_movements_product', columns: {#productId})
@TableIndex(name: 'idx_stock_movements_reference', columns: {#referenceId})
class StockMovements extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get productId => text().references(Products, #id)();
  TextColumn get type => text()(); // IN, OUT, ADJUSTMENT
  IntColumn get quantity => integer()();
  TextColumn get reason => text().nullable()();
  TextColumn get referenceId => text().nullable()();
  TextColumn get note => text().nullable()();
  IntColumn get createdAt => integer()();
  TextColumn get syncStatus => text().withDefault(const Constant('PENDING'))();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'idx_customers_phone', columns: {#phone})
@TableIndex(name: 'idx_customers_name', columns: {#name})
class Customers extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get name => text()();
  TextColumn get phone => text().unique()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  RealColumn get totalOutstanding => real().withDefault(const Constant(0.0))();
  IntColumn get isDeleted => integer().withDefault(const Constant(0))();
  IntColumn get deletedAt => integer().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  TextColumn get syncStatus => text().withDefault(const Constant('PENDING'))();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'idx_invoices_customer', columns: {#customerId})
@TableIndex(name: 'idx_invoices_status', columns: {#status})
@TableIndex(name: 'idx_invoices_payment_status', columns: {#paymentStatus})
@TableIndex(name: 'idx_invoices_created_at', columns: {#createdAt})
class Invoices extends Table {
  TextColumn get id => text()(); // UUID
  IntColumn get invoiceNumber => integer().unique()();
  TextColumn get customerId => text().nullable().references(Customers, #id)(); // Null for walk-in
  RealColumn get subtotal => real()();
  RealColumn get discountAmount => real().withDefault(const Constant(0.0))();
  TextColumn get discountType => text().withDefault(const Constant('FLAT'))();
  RealColumn get taxAmount => real().withDefault(const Constant(0.0))();
  TextColumn get taxType => text().withDefault(const Constant('FLAT'))();
  RealColumn get total => real()();
  RealColumn get paidAmount => real().withDefault(const Constant(0.0))();
  RealColumn get balanceAmount => real()();
  TextColumn get paymentStatus => text()(); // PAID, PARTIAL, UNPAID
  TextColumn get status => text().withDefault(const Constant('ACTIVE'))(); // ACTIVE, VOID
  TextColumn get note => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  TextColumn get syncStatus => text().withDefault(const Constant('PENDING'))();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'idx_invoice_items_invoice', columns: {#invoiceId})
@TableIndex(name: 'idx_invoice_items_product', columns: {#productId})
class InvoiceItems extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get invoiceId => text().references(Invoices, #id)();
  TextColumn get productId => text().references(Products, #id)();
  TextColumn get productName => text()();
  TextColumn get productSku => text()();
  RealColumn get unitPrice => real()();
  IntColumn get quantity => integer()();
  RealColumn get lineTotal => real()();
  IntColumn get createdAt => integer()();
  TextColumn get syncStatus => text().withDefault(const Constant('PENDING'))();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'idx_payments_invoice', columns: {#invoiceId})
class Payments extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get invoiceId => text().references(Invoices, #id)();
  RealColumn get amount => real()();
  TextColumn get method => text().withDefault(const Constant('CASH'))();
  TextColumn get note => text().nullable()();
  IntColumn get createdAt => integer()();
  TextColumn get syncStatus => text().withDefault(const Constant('PENDING'))();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'idx_expenses_date', columns: {#date})
class Expenses extends Table {
  TextColumn get id => text()(); // UUID
  RealColumn get amount => real()();
  TextColumn get category => text()();
  IntColumn get date => integer()();
  TextColumn get note => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  TextColumn get syncStatus => text().withDefault(const Constant('PENDING'))();

  @override
  Set<Column> get primaryKey => {id};
}

class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [
  Users,
  Categories,
  Products,
  StockMovements,
  Customers,
  Invoices,
  InvoiceItems,
  Payments,
  Expenses,
  Settings,
])
class AppDatabase extends _$AppDatabase {
  // Test constructor
  AppDatabase([QueryExecutor? executor]) : super(executor ?? (throw ArgumentError('Executor or SecureKeyStore required.')));

  // Production factory constructor
  AppDatabase.withKeyStore(SecureKeyStore keyStore) : super(openConnection(keyStore));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        
        final now = DateTime.now().millisecondsSinceEpoch;
        
        // 1. Default settings as defined in 08_Database_Design.md
        await into(settings).insert(SettingsCompanion.insert(key: 'invoice_number_sequence', value: '1000', updatedAt: now));
        await into(settings).insert(SettingsCompanion.insert(key: 'app_version', value: '1.0.0', updatedAt: now));
        await into(settings).insert(SettingsCompanion.insert(key: 'last_sync_at', value: '0', updatedAt: now));

        // 2. Defect 6: Seed default categories
        const uuid = Uuid();
        final defaultCategories = ['Phones', 'Accessories', 'Spare Parts', 'Cables', 'Other'];
        
        for (final catName in defaultCategories) {
          await into(categories).insert(CategoriesCompanion.insert(
            id: uuid.v4(),
            name: catName,
            createdAt: now,
            updatedAt: now,
          ));
        }
      },
    );
  }

  // --- Transactional Boundaries ---

  // Defect 2: Fix createInvoiceTx mapping directly to docs/08_Database_Design.md boundaries
  Future<int> createInvoiceTx({
    required InvoicesCompanion invoice,
    required List<InvoiceItemsCompanion> items,
    PaymentsCompanion? payment,
    required List<StockMovementsCompanion> movements,
  }) {
    return transaction(() async {
      // 1. Read sequence setting safely offline
      final seqSetting = await (select(settings)..where((tbl) => tbl.key.equals('invoice_number_sequence'))).getSingle();
      final currentInvoiceNumber = int.parse(seqSetting.value);
      
      // 2. Insert Invoice row (patching invoiceNumber safely in txn)
      final invoiceToInsert = invoice.copyWith(invoiceNumber: Value(currentInvoiceNumber));
      await into(invoices).insert(invoiceToInsert);
      
      // 3. Insert InvoiceItem rows
      for (final item in items) {
        await into(invoiceItems).insert(item);
      }
      
      // 4. Insert Payment row & update invoice status (if payment provided)
      if (payment != null) {
        await into(payments).insert(payment);
        
        final currentInvoice = await (select(invoices)..where((tbl) => tbl.id.equals(invoiceToInsert.id.value))).getSingle();
        final newPaidAmount = currentInvoice.paidAmount + payment.amount.value;
        final newBalanceAmount = currentInvoice.total - newPaidAmount;
        
        String newStatus = 'UNPAID';
        if (newPaidAmount >= currentInvoice.total) {
          newStatus = 'PAID';
        } else if (newPaidAmount > 0) {
          newStatus = 'PARTIAL';
        }
        
        await update(invoices).replace(currentInvoice.copyWith(
          paidAmount: newPaidAmount,
          balanceAmount: newBalanceAmount,
          paymentStatus: newStatus,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        ));
      }
      
      // 5 & 6. Insert StockMovement rows & Update Product stock
      for (final movement in movements) {
        await into(stockMovements).insert(movement);
        final currentProduct = await (select(products)..where((tbl) => tbl.id.equals(movement.productId.value))).getSingle();
        await update(products).replace(
            currentProduct.copyWith(stockQuantity: currentProduct.stockQuantity + movement.quantity.value));
      }
      
      // 7. Update Settings sequence safely offline
      final newSeq = currentInvoiceNumber + 1;
      await update(settings).replace(seqSetting.copyWith(
        value: newSeq.toString(), 
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      ));

      return currentInvoiceNumber;
    });
  }

  // Defect 3: Fix voidInvoiceTx customer outstanding recalculation
  Future<void> voidInvoiceTx(String invoiceId, List<StockMovementsCompanion> correctionMovements) {
    return transaction(() async {
      final now = DateTime.now().millisecondsSinceEpoch;
      
      final invoice = await (select(invoices)..where((tbl) => tbl.id.equals(invoiceId))).getSingle();

      // OPEN QUESTION: docs/08_Database_Design.md does not specify if voiding an invoice 
      // affects paidAmount or paymentStatus, or if linked payments should be refunded/deleted. 
      // Leaving them unchanged for now.
      await (update(invoices)..where((tbl) => tbl.id.equals(invoiceId)))
          .write(InvoicesCompanion(status: const Value('VOID'), updatedAt: Value(now)));
          
      for (final movement in correctionMovements) {
        await into(stockMovements).insert(movement);
        final currentProduct = await (select(products)..where((tbl) => tbl.id.equals(movement.productId.value))).getSingle();
        await update(products).replace(
            currentProduct.copyWith(stockQuantity: currentProduct.stockQuantity + movement.quantity.value));
      }

      // Deduct voided balance from customer's total outstanding
      if (invoice.customerId != null) {
        final currentCustomer = await (select(customers)..where((tbl) => tbl.id.equals(invoice.customerId!))).getSingle();
        await update(customers).replace(currentCustomer.copyWith(
          totalOutstanding: currentCustomer.totalOutstanding - invoice.balanceAmount,
          updatedAt: now,
        ));
      }
    });
  }

  // Defect 4: Enforce BI-005 directly in the transaction
  Future<void> addPaymentTx(PaymentsCompanion payment) {
    return transaction(() async {
      final invoiceId = payment.invoiceId.value;
      final currentInvoice = await (select(invoices)..where((tbl) => tbl.id.equals(invoiceId))).getSingle();
      
      final newPaidAmount = currentInvoice.paidAmount + payment.amount.value;
      
      if (newPaidAmount > currentInvoice.total) {
        throw ArgumentError('Payment amount exceeds invoice total (BI-005).');
      }
      
      await into(payments).insert(payment);
      
      final newBalanceAmount = currentInvoice.total - newPaidAmount;
      String newStatus = 'UNPAID';
      if (newPaidAmount >= currentInvoice.total) {
        newStatus = 'PAID';
      } else if (newPaidAmount > 0) {
        newStatus = 'PARTIAL';
      }

      final now = DateTime.now().millisecondsSinceEpoch;
      await update(invoices).replace(currentInvoice.copyWith(
        paidAmount: newPaidAmount,
        balanceAmount: newBalanceAmount,
        paymentStatus: newStatus,
        updatedAt: now,
      ));

      if (currentInvoice.customerId != null) {
        final currentCustomer = await (select(customers)..where((tbl) => tbl.id.equals(currentInvoice.customerId!))).getSingle();
        await update(customers).replace(currentCustomer.copyWith(
          totalOutstanding: currentCustomer.totalOutstanding - payment.amount.value,
          updatedAt: now,
        ));
      }
    });
  }

  Future<void> addStockTx(StockMovementsCompanion movement) {
    return transaction(() async {
      await into(stockMovements).insert(movement);
      final currentProduct = await (select(products)..where((tbl) => tbl.id.equals(movement.productId.value))).getSingle();
      await update(products).replace(currentProduct.copyWith(
        stockQuantity: currentProduct.stockQuantity + movement.quantity.value,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      ));
    });
  }
}
