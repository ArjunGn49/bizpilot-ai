import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bizpilotai/features/expenses/domain/entities/expense.dart';
import 'package:bizpilotai/features/expenses/domain/use_cases/watch_expenses_use_case.dart';

final expensesProvider = StreamProvider.autoDispose<List<Expense>>((ref) {
  return ref.watch(watchExpensesUseCaseProvider).call();
});
