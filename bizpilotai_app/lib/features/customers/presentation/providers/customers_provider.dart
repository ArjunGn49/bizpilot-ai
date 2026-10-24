import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bizpilotai/features/customers/domain/entities/customer.dart';
import 'package:bizpilotai/features/customers/domain/use_cases/watch_customers_use_case.dart';
import 'package:bizpilotai/features/invoices/domain/entities/invoice.dart';
import 'package:bizpilotai/features/invoices/domain/use_cases/watch_invoices_use_case.dart';

final customersProvider = StreamProvider.autoDispose<List<Customer>>((ref) {
  return ref.watch(watchCustomersUseCaseProvider).call();
});

final customerDetailProvider = StreamProvider.autoDispose.family<Customer?, String>((ref, id) {
  return ref.watch(watchCustomersUseCaseProvider).call().map((customers) {
    try {
      return customers.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  });
});

final customerInvoicesProvider = StreamProvider.autoDispose.family<List<Invoice>, String>((ref, customerId) {
  return ref.watch(watchInvoicesUseCaseProvider).call().map((invoices) {
    return invoices.where((inv) => inv.customerId == customerId).toList();
  });
});
