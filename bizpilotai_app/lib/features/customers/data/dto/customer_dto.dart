import 'package:drift/drift.dart';
import 'package:bizpilotai/core/database/app_database.dart' as db;
import 'package:bizpilotai/features/customers/domain/entities/customer.dart';

extension CustomerDtoMapper on db.Customer {
  Customer toDomain() {
    return Customer(
      id: id,
      name: name,
      phone: phone,
      email: email,
      address: address,
      totalOutstanding: totalOutstanding,
      isDeleted: isDeleted == 1,
      deletedAt: deletedAt != null ? DateTime.fromMillisecondsSinceEpoch(deletedAt!) : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt),
    );
  }
}

extension CustomerDomainMapper on Customer {
  db.CustomersCompanion toTableCompanion() {
    return db.CustomersCompanion(
      id: Value(id),
      name: Value(name),
      phone: Value(phone),
      email: Value(email),
      address: Value(address),
      totalOutstanding: Value(totalOutstanding),
      isDeleted: Value(isDeleted ? 1 : 0),
      deletedAt: Value(deletedAt?.millisecondsSinceEpoch),
      createdAt: Value(createdAt.millisecondsSinceEpoch),
      updatedAt: Value(updatedAt.millisecondsSinceEpoch),
    );
  }
}
