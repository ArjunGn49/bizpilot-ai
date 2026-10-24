import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bizpilotai/core/errors/result.dart';
import 'package:bizpilotai/features/expenses/domain/repositories/expense_repository.dart';
import 'package:bizpilotai/features/expenses/data/repositories/expense_repository_impl.dart';

final deleteExpenseUseCaseProvider = Provider<DeleteExpenseUseCase>((ref) {
  return DeleteExpenseUseCase(ref.watch(expenseRepositoryProvider));
});

class DeleteExpenseUseCase {
  final ExpenseRepository _repository;

  DeleteExpenseUseCase(this._repository);

  Future<Result<void>> call(String id) {
    return _repository.deleteExpense(id);
  }
}
