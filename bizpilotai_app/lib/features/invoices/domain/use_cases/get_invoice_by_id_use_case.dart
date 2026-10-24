import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bizpilotai/core/errors/result.dart';
import 'package:bizpilotai/features/invoices/domain/entities/invoice.dart';
import 'package:bizpilotai/features/invoices/domain/repositories/invoice_repository.dart';
import 'package:bizpilotai/features/invoices/data/repositories/invoice_repository_impl.dart';

final getInvoiceByIdUseCaseProvider = Provider<GetInvoiceByIdUseCase>((ref) {
  return GetInvoiceByIdUseCase(ref.watch(invoiceRepositoryProvider));
});

class GetInvoiceByIdUseCase {
  final InvoiceRepository _repository;

  GetInvoiceByIdUseCase(this._repository);

  Future<Result<Invoice>> call(String id) {
    return _repository.getInvoiceById(id);
  }
}
