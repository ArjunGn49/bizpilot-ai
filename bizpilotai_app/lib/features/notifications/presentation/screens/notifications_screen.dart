import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:bizpilotai/features/invoices/presentation/providers/invoices_provider.dart';
import 'package:bizpilotai/features/products/presentation/providers/products_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  int _selectedFilter = 0; // 0: All, 1: Stock, 2: Payments

  @override
  Widget build(BuildContext context) {
    final lowStockAsync = ref.watch(lowStockProductsProvider);
    final invoicesAsync = ref.watch(invoicesProvider);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currencyFormat = NumberFormat.currency(symbol: '₹');

    final lowStockItems = lowStockAsync.value ?? [];
    final unpaidInvoices = (invoicesAsync.value ?? []).where((i) => !i.isVoid && i.balanceAmount > 0).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications & Alerts'),
      ),
      body: Column(
        children: [
          // Filter Segment
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 0, label: Text('All Alerts')),
                  ButtonSegment(value: 1, label: Text('Low Stock')),
                  ButtonSegment(value: 2, label: Text('Payment Dues')),
                ],
                selected: {_selectedFilter},
                onSelectionChanged: (val) {
                  setState(() {
                    _selectedFilter = val.first;
                  });
                },
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // Stock Warning Items
                if (_selectedFilter == 0 || _selectedFilter == 1) ...[
                  if (lowStockItems.isEmpty && _selectedFilter == 1)
                    const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(child: Text('No low stock alerts! All inventory level is sufficient.')),
                    )
                  else
                    ...lowStockItems.map((prod) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: colorScheme.errorContainer.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: colorScheme.error.withOpacity(0.3)),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: colorScheme.error.withOpacity(0.2),
                            child: Icon(Icons.warning_amber_rounded, color: colorScheme.error),
                          ),
                          title: Text('Low Stock Alert: ${prod.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('SKU: ${prod.sku} | Only ${prod.stockQuantity} remaining (Alert threshold: ${prod.lowStockThreshold})'),
                          trailing: const Icon(Icons.chevron_right),
                        ),
                      );
                    }),
                ],

                // Overdue Invoices
                if (_selectedFilter == 0 || _selectedFilter == 2) ...[
                  if (unpaidInvoices.isEmpty && _selectedFilter == 2)
                    const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(child: Text('No pending customer balance alerts.')),
                    )
                  else
                    ...unpaidInvoices.map((inv) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: colorScheme.outlineVariant),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: colorScheme.primaryContainer,
                            child: Icon(Icons.receipt_long_outlined, color: colorScheme.primary),
                          ),
                          title: Text('Unpaid Invoice #${inv.invoiceNumber}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Balance Due: ${currencyFormat.format(inv.balanceAmount)} | Customer: ${inv.customerId ?? 'Walk-in'}'),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.orange.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                            child: Text(inv.paymentStatus, style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 11)),
                          ),
                        ),
                      );
                    }),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
