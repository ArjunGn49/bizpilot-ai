import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bizpilotai/features/expenses/domain/entities/expense.dart';
import 'package:bizpilotai/features/expenses/domain/repositories/expense_repository.dart';
import 'package:bizpilotai/features/expenses/data/repositories/expense_repository_impl.dart';

final watchExpensesUseCaseProvider = Provider<WatchExpensesUseCase>((ref) {
  return WatchExpensesUseCase(ref.watch(expenseRepositoryProvider));
});

class WatchExpensesUseCase {
  final ExpenseRepository _repository;

  WatchExpensesUseCase(this._repository);

  Stream<List<Expense>> call() {
    return _repository.watchExpenses();
  }
}
