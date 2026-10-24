import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:bizpilotai/core/router/route_constants.dart';
import 'package:bizpilotai/features/customers/domain/entities/customer.dart';
import 'package:bizpilotai/features/customers/domain/use_cases/delete_customer_use_case.dart';
import 'package:bizpilotai/features/customers/presentation/providers/customers_provider.dart';
import 'package:bizpilotai/features/invoices/domain/entities/payment.dart';
import 'package:bizpilotai/features/invoices/domain/use_cases/add_payment_use_case.dart';
import 'package:bizpilotai/features/invoices/presentation/widgets/invoice_card.dart';

class CustomerDetailScreen extends ConsumerStatefulWidget {
  final String customerId;

  const CustomerDetailScreen({super.key, required this.customerId});

  @override
  ConsumerState<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends ConsumerState<CustomerDetailScreen> {
  Future<void> _confirmDeleteCustomer(Customer customer) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Customer'),
        content: Text('Are you sure you want to delete ${customer.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final res = await ref.read(deleteCustomerUseCaseProvider).call(customer.id);
      if (mounted) {
        res.when(
          success: (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Customer deleted')),
            );
            context.pop();
          },
          failure: (f) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(f.message), backgroundColor: Colors.red),
            );
          },
        );
      }
    }
  }

  Future<void> _showCollectPaymentDialog(Customer customer) async {
    final customerInvoices =
        ref.read(customerInvoicesProvider(customer.id)).value ?? [];
    final unpaidInvoices = customerInvoices
        .where((inv) => !inv.isVoid && inv.balanceAmount > 0)
        .toList();

    if (unpaidInvoices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No pending unpaid invoices for this customer.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final targetInvoice = unpaidInvoices.first;
    final amountController =
        TextEditingController(text: targetInvoice.balanceAmount.toStringAsFixed(2));
    final noteController = TextEditingController();
    String paymentMethod = 'CASH';

    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Collect Payment (${customer.name})'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Invoice #${targetInvoice.invoiceNumber} Balance: ₹${targetInvoice.balanceAmount.toStringAsFixed(2)}'),
              const SizedBox(height: 12),
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
                  if (parsed > targetInvoice.balanceAmount) return 'Exceeds invoice balance';
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
                  DropdownMenuItem(value: 'CARD', child: Text('Card')),
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
        invoiceId: targetInvoice.id,
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
                content: Text('Payment recorded & customer balance updated!'),
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
    final customerAsync = ref.watch(customerDetailProvider(widget.customerId));
    final customerInvoicesAsync = ref.watch(customerInvoicesProvider(widget.customerId));

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currencyFormat = NumberFormat.currency(symbol: '₹');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Profile'),
      ),
      body: customerAsync.when(
        data: (customer) {
          if (customer == null) {
            return const Center(child: Text('Customer not found'));
          }

          final initials = customer.name.isNotEmpty
              ? customer.name.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase()
              : '?';

          final customerInvoices = customerInvoicesAsync.value ?? [];
          final totalPurchases = customerInvoices
              .where((inv) => !inv.isVoid)
              .fold<double>(0.0, (sum, inv) => sum + inv.total);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: colorScheme.primaryContainer,
                              child: Text(
                                initials,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    customer.name,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.phone_outlined, size: 16, color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Text(customer.phone, style: const TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                                  if (customer.email != null && customer.email!.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        const Icon(Icons.email_outlined, size: 16, color: Colors.grey),
                                        const SizedBox(width: 6),
                                        Text(customer.email!, style: const TextStyle(color: Colors.grey)),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (customer.address != null && customer.address!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  customer.address!,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const Divider(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  context.push(RoutePaths.customersAdd, extra: customer);
                                },
                                icon: const Icon(Icons.edit_outlined),
                                label: const Text('Edit Profile'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              tooltip: 'Delete Customer',
                              onPressed: () => _confirmDeleteCustomer(customer),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Financial Credit & Outstanding Summary
                Card(
                  elevation: 2,
                  color: customer.totalOutstanding > 0
                      ? colorScheme.errorContainer.withOpacity(0.3)
                      : colorScheme.primaryContainer.withOpacity(0.3),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildSummaryCol('Total Orders', customerInvoices.length.toString(), Colors.blue),
                            _buildSummaryCol('Total Spent', currencyFormat.format(totalPurchases), Colors.green),
                            _buildSummaryCol(
                              'Outstanding Due',
                              currencyFormat.format(customer.totalOutstanding),
                              customer.totalOutstanding > 0 ? Colors.red : Colors.green,
                            ),
                          ],
                        ),
                        if (customer.totalOutstanding > 0) ...[
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _showCollectPaymentDialog(customer),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              icon: const Icon(Icons.payments_outlined),
                              label: Text('Collect Payment (${currencyFormat.format(customer.totalOutstanding)})'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Payment reminder sent to ${customer.name} (${customer.phone})!'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.mark_email_read_outlined, size: 18),
                              label: const Text('Send WhatsApp / SMS Reminder'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Customer Purchase & Invoice History Feed
                Text(
                  'Purchase History (${customerInvoices.length})',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (customerInvoices.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Center(child: Text('No purchase transactions recorded yet.')),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: customerInvoices.length,
                    itemBuilder: (context, index) {
                      final invoice = customerInvoices[index];
                      return InvoiceCard(
                        invoice: invoice,
                        onTap: () {
                          final location = RoutePaths.invoiceDetail.replaceAll(':id', invoice.id);
                          context.push(location);
                        },
                      );
                    },
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading customer details: $err')),
      ),
    );
  }

  Widget _buildSummaryCol(String title, String value, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
