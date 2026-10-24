import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bizpilotai/core/errors/failure.dart';
import 'package:bizpilotai/core/errors/result.dart';
import 'package:bizpilotai/features/expenses/data/datasources/expense_local_data_source.dart';
import 'package:bizpilotai/features/expenses/domain/entities/expense.dart';
import 'package:bizpilotai/features/expenses/domain/repositories/expense_repository.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepositoryImpl(ref.watch(expenseLocalDataSourceProvider));
});

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseLocalDataSource _localDataSource;

  ExpenseRepositoryImpl(this._localDataSource);

  @override
  Future<Result<List<Expense>>> getExpenses() async {
    try {
      final expenses = await _localDataSource.getExpenses();
      return Result.success(expenses);
    } catch (e) {
      return Result.failure(DatabaseFailure(e.toString()));
    }
  }

  @override
  Stream<List<Expense>> watchExpenses() {
    return _localDataSource.watchExpenses();
  }

  @override
  Future<Result<void>> addExpense(Expense expense) async {
    try {
      await _localDataSource.insertExpense(expense);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteExpense(String id) async {
    try {
      await _localDataSource.deleteExpense(id);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseFailure(e.toString()));
    }
  }
}
