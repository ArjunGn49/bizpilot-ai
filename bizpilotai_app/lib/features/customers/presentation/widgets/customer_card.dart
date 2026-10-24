import 'package:flutter/material.dart';
import 'package:bizpilotai/features/customers/domain/entities/customer.dart';

class CustomerCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback? onTap;

  const CustomerCard({
    super.key,
    required this.customer,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasOutstanding = customer.totalOutstanding > 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        onTap: onTap,
        title: Text(
          customer.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(customer.phone),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${customer.totalOutstanding.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: hasOutstanding ? Theme.of(context).colorScheme.error : null,
              ),
            ),
            Text(
              'outstanding',
              style: TextStyle(
                fontSize: 12,
                color: hasOutstanding ? Theme.of(context).colorScheme.error : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
