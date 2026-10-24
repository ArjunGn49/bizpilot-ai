import 'package:freezed_annotation/freezed_annotation.dart';
import 'invoice_item.dart';
import 'payment.dart';

part 'invoice.freezed.dart';

@freezed
class Invoice with _$Invoice {
  const Invoice._();

  const factory Invoice({
    required String id,
    required int invoiceNumber,
    String? customerId,
    required double subtotal,
    required double discountAmount,
    required String discountType, // 'FLAT' or 'PERCENTAGE'
    required double taxAmount,
    required String taxType,
    required double total,
    required double paidAmount,
    required double balanceAmount,
    required String paymentStatus, // 'PAID', 'PARTIAL', 'UNPAID'
    required String status, // 'ACTIVE', 'VOID'
    String? note,
    required DateTime createdAt,
    required DateTime updatedAt,
    // Relationships
    @Default([]) List<InvoiceItem> items,
    @Default([]) List<Payment> payments,
  }) = _Invoice;

  bool get isFullyPaid => balanceAmount <= 0;
  bool get isVoid => status == 'VOID';
}
