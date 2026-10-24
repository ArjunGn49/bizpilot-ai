import 'package:drift/drift.dart';
import 'package:bizpilotai/core/database/app_database.dart' as db;
import 'package:bizpilotai/features/expenses/domain/entities/expense.dart';

extension ExpenseDataX on db.Expense {
  Expense toDomain() {
    return Expense(
      id: id,
      amount: amount,
      category: category,
      date: DateTime.fromMillisecondsSinceEpoch(date),
      note: note,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt),
    );
  }
}

extension ExpenseX on Expense {
  db.ExpensesCompanion toCompanion() {
    return db.ExpensesCompanion(
      id: Value(id),
      amount: Value(amount),
      category: Value(category),
      date: Value(date.millisecondsSinceEpoch),
      note: Value(note),
      createdAt: Value(createdAt.millisecondsSinceEpoch),
      updatedAt: Value(updatedAt.millisecondsSinceEpoch),
      syncStatus: const Value('PENDING'),
    );
  }
}
