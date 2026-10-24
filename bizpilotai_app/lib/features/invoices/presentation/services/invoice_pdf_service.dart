import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:bizpilotai/features/invoices/domain/entities/invoice.dart';

class InvoicePdfService {
  static Future<void> printOrShareInvoice({
    required Invoice invoice,
    String businessName = 'BizPilot AI Store',
    String? customerName,
    bool isThermalReceipt = false,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');

    if (isThermalReceipt) {
      // 80mm Thermal Receipt Layout
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.roll80,
          margin: const pw.EdgeInsets.all(8),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  businessName,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Tax Invoice #${invoice.invoiceNumber}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  dateFormat.format(invoice.createdAt),
                  style: const pw.TextStyle(fontSize: 8),
                ),
                if (customerName != null) ...[
                  pw.SizedBox(height: 2),
                  pw.Text('Customer: $customerName', style: const pw.TextStyle(fontSize: 8)),
                ],
                pw.Divider(thickness: 0.5),

                // Items
                ...invoice.items.map((item) {
                  return pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Expanded(
                          child: pw.Text(
                            '${item.productName} x${item.quantity}',
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                        ),
                        pw.Text(
                          '₹${item.lineTotal.toStringAsFixed(2)}',
                          style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }),
                pw.Divider(thickness: 0.5),

                // Subtotal & Total
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Subtotal', style: const pw.TextStyle(fontSize: 8)),
                    pw.Text('₹${invoice.subtotal.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 8)),
                  ],
                ),
                if (invoice.discountAmount > 0)
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Discount', style: const pw.TextStyle(fontSize: 8)),
                      pw.Text('-₹${invoice.discountAmount.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 8)),
                    ],
                  ),
                if (invoice.taxAmount > 0)
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Tax', style: const pw.TextStyle(fontSize: 8)),
                      pw.Text('₹${invoice.taxAmount.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 8)),
                    ],
                  ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('TOTAL', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                    pw.Text('₹${invoice.total.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Paid', style: const pw.TextStyle(fontSize: 8)),
                    pw.Text('₹${invoice.paidAmount.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 8)),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Balance', style: const pw.TextStyle(fontSize: 8)),
                    pw.Text('₹${invoice.balanceAmount.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 8)),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.BarcodeWidget(
                  barcode: pw.Barcode.code128(),
                  data: 'INV-${invoice.invoiceNumber}',
                  width: 120,
                  height: 30,
                  drawText: false,
                ),
                pw.SizedBox(height: 4),
                pw.Text('Thank you for your business!', style: const pw.TextStyle(fontSize: 8)),
              ],
            );
          },
        ),
      );
    } else {
      // Standard A4 PDF Document Layout
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          businessName,
                          style: pw.TextStyle(
                            fontSize: 22,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue800,
                          ),
                        ),
                        pw.Text('Smart Business & POS Solutions', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'INVOICE',
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey900,
                          ),
                        ),
                        pw.Text('#${invoice.invoiceNumber}', style: const pw.TextStyle(fontSize: 12)),
                        pw.Text('Date: ${dateFormat.format(invoice.createdAt)}', style: const pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 24),

                if (customerName != null) ...[
                  pw.Text('Billed To:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                  pw.Text(customerName, style: const pw.TextStyle(fontSize: 11)),
                  pw.SizedBox(height: 16),
                ],

                // Table Header & Rows
                pw.TableHelper.fromTextArray(
                  headers: ['Item / SKU', 'Qty', 'Unit Price', 'Total'],
                  data: invoice.items.map((item) {
                    return [
                      '${item.productName}\n(${item.productSku})',
                      item.quantity.toString(),
                      '₹${item.unitPrice.toStringAsFixed(2)}',
                      '₹${item.lineTotal.toStringAsFixed(2)}',
                    ];
                  }).toList(),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
                  cellAlignment: pw.Alignment.centerLeft,
                  cellPadding: const pw.EdgeInsets.all(8),
                ),
                pw.SizedBox(height: 16),

                // Totals Summary
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Container(
                      width: 200,
                      child: pw.Column(
                        children: [
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('Subtotal:'),
                              pw.Text('₹${invoice.subtotal.toStringAsFixed(2)}'),
                            ],
                          ),
                          if (invoice.discountAmount > 0)
                            pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text('Discount:'),
                                pw.Text('-₹${invoice.discountAmount.toStringAsFixed(2)}'),
                              ],
                            ),
                          if (invoice.taxAmount > 0)
                            pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text('Tax:'),
                                pw.Text('₹${invoice.taxAmount.toStringAsFixed(2)}'),
                              ],
                            ),
                          pw.Divider(),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('Total:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                              pw.Text('₹${invoice.total.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                            ],
                          ),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('Paid:'),
                              pw.Text('₹${invoice.paidAmount.toStringAsFixed(2)}'),
                            ],
                          ),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('Balance:'),
                              pw.Text('₹${invoice.balanceAmount.toStringAsFixed(2)}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.Spacer(),
                pw.Divider(color: PdfColors.grey400),
                pw.Center(
                  child: pw.Text('Thank you for choosing BizPilot AI!', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                ),
              ],
            );
          },
        ),
      );
    }

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Invoice_${invoice.invoiceNumber}.pdf',
    );
  }
}
