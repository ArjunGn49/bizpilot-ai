import 'package:bizpilotai/core/errors/result.dart';
import 'package:bizpilotai/features/invoices/domain/entities/invoice.dart';
import 'package:bizpilotai/features/invoices/domain/entities/payment.dart';

abstract class InvoiceRepository {
  Future<Result<List<Invoice>>> getInvoices();
  Future<Result<Invoice>> getInvoiceById(String id);
  Future<Result<int>> createInvoice({
    required Invoice invoice,
    required List<Payment> initialPayments,
  });
  Future<Result<void>> voidInvoice(String invoiceId);
  Future<Result<void>> addPayment(Payment payment);
  Stream<List<Invoice>> watchInvoices();
}
