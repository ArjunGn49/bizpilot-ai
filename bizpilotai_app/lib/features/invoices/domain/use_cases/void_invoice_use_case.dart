import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bizpilotai/core/errors/result.dart';
import 'package:bizpilotai/features/invoices/domain/repositories/invoice_repository.dart';
import 'package:bizpilotai/features/invoices/data/repositories/invoice_repository_impl.dart';

final voidInvoiceUseCaseProvider = Provider<VoidInvoiceUseCase>((ref) {
  return VoidInvoiceUseCase(ref.watch(invoiceRepositoryProvider));
});

class VoidInvoiceUseCase {
  final InvoiceRepository _repository;

  VoidInvoiceUseCase(this._repository);

  Future<Result<void>> call(String invoiceId) {
    return _repository.voidInvoice(invoiceId);
  }
}
