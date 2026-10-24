import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:bizpilotai/core/errors/failure.dart';
import 'package:bizpilotai/core/errors/result.dart';
import 'package:bizpilotai/core/database/app_database.dart' as db;
import 'package:bizpilotai/features/invoices/domain/entities/invoice.dart';
import 'package:bizpilotai/features/invoices/domain/entities/payment.dart';
import 'package:bizpilotai/features/invoices/domain/repositories/invoice_repository.dart';
import 'package:bizpilotai/features/invoices/data/data_sources/invoice_local_data_source.dart';
import 'package:bizpilotai/features/invoices/data/dto/invoice_dto.dart';

final invoiceRepositoryProvider = Provider<InvoiceRepository>((ref) {
  return InvoiceRepositoryImpl(ref.watch(invoiceLocalDataSourceProvider));
});

class InvoiceRepositoryImpl implements InvoiceRepository {
  final InvoiceLocalDataSource _local;

  InvoiceRepositoryImpl(this._local);

  @override
  Future<Result<List<Invoice>>> getInvoices() async {
    try {
      final invoices = await _local.getInvoices();
      return Result.success(invoices);
    } catch (e) {
      return Result.failure(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<Invoice>> getInvoiceById(String id) async {
    try {
      final invoice = await _local.getInvoiceById(id);
      return Result.success(invoice);
    } catch (e) {
      return Result.failure(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<int>> createInvoice({
    required Invoice invoice,
    required List<Payment> initialPayments,
  }) async {
    try {
      // 1. Prepare Invoice Companion
      final invoiceCompanion = invoice.toTableCompanion();

      // 2. Prepare Items
      final itemsCompanion = invoice.items.map((i) => i.toTableCompanion()).toList();

      // 3. Prepare Payment (MVP supports single payment at creation)
      db.PaymentsCompanion? paymentCompanion;
      if (initialPayments.isNotEmpty) {
        paymentCompanion = initialPayments.first.toTableCompanion();
      }

      // 4. Prepare Stock Movements for deduction
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      const uuid = Uuid();
      final movements = invoice.items.map((item) {
        return db.StockMovementsCompanion.insert(
          id: uuid.v4(),
          productId: item.productId,
          type: 'OUT',
          quantity: -item.quantity, // Negative for OUT
          reason: const Value('SALE'),
          referenceId: Value(invoice.id),
          createdAt: nowMs,
        );
      }).toList();

      // 5. Execute unified transaction
      final invoiceNumber = await _local.createInvoiceTx(
        invoice: invoiceCompanion,
        items: itemsCompanion,
        payment: paymentCompanion,
        movements: movements,
      );
      return Result.success(invoiceNumber);
    } catch (e) {
      return Result.failure(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> voidInvoice(String invoiceId) async {
    try {
      // Need to fetch current items to restore stock
      final invoice = await _local.getInvoiceById(invoiceId);
      
      if (invoice.isVoid) {
        return const Result.failure(ValidationFailure('Invoice is already void.'));
      }

      final nowMs = DateTime.now().millisecondsSinceEpoch;
      const uuid = Uuid();
      final correctionMovements = invoice.items.map((item) {
        return db.StockMovementsCompanion.insert(
          id: uuid.v4(),
          productId: item.productId,
          type: 'IN',
          quantity: item.quantity, // Positive for IN
          reason: const Value('CORRECTION'),
          referenceId: Value(invoiceId),
          createdAt: nowMs,
        );
      }).toList();

      await _local.voidInvoiceTx(invoiceId, correctionMovements);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> addPayment(Payment payment) async {
    try {
      await _local.addPaymentTx(payment.toTableCompanion());
      return const Result.success(null);
    } catch (e) {
      if (e is ArgumentError) {
        return Result.failure(ValidationFailure(e.message)); // BI-005 trap
      }
      return Result.failure(DatabaseFailure(e.toString()));
    }
  }

  @override
  Stream<List<Invoice>> watchInvoices() {
    return _local.watchInvoices();
  }
}
