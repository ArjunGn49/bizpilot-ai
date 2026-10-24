import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:bizpilotai/features/invoices/domain/entities/payment.dart';
import 'package:bizpilotai/features/invoices/domain/use_cases/add_payment_use_case.dart';
import 'package:bizpilotai/features/invoices/domain/use_cases/void_invoice_use_case.dart';
import 'package:bizpilotai/features/invoices/presentation/providers/invoices_provider.dart';
import 'package:bizpilotai/features/invoices/presentation/services/invoice_pdf_service.dart';

class InvoiceDetailScreen extends ConsumerStatefulWidget {
  final String invoiceId;

  const InvoiceDetailScreen({super.key, required this.invoiceId});

  @override
  ConsumerState<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends ConsumerState<InvoiceDetailScreen> {
  Future<void> _showAddPaymentDialog(double balanceAmount) async {
    final amountController = TextEditingController(text: balanceAmount.toStringAsFixed(2));
    final noteController = TextEditingController();
    String paymentMethod = 'CASH';

    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Collect Payment'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: amountController,
                decoration: const InputDecoration(
                  labelText: 'Payment Amount (₹)',
                  prefixIcon: Icon(Icons.currency_rupee),
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Enter amount';
                  final parsed = double.tryParse(val.trim());
                  if (parsed == null || parsed <= 0) return 'Enter valid amount';
                  if (parsed > balanceAmount) return 'Amount exceeds balance';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: paymentMethod,
                decoration: const InputDecoration(
                  labelText: 'Payment Method',
                  prefixIcon: Icon(Icons.payment),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'CASH', child: Text('Cash')),
                  DropdownMenuItem(value: 'CARD', child: Text('Card / POS')),
                  DropdownMenuItem(value: 'UPI', child: Text('UPI / QR')),
                  DropdownMenuItem(value: 'BANK_TRANSFER', child: Text('Bank Transfer')),
                ],
                onChanged: (val) {
                  if (val != null) paymentMethod = val;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: 'Note (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(ctx).pop(true);
              }
            },
            child: const Text('Record Payment'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      final amount = double.parse(amountController.text.trim());
      final payment = Payment(
        id: const Uuid().v4(),
        invoiceId: widget.invoiceId,
        amount: amount,
        method: paymentMethod,
        note: noteController.text.trim().isNotEmpty ? noteController.text.trim() : null,
        createdAt: DateTime.now(),
      );

      final res = await ref.read(addPaymentUseCaseProvider).call(payment);
      if (mounted) {
        res.when(
          success: (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Payment recorded successfully!'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          failure: (f) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(f.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        );
      }
    }
  }

  Future<void> _showVoidDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Void Invoice'),
        content: const Text('Are you sure you want to void this invoice? Restored items will be added back to stock inventory.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Void Invoice', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final res = await ref.read(voidInvoiceUseCaseProvider).call(widget.invoiceId);
      if (mounted) {
        res.when(
          success: (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invoice voided successfully'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          failure: (f) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(f.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final invoiceAsync = ref.watch(invoiceDetailProvider(widget.invoiceId));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currencyFormat = NumberFormat.currency(symbol: '₹');
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Details'),
      ),
      body: invoiceAsync.when(
        data: (invoice) {
          if (invoice == null) {
            return const Center(child: Text('Invoice not found'));
          }

          Color statusColor;
          if (invoice.isVoid) {
            statusColor = Colors.grey;
          } else if (invoice.paymentStatus == 'PAID') {
            statusColor = Colors.green;
          } else if (invoice.paymentStatus == 'PARTIAL') {
            statusColor = Colors.orange;
          } else {
            statusColor = Colors.red;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Invoice #${invoice.invoiceNumber}',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                invoice.isVoid ? 'VOID' : invoice.paymentStatus,
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Date: ${dateFormat.format(invoice.createdAt)}',
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        if (invoice.customerId != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Customer: ${invoice.customerId}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildAmountSummary('Total', currencyFormat.format(invoice.total), colorScheme.primary),
                            _buildAmountSummary('Paid', currencyFormat.format(invoice.paidAmount), Colors.green),
                            _buildAmountSummary('Balance Due', currencyFormat.format(invoice.balanceAmount), Colors.redAccent),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Itemized Breakdown
                Text(
                  'Itemized Items (${invoice.items.length})',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (invoice.items.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No item details recorded.'),
                    ),
                  )
                else
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: invoice.items.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = invoice.items[index];
                        return ListTile(
                          title: Text(item.productName, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('SKU: ${item.productSku} | Qty: ${item.quantity} x ₹${item.unitPrice.toStringAsFixed(2)}'),
                          trailing: Text(
                            currencyFormat.format(item.lineTotal),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 20),

                // Action Buttons Banner
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          InvoicePdfService.printOrShareInvoice(
                            invoice: invoice,
                            isThermalReceipt: true,
                          );
                        },
                        icon: const Icon(Icons.receipt_long),
                        label: const Text('Thermal Receipt'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          InvoicePdfService.printOrShareInvoice(
                            invoice: invoice,
                            isThermalReceipt: false,
                          );
                        },
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text('A4 PDF Invoice'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (!invoice.isVoid && invoice.balanceAmount > 0) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showAddPaymentDialog(invoice.balanceAmount),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.add_card),
                      label: Text('Collect Payment (${currencyFormat.format(invoice.balanceAmount)})'),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                if (!invoice.isVoid)
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: _showVoidDialog,
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      icon: const Icon(Icons.block_outlined),
                      label: const Text('Void Transaction'),
                    ),
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading invoice: $err')),
      ),
    );
  }

  Widget _buildAmountSummary(String title, String amount, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(
          amount,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
