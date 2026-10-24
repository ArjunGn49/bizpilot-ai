import 'package:freezed_annotation/freezed_annotation.dart';

part 'invoice_item.freezed.dart';

@freezed
class InvoiceItem with _$InvoiceItem {
  const factory InvoiceItem({
    required String id,
    required String invoiceId,
    required String productId,
    required String productName,
    required String productSku,
    required double unitPrice,
    required int quantity,
    required double lineTotal,
    required DateTime createdAt,
  }) = _InvoiceItem;
}
