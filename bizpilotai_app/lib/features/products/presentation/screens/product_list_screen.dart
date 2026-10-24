import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bizpilotai/core/router/route_constants.dart';
import 'package:bizpilotai/core/widgets/barcode_scanner_dialog.dart';
import 'package:bizpilotai/features/products/presentation/providers/categories_provider.dart';
import 'package:bizpilotai/features/products/presentation/providers/products_provider.dart';
import 'package:bizpilotai/features/products/presentation/widgets/product_card.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  String _searchQuery = '';
  String? _selectedCategoryId;
  bool _onlyLowStock = false;

  Future<void> _scanBarcode() async {
    final scannedCode = await BarcodeScannerDialog.scan(context);
    if (!mounted) return;
    if (scannedCode != null && scannedCode.isNotEmpty) {
      setState(() {
        _searchQuery = scannedCode;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Scanned barcode: $scannedCode')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products Inventory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Scan Barcode',
            onPressed: _scanBarcode,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Scan Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search product or scan barcode...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : IconButton(
                        icon: const Icon(Icons.camera_alt_outlined),
                        onPressed: _scanBarcode,
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Category Filter Chips Bar
          categoriesAsync.when(
            data: (categories) {
              return SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        selected: _selectedCategoryId == null && !_onlyLowStock,
                        label: const Text('All Products'),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedCategoryId = null;
                              _onlyLowStock = false;
                            });
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        selected: _onlyLowStock,
                        avatar: const Icon(Icons.warning_amber_rounded, size: 16, color: Colors.red),
                        label: const Text('Low Stock Alerts'),
                        onSelected: (selected) {
                          setState(() {
                            _onlyLowStock = selected;
                            if (selected) _selectedCategoryId = null;
                          });
                        },
                      ),
                    ),
                    ...categories.map((cat) {
                      final isSelected = cat.id == _selectedCategoryId;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          selected: isSelected,
                          label: Text(cat.name),
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategoryId = selected ? cat.id : null;
                              _onlyLowStock = false;
                            });
                          },
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
            loading: () => const SizedBox(height: 40),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: productsAsync.when(
              data: (products) {
                final filtered = products.where((p) {
                  // Low Stock Filter
                  if (_onlyLowStock && p.stockQuantity > p.lowStockThreshold) return false;

                  // Category Filter
                  if (_selectedCategoryId != null && p.categoryId != _selectedCategoryId) return false;

                  // Search Filter
                  if (_searchQuery.isEmpty) return true;
                  final q = _searchQuery.toLowerCase();
                  return p.name.toLowerCase().contains(q) ||
                      p.sku.toLowerCase().contains(q) ||
                      (p.barcode != null && p.barcode!.toLowerCase().contains(q));
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      _searchQuery.isEmpty && _selectedCategoryId == null && !_onlyLowStock
                          ? 'No products found. Add one!'
                          : 'No products matching selected filters.',
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final product = filtered[index];
                    return ProductCard(
                      product: product,
                      onTap: () {
                        final location = RoutePaths.productDetail.replaceAll(':id', product.id);
                        context.push(location);
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error loading products: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(RoutePaths.productsAdd),
        child: const Icon(Icons.add),
      ),
    );
  }
}
