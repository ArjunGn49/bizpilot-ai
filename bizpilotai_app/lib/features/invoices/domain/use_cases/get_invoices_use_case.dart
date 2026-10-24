import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bizpilotai/core/errors/result.dart';
import 'package:bizpilotai/features/invoices/domain/entities/invoice.dart';
import 'package:bizpilotai/features/invoices/domain/repositories/invoice_repository.dart';
import 'package:bizpilotai/features/invoices/data/repositories/invoice_repository_impl.dart';

final getInvoicesUseCaseProvider = Provider<GetInvoicesUseCase>((ref) {
  return GetInvoicesUseCase(ref.watch(invoiceRepositoryProvider));
});

class GetInvoicesUseCase {
  final InvoiceRepository _repository;

  GetInvoicesUseCase(this._repository);

  Future<Result<List<Invoice>>> call() {
    return _repository.getInvoices();
  }
}
