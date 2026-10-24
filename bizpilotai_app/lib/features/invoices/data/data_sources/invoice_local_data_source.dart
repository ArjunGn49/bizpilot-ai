import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bizpilotai/core/database/app_database.dart' as db;
import 'package:bizpilotai/core/database/database_provider.dart';
import 'package:bizpilotai/features/invoices/domain/entities/invoice.dart';
import 'package:bizpilotai/features/invoices/data/dto/invoice_dto.dart';

final invoiceLocalDataSourceProvider = Provider<InvoiceLocalDataSource>((ref) {
  return InvoiceLocalDataSource(ref.watch(databaseProvider));
});

class InvoiceLocalDataSource {
  final db.AppDatabase _db;

  InvoiceLocalDataSource(this._db);

  Future<List<Invoice>> getInvoices() async {
    final invoices = await (_db.select(_db.invoices)
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]))
      .get();
    
    // We avoid N+1 queries by fetching all related and grouping locally, 
    // or we fetch per invoice if the dataset is small.
    // For MVP scale, fetching per invoice is acceptable.
    final result = <Invoice>[];
    for (var inv in invoices) {
      final items = await (_db.select(_db.invoiceItems)..where((t) => t.invoiceId.equals(inv.id))).get();
      final payments = await (_db.select(_db.payments)..where((t) => t.invoiceId.equals(inv.id))).get();
      result.add(inv.toDomain(
        items: items.map((i) => i.toDomain()).toList(),
        payments: payments.map((p) => p.toDomain()).toList(),
      ));
    }
    return result;
  }

  Future<Invoice> getInvoiceById(String id) async {
    final inv = await (_db.select(_db.invoices)..where((t) => t.id.equals(id))).getSingle();
    final items = await (_db.select(_db.invoiceItems)..where((t) => t.invoiceId.equals(id))).get();
    final payments = await (_db.select(_db.payments)..where((t) => t.invoiceId.equals(id))).get();
    
    return inv.toDomain(
      items: items.map((i) => i.toDomain()).toList(),
      payments: payments.map((p) => p.toDomain()).toList(),
    );
  }

  Future<int> createInvoiceTx({
    required db.InvoicesCompanion invoice,
    required List<db.InvoiceItemsCompanion> items,
    db.PaymentsCompanion? payment,
    required List<db.StockMovementsCompanion> movements,
  }) {
    return _db.createInvoiceTx(
      invoice: invoice,
      items: items,
      payment: payment,
      movements: movements,
    );
  }

  Future<void> voidInvoiceTx(String invoiceId, List<db.StockMovementsCompanion> movements) {
    return _db.voidInvoiceTx(invoiceId, movements);
  }

  Future<void> addPaymentTx(db.PaymentsCompanion payment) {
    return _db.addPaymentTx(payment);
  }

  Stream<List<Invoice>> watchInvoices() {
    // Basic watch on the invoices table. For full populated objects in a stream,
    // we map over the stream and fetch relations. 
    return (_db.select(_db.invoices)
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]))
      .watch()
      .asyncMap((invoices) async {
        final result = <Invoice>[];
        for (var inv in invoices) {
          final items = await (_db.select(_db.invoiceItems)..where((t) => t.invoiceId.equals(inv.id))).get();
          final payments = await (_db.select(_db.payments)..where((t) => t.invoiceId.equals(inv.id))).get();
          result.add(inv.toDomain(
            items: items.map((i) => i.toDomain()).toList(),
            payments: payments.map((p) => p.toDomain()).toList(),
          ));
        }
        return result;
      });
  }
}
