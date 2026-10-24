import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bizpilotai/core/errors/result.dart';
import 'package:bizpilotai/features/expenses/domain/entities/expense.dart';
import 'package:bizpilotai/features/expenses/domain/repositories/expense_repository.dart';
import 'package:bizpilotai/features/expenses/data/repositories/expense_repository_impl.dart';

final addExpenseUseCaseProvider = Provider<AddExpenseUseCase>((ref) {
  return AddExpenseUseCase(ref.watch(expenseRepositoryProvider));
});

class AddExpenseUseCase {
  final ExpenseRepository _repository;

  AddExpenseUseCase(this._repository);

  Future<Result<void>> call(Expense expense) {
    return _repository.addExpense(expense);
  }
}
