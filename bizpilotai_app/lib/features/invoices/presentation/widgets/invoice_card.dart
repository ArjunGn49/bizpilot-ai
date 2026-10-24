import 'package:flutter/material.dart';
import 'package:bizpilotai/features/invoices/domain/entities/invoice.dart';
import 'package:intl/intl.dart';

class InvoiceCard extends StatelessWidget {
  final Invoice invoice;
  final VoidCallback onTap;

  const InvoiceCard({
    super.key,
    required this.invoice,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final dateFormat = DateFormat.yMMMd();

    Color statusColor;
    switch (invoice.status) {
      case 'VOID':
        statusColor = Colors.grey;
        break;
      default:
        switch (invoice.paymentStatus) {
          case 'PAID':
            statusColor = Colors.green;
            break;
          case 'PARTIAL':
            statusColor = Colors.orange;
            break;
          default:
            statusColor = Colors.red;
        }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: ListTile(
        onTap: onTap,
        title: Text(
          'Invoice #${invoice.invoiceNumber}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Date: ${dateFormat.format(invoice.createdAt)}'),
            const SizedBox(height: 4),
            Text('Status: ${invoice.paymentStatus} ${invoice.isVoid ? "(VOID)" : ""}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              currencyFormat.format(invoice.total),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
            if (invoice.balanceAmount > 0 && !invoice.isVoid) ...[
              const SizedBox(height: 4),
              Text(
                'Due: ${currencyFormat.format(invoice.balanceAmount)}',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
