import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:bizpilotai/core/router/route_constants.dart';
import 'package:bizpilotai/features/products/domain/entities/product.dart';
import 'package:bizpilotai/features/products/domain/use_cases/delete_product_use_case.dart';
import 'package:bizpilotai/features/products/domain/use_cases/update_product_use_case.dart';
import 'package:bizpilotai/features/products/presentation/providers/products_provider.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  Future<void> _confirmDeleteProduct(Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete ${product.name}?'),
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
      final res = await ref.read(deleteProductUseCaseProvider).call(product.id);
      if (mounted) {
        res.when(
          success: (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Product deleted successfully')),
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

  Future<void> _showAdjustStockDialog(Product product) async {
    final qtyController = TextEditingController(text: '1');
    bool isAdding = true;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            title: Text('Adjust Stock (${product.name})'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('+ Restock'),
                        selected: isAdding,
                        onSelected: (val) => setModalState(() => isAdding = true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('- Deduct'),
                        selected: !isAdding,
                        onSelected: (val) => setModalState(() => isAdding = false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: qtyController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Quantity Units',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Save Stock'),
              ),
            ],
          );
        },
      ),
    );

    if (confirm == true && mounted) {
      final change = int.tryParse(qtyController.text.trim()) ?? 0;
      if (change <= 0) return;

      final newQty = isAdding ? product.stockQuantity + change : (product.stockQuantity - change).clamp(0, 999999);
      final updatedProduct = product.copyWith(stockQuantity: newQty, updatedAt: DateTime.now());

      final res = await ref.read(updateProductUseCaseProvider).call(updatedProduct);
      if (mounted) {
        res.when(
          success: (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Stock quantity updated to $newQty units!')),
            );
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

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailProvider(widget.productId));

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currencyFormat = NumberFormat.currency(symbol: '₹');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
      ),
      body: productAsync.when(
        data: (product) {
          if (product == null) {
            return const Center(child: Text('Product not found'));
          }

          final margin = product.sellingPrice - product.costPrice;
          final marginPct = product.sellingPrice > 0 ? (margin / product.sellingPrice) * 100 : 0.0;
          final isLowStock = product.stockQuantity <= product.lowStockThreshold;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Overview Header Card
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
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'SKU: ${product.sku}',
                                    style: TextStyle(
                                      color: colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isLowStock ? Colors.red.withOpacity(0.15) : Colors.green.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                isLowStock ? 'LOW STOCK' : 'IN STOCK',
                                style: TextStyle(
                                  color: isLowStock ? Colors.red : Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (product.barcode != null && product.barcode!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.qr_code, size: 18, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                'Barcode: ${product.barcode}',
                                style: const TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                        const Divider(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  context.push(RoutePaths.productsAdd, extra: product);
                                },
                                icon: const Icon(Icons.edit_outlined),
                                label: const Text('Edit Product'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              tooltip: 'Delete Product',
                              onPressed: () => _confirmDeleteProduct(product),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Stock & Inventory Card
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Inventory & Stock Level',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _showAdjustStockDialog(product),
                      icon: const Icon(Icons.tune, size: 16),
                      label: const Text('Adjust Stock'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCol(
                          'Current Stock',
                          '${product.stockQuantity} units',
                          isLowStock ? Colors.red : colorScheme.primary,
                        ),
                        _buildStatCol(
                          'Alert Threshold',
                          '${product.lowStockThreshold} units',
                          Colors.orange,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Financials & Profit Margin Card
                Text(
                  'Financials & Profit Margins',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatCol('Selling Price', currencyFormat.format(product.sellingPrice), Colors.green),
                            _buildStatCol('Cost Price', currencyFormat.format(product.costPrice), Colors.grey),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatCol('Profit Margin', currencyFormat.format(margin), margin >= 0 ? Colors.green : Colors.red),
                            _buildStatCol('Margin %', '${marginPct.toStringAsFixed(1)}%', marginPct >= 0 ? Colors.blue : Colors.red),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading product: $err')),
      ),
    );
  }

  Widget _buildStatCol(String title, String value, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
