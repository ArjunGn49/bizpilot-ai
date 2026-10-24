import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bizpilotai/core/errors/result.dart';
import 'package:bizpilotai/features/invoices/domain/entities/invoice.dart';
import 'package:bizpilotai/features/invoices/domain/entities/payment.dart';
import 'package:bizpilotai/features/invoices/domain/repositories/invoice_repository.dart';
import 'package:bizpilotai/features/invoices/data/repositories/invoice_repository_impl.dart';

final createInvoiceUseCaseProvider = Provider<CreateInvoiceUseCase>((ref) {
  return CreateInvoiceUseCase(ref.watch(invoiceRepositoryProvider));
});

class CreateInvoiceUseCase {
  final InvoiceRepository _repository;

  CreateInvoiceUseCase(this._repository);

  Future<Result<int>> call({
    required Invoice invoice,
    required List<Payment> initialPayments,
  }) {
    return _repository.createInvoice(
      invoice: invoice,
      initialPayments: initialPayments,
    );
  }
}
