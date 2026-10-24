import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment.freezed.dart';

@freezed
class Payment with _$Payment {
  const factory Payment({
    required String id,
    required String invoiceId,
    required double amount,
    required String method,
    String? note,
    required DateTime createdAt,
  }) = _Payment;
}
