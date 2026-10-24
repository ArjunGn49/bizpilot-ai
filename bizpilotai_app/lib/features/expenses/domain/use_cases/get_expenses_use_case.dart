import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bizpilotai/core/errors/result.dart';
import 'package:bizpilotai/features/expenses/domain/entities/expense.dart';
import 'package:bizpilotai/features/expenses/domain/repositories/expense_repository.dart';
import 'package:bizpilotai/features/expenses/data/repositories/expense_repository_impl.dart';

final getExpensesUseCaseProvider = Provider<GetExpensesUseCase>((ref) {
  return GetExpensesUseCase(ref.watch(expenseRepositoryProvider));
});

class GetExpensesUseCase {
  final ExpenseRepository _repository;

  GetExpensesUseCase(this._repository);

  Future<Result<List<Expense>>> call() {
    return _repository.getExpenses();
  }
}
