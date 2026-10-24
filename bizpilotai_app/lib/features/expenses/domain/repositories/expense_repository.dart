import 'package:bizpilotai/core/errors/result.dart';
import 'package:bizpilotai/features/expenses/domain/entities/expense.dart';

abstract class ExpenseRepository {
  Future<Result<List<Expense>>> getExpenses();
  Stream<List<Expense>> watchExpenses();
  Future<Result<void>> addExpense(Expense expense);
  Future<Result<void>> deleteExpense(String id);
}
