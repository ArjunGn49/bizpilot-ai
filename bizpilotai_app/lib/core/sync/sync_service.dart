import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bizpilotai/core/database/database_provider.dart';
import 'package:bizpilotai/core/database/app_database.dart';
import 'package:bizpilotai/core/utils/app_logger.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  final db = ref.watch(databaseProvider);
  return SyncService(db);
});

class SyncService {
  final AppDatabase _db;
  final FirebaseFirestore _firestore;
  Timer? _periodicTimer;
  bool _isSyncing = false;

  SyncService(this._db, {FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  void startPeriodicSync({Duration interval = const Duration(minutes: 5)}) {
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(interval, (_) => syncPendingData());
  }

  void stopPeriodicSync() {
    _periodicTimer?.cancel();
  }

  Future<void> syncPendingData() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      logger.d('Starting background cloud sync to Firebase Cloud Firestore...');

      // 1. Sync Categories
      final pendingCategories = await (_db.select(_db.categories)
            ..where((tbl) => tbl.syncStatus.equals('PENDING')))
          .get();

      for (final cat in pendingCategories) {
        logger.d('Syncing category ${cat.name} to Firestore...');
        await _firestore.collection('categories').doc(cat.id).set({
          'id': cat.id,
          'name': cat.name,
          'color': cat.color,
          'createdAt': cat.createdAt,
          'updatedAt': cat.updatedAt,
          'syncedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        await (_db.update(_db.categories)..where((tbl) => tbl.id.equals(cat.id)))
            .write(const CategoriesCompanion(syncStatus: Value('SYNCED')));
      }

      // 2. Sync Products
      final pendingProducts = await (_db.select(_db.products)
            ..where((tbl) => tbl.syncStatus.equals('PENDING')))
          .get();

      for (final prod in pendingProducts) {
        logger.d('Syncing product ${prod.name} to Firestore...');
        await _firestore.collection('products').doc(prod.id).set({
          'id': prod.id,
          'name': prod.name,
          'sku': prod.sku,
          'barcode': prod.barcode,
          'categoryId': prod.categoryId,
          'sellingPrice': prod.sellingPrice,
          'costPrice': prod.costPrice,
          'stockQuantity': prod.stockQuantity,
          'lowStockThreshold': prod.lowStockThreshold,
          'isDeleted': prod.isDeleted,
          'createdAt': prod.createdAt,
          'updatedAt': prod.updatedAt,
          'syncedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        await (_db.update(_db.products)..where((tbl) => tbl.id.equals(prod.id)))
            .write(const ProductsCompanion(syncStatus: Value('SYNCED')));
      }

      // 3. Sync Customers
      final pendingCustomers = await (_db.select(_db.customers)
            ..where((tbl) => tbl.syncStatus.equals('PENDING')))
          .get();

      for (final cust in pendingCustomers) {
        logger.d('Syncing customer ${cust.name} to Firestore...');
        await _firestore.collection('customers').doc(cust.id).set({
          'id': cust.id,
          'name': cust.name,
          'phone': cust.phone,
          'email': cust.email,
          'address': cust.address,
          'totalOutstanding': cust.totalOutstanding,
          'isDeleted': cust.isDeleted,
          'createdAt': cust.createdAt,
          'updatedAt': cust.updatedAt,
          'syncedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        await (_db.update(_db.customers)..where((tbl) => tbl.id.equals(cust.id)))
            .write(const CustomersCompanion(syncStatus: Value('SYNCED')));
      }

      // 4. Sync Invoices
      final pendingInvoices = await (_db.select(_db.invoices)
            ..where((tbl) => tbl.syncStatus.equals('PENDING')))
          .get();

      for (final inv in pendingInvoices) {
        logger.d('Syncing invoice #${inv.invoiceNumber} to Firestore...');
        await _firestore.collection('invoices').doc(inv.id).set({
          'id': inv.id,
          'invoiceNumber': inv.invoiceNumber,
          'customerId': inv.customerId,
          'subtotal': inv.subtotal,
          'discountAmount': inv.discountAmount,
          'taxAmount': inv.taxAmount,
          'total': inv.total,
          'paidAmount': inv.paidAmount,
          'balanceAmount': inv.balanceAmount,
          'paymentStatus': inv.paymentStatus,
          'status': inv.status,
          'createdAt': inv.createdAt,
          'updatedAt': inv.updatedAt,
          'syncedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        await (_db.update(_db.invoices)..where((tbl) => tbl.id.equals(inv.id)))
            .write(const InvoicesCompanion(syncStatus: Value('SYNCED')));
      }

      // 5. Sync Expenses
      final pendingExpenses = await (_db.select(_db.expenses)
            ..where((tbl) => tbl.syncStatus.equals('PENDING')))
          .get();

      for (final exp in pendingExpenses) {
        logger.d('Syncing expense ${exp.category} (₹${exp.amount}) to Firestore...');
        await _firestore.collection('expenses').doc(exp.id).set({
          'id': exp.id,
          'amount': exp.amount,
          'category': exp.category,
          'date': exp.date,
          'note': exp.note,
          'createdAt': exp.createdAt,
          'updatedAt': exp.updatedAt,
          'syncedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        await (_db.update(_db.expenses)..where((tbl) => tbl.id.equals(exp.id)))
            .write(const ExpensesCompanion(syncStatus: Value('SYNCED')));
      }

      logger.d('Firebase Cloud Firestore sync completed successfully.');
    } catch (e, stack) {
      logger.e('Error during cloud sync: $e', error: e, stackTrace: stack);
    } finally {
      _isSyncing = false;
    }
  }
}
