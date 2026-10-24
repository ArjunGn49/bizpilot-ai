import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bizpilotai/features/invoices/domain/entities/invoice.dart';
import 'package:bizpilotai/features/invoices/domain/repositories/invoice_repository.dart';
import 'package:bizpilotai/features/invoices/data/repositories/invoice_repository_impl.dart';

final watchInvoicesUseCaseProvider = Provider<WatchInvoicesUseCase>((ref) {
  return WatchInvoicesUseCase(ref.watch(invoiceRepositoryProvider));
});

class WatchInvoicesUseCase {
  final InvoiceRepository _repository;

  WatchInvoicesUseCase(this._repository);

  Stream<List<Invoice>> call() {
    return _repository.watchInvoices();
  }
}
