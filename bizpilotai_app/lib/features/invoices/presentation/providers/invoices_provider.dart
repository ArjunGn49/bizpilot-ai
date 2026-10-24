import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bizpilotai/features/invoices/domain/entities/invoice.dart';
import 'package:bizpilotai/features/invoices/domain/use_cases/watch_invoices_use_case.dart';

final invoicesProvider = StreamProvider.autoDispose<List<Invoice>>((ref) {
  return ref.watch(watchInvoicesUseCaseProvider).call();
});

final invoiceDetailProvider = StreamProvider.autoDispose.family<Invoice?, String>((ref, id) {
  return ref.watch(watchInvoicesUseCaseProvider).call().map((invoices) {
    try {
      return invoices.firstWhere((inv) => inv.id == id);
    } catch (_) {
      return null;
    }
  });
});
