import 'package:bizpilotai/core/database/app_database.dart' as db;
import 'package:bizpilotai/features/products/domain/entities/category.dart';

extension CategoryDtoMapper on db.Category {
  Category toDomain() {
    return Category(
      id: id,
      name: name,
      color: color,
    );
  }
}
