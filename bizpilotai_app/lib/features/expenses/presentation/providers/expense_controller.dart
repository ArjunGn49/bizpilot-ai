import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bizpilotai/features/expenses/domain/entities/expense.dart';
import 'package:bizpilotai/features/expenses/domain/use_cases/add_expense_use_case.dart';
import 'package:bizpilotai/features/expenses/domain/use_cases/delete_expense_use_case.dart';

final expenseControllerProvider =
    StateNotifierProvider.autoDispose<ExpenseController, AsyncValue<void>>((ref) {
  return ExpenseController(ref);
});

class ExpenseController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  ExpenseController(this._ref) : super(const AsyncValue.data(null));

  Future<bool> addExpense(Expense expense) async {
    state = const AsyncValue.loading();
    final result = await _ref.read(addExpenseUseCaseProvider).call(expense);
    return result.when(
      success: (_) {
        state = const AsyncValue.data(null);
        return true;
      },
      failure: (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
        return false;
      },
    );
  }

  Future<bool> deleteExpense(String id) async {
    state = const AsyncValue.loading();
    final result = await _ref.read(deleteExpenseUseCaseProvider).call(id);
    return result.when(
      success: (_) {
        state = const AsyncValue.data(null);
        return true;
      },
      failure: (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
        return false;
      },
    );
  }
}
