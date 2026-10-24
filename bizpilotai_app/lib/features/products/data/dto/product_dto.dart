import 'package:drift/drift.dart';
import 'package:bizpilotai/core/database/app_database.dart' as db;
import 'package:bizpilotai/features/products/domain/entities/product.dart';

extension ProductDtoMapper on db.Product {
  Product toDomain() {
    return Product(
      id: id,
      name: name,
      sku: sku,
      barcode: barcode,
      serialNumber: serialNumber,
      imei: imei,
      categoryId: categoryId,
      sellingPrice: sellingPrice,
      costPrice: costPrice,
      stockQuantity: stockQuantity,
      lowStockThreshold: lowStockThreshold,
      isDeleted: isDeleted == 1,
      deletedAt: deletedAt != null ? DateTime.fromMillisecondsSinceEpoch(deletedAt!) : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt),
    );
  }
}

extension ProductDomainMapper on Product {
  db.ProductsCompanion toTableCompanion() {
    return db.ProductsCompanion(
      id: Value(id),
      name: Value(name),
      sku: Value(sku),
      barcode: Value(barcode),
      serialNumber: Value(serialNumber),
      imei: Value(imei),
      categoryId: Value(categoryId),
      sellingPrice: Value(sellingPrice),
      costPrice: Value(costPrice),
      stockQuantity: Value(stockQuantity),
      lowStockThreshold: Value(lowStockThreshold),
      isDeleted: Value(isDeleted ? 1 : 0),
      deletedAt: Value(deletedAt?.millisecondsSinceEpoch),
      createdAt: Value(createdAt.millisecondsSinceEpoch),
      updatedAt: Value(updatedAt.millisecondsSinceEpoch),
    );
  }
}
