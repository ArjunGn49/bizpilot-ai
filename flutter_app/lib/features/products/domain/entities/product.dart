import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';

@freezed
class Product with _$Product {
  const factory Product({
    required String id,
    required String name,
    required String sku,
    String? barcode,
    String? serialNumber,
    String? imei,
    required String categoryId,
    required double sellingPrice,
    required double costPrice,
    required int stockQuantity,
    required int lowStockThreshold,
    required bool isDeleted,
    DateTime? deletedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Product;
}
