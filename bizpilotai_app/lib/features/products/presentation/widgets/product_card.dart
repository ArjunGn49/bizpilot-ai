import 'package:flutter/material.dart';
import 'package:bizpilotai/features/products/domain/entities/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLowStock = product.stockQuantity <= product.lowStockThreshold;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        onTap: onTap,
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('SKU: ${product.sku} | Price: \$${product.sellingPrice.toStringAsFixed(2)}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${product.stockQuantity}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isLowStock ? Theme.of(context).colorScheme.error : null,
              ),
            ),
            Text(
              'in stock',
              style: TextStyle(
                fontSize: 12,
                color: isLowStock ? Theme.of(context).colorScheme.error : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
