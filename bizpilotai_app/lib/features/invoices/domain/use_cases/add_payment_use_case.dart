import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bizpilotai/core/errors/result.dart';
import 'package:bizpilotai/features/invoices/domain/entities/payment.dart';
import 'package:bizpilotai/features/invoices/domain/repositories/invoice_repository.dart';
import 'package:bizpilotai/features/invoices/data/repositories/invoice_repository_impl.dart';

final addPaymentUseCaseProvider = Provider<AddPaymentUseCase>((ref) {
  return AddPaymentUseCase(ref.watch(invoiceRepositoryProvider));
});

class AddPaymentUseCase {
  final InvoiceRepository _repository;

  AddPaymentUseCase(this._repository);

  Future<Result<void>> call(Payment payment) {
    return _repository.addPayment(payment);
  }
}
