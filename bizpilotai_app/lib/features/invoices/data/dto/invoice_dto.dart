import 'package:drift/drift.dart';
import 'package:bizpilotai/core/database/app_database.dart' as db;
import 'package:bizpilotai/features/invoices/domain/entities/invoice.dart';
import 'package:bizpilotai/features/invoices/domain/entities/invoice_item.dart';
import 'package:bizpilotai/features/invoices/domain/entities/payment.dart';

extension InvoiceItemDtoMapper on db.InvoiceItem {
  InvoiceItem toDomain() {
    return InvoiceItem(
      id: id,
      invoiceId: invoiceId,
      productId: productId,
      productName: productName,
      productSku: productSku,
      unitPrice: unitPrice,
      quantity: quantity,
      lineTotal: lineTotal,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
    );
  }
}

extension InvoiceItemDomainMapper on InvoiceItem {
  db.InvoiceItemsCompanion toTableCompanion() {
    return db.InvoiceItemsCompanion(
      id: Value(id),
      invoiceId: Value(invoiceId),
      productId: Value(productId),
      productName: Value(productName),
      productSku: Value(productSku),
      unitPrice: Value(unitPrice),
      quantity: Value(quantity),
      lineTotal: Value(lineTotal),
      createdAt: Value(createdAt.millisecondsSinceEpoch),
    );
  }
}

extension PaymentDtoMapper on db.Payment {
  Payment toDomain() {
    return Payment(
      id: id,
      invoiceId: invoiceId,
      amount: amount,
      method: method,
      note: note,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
    );
  }
}

extension PaymentDomainMapper on Payment {
  db.PaymentsCompanion toTableCompanion() {
    return db.PaymentsCompanion(
      id: Value(id),
      invoiceId: Value(invoiceId),
      amount: Value(amount),
      method: Value(method),
      note: Value(note),
      createdAt: Value(createdAt.millisecondsSinceEpoch),
    );
  }
}

extension InvoiceDtoMapper on db.Invoice {
  Invoice toDomain({List<InvoiceItem> items = const [], List<Payment> payments = const []}) {
    return Invoice(
      id: id,
      invoiceNumber: invoiceNumber,
      customerId: customerId,
      subtotal: subtotal,
      discountAmount: discountAmount,
      discountType: discountType,
      taxAmount: taxAmount,
      taxType: taxType,
      total: total,
      paidAmount: paidAmount,
      balanceAmount: balanceAmount,
      paymentStatus: paymentStatus,
      status: status,
      note: note,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt),
      items: items,
      payments: payments,
    );
  }
}

extension InvoiceDomainMapper on Invoice {
  db.InvoicesCompanion toTableCompanion() {
    return db.InvoicesCompanion(
      id: Value(id),
      invoiceNumber: Value(invoiceNumber),
      customerId: Value(customerId),
      subtotal: Value(subtotal),
      discountAmount: Value(discountAmount),
      discountType: Value(discountType),
      taxAmount: Value(taxAmount),
      taxType: Value(taxType),
      total: Value(total),
      paidAmount: Value(paidAmount),
      balanceAmount: Value(balanceAmount),
      paymentStatus: Value(paymentStatus),
      status: Value(status),
      note: Value(note),
      createdAt: Value(createdAt.millisecondsSinceEpoch),
      updatedAt: Value(updatedAt.millisecondsSinceEpoch),
    );
  }
}
