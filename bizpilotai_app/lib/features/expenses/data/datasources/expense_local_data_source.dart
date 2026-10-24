import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bizpilotai/core/database/database_provider.dart';
import 'package:bizpilotai/core/database/app_database.dart' hide Expense;
import 'package:bizpilotai/features/expenses/data/dto/expense_dto.dart';
import 'package:bizpilotai/features/expenses/domain/entities/expense.dart';

final expenseLocalDataSourceProvider = Provider<ExpenseLocalDataSource>((ref) {
  return ExpenseLocalDataSourceImpl(ref.watch(databaseProvider));
});

abstract class ExpenseLocalDataSource {
  Future<List<Expense>> getExpenses();
  Stream<List<Expense>> watchExpenses();
  Future<void> insertExpense(Expense expense);
  Future<void> deleteExpense(String id);
}

class ExpenseLocalDataSourceImpl implements ExpenseLocalDataSource {
  final AppDatabase _db;

  ExpenseLocalDataSourceImpl(this._db);

  @override
  Future<List<Expense>> getExpenses() async {
    final rows = await (_db.select(_db.expenses)
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
    return rows.map((r) => r.toDomain()).toList();
  }

  @override
  Stream<List<Expense>> watchExpenses() {
    return (_db.select(_db.expenses)
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch()
        .map((rows) => rows.map((r) => r.toDomain()).toList());
  }

  @override
  Future<void> insertExpense(Expense expense) async {
    await _db.into(_db.expenses).insertOnConflictUpdate(expense.toCompanion());
  }

  @override
  Future<void> deleteExpense(String id) async {
    await (_db.delete(_db.expenses)..where((tbl) => tbl.id.equals(id))).go();
  }
}
