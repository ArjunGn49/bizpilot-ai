import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'package:bizpilotai/core/widgets/barcode_scanner_dialog.dart';
import 'package:bizpilotai/features/customers/domain/entities/customer.dart';
import 'package:bizpilotai/features/customers/presentation/providers/customers_provider.dart';
import 'package:bizpilotai/features/invoices/domain/entities/invoice.dart';
import 'package:bizpilotai/features/invoices/domain/entities/invoice_item.dart';
import 'package:bizpilotai/features/invoices/domain/entities/payment.dart';
import 'package:bizpilotai/features/invoices/domain/use_cases/create_invoice_use_case.dart';
import 'package:bizpilotai/features/invoices/presentation/services/invoice_pdf_service.dart';
import 'package:bizpilotai/features/products/domain/entities/product.dart';
import 'package:bizpilotai/features/products/presentation/providers/products_provider.dart';

class _CartItem {
  final Product product;
  int quantity;

  _CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get unitPrice => product.sellingPrice;
  double get lineTotal => unitPrice * quantity;
}

class CreateInvoiceScreen extends ConsumerStatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  ConsumerState<CreateInvoiceScreen> createState() =>
      _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends ConsumerState<CreateInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _discountController = TextEditingController(text: '0');
  final _taxController = TextEditingController(text: '0');
  final _initialPaymentController = TextEditingController();
  final _noteController = TextEditingController();

  final List<_CartItem> _cart = [];
  Customer? _selectedCustomer;
  String _paymentMethod = 'CASH';
  bool _isLoading = false;
  Invoice? _createdInvoice;

  @override
  void dispose() {
    _discountController.dispose();
    _taxController.dispose();
    _initialPaymentController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  double get _subtotal => _cart.fold(0.0, (sum, item) => sum + item.lineTotal);

  double get _discountAmount =>
      double.tryParse(_discountController.text.trim()) ?? 0.0;

  double get _taxAmount => double.tryParse(_taxController.text.trim()) ?? 0.0;

  double get _total {
    final t = _subtotal - _discountAmount + _taxAmount;
    return t < 0 ? 0.0 : t;
  }

  void _addToCart(Product product) {
    if (product.stockQuantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} is currently out of stock.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final existingIndex =
        _cart.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      final currentQty = _cart[existingIndex].quantity;
      if (currentQty + 1 > product.stockQuantity) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Cannot exceed available stock (${product.stockQuantity} available).'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      setState(() {
        _cart[existingIndex].quantity++;
      });
    } else {
      setState(() {
        _cart.add(_CartItem(product: product, quantity: 1));
      });
    }
  }

  void _updateQuantity(_CartItem item, int delta) {
    final newQty = item.quantity + delta;

    if (newQty <= 0) {
      _removeFromCart(item);
      return;
    }

    if (newQty > item.product.stockQuantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Cannot exceed available stock (${item.product.stockQuantity} available).'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      item.quantity = newQty;
    });
  }

  void _removeFromCart(_CartItem item) {
    setState(() {
      _cart.removeWhere((i) => i.product.id == item.product.id);
    });
  }

  Future<void> _scanBarcode(List<Product> availableProducts) async {
    final scannedCode = await BarcodeScannerDialog.scan(context);
    if (!mounted) return;

    if (scannedCode != null && scannedCode.isNotEmpty) {
      final matchingProduct = availableProducts.cast<Product?>().firstWhere(
            (p) =>
                p != null && (p.barcode == scannedCode || p.sku == scannedCode),
            orElse: () => null,
          );

      if (matchingProduct != null) {
        _addToCart(matchingProduct);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added ${matchingProduct.name} to cart!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No product found with barcode: $scannedCode'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showAddProductDialog(List<Product> availableProducts) {
    String query = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = availableProducts.where((p) {
              if (query.isEmpty) return true;
              final q = query.toLowerCase();
              return p.name.toLowerCase().contains(q) ||
                  p.sku.toLowerCase().contains(q) ||
                  (p.barcode != null && p.barcode!.toLowerCase().contains(q));
            }).toList();

            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Select Product to Add',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      onChanged: (val) {
                        setModalState(() {
                          query = val;
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: 'Search product name, SKU, or barcode...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: filtered.isEmpty
                          ? const Center(
                              child: Text('No matching products found.'))
                          : ListView.builder(
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final product = filtered[index];
                                final isOutOfStock = product.stockQuantity <= 0;

                                return ListTile(
                                  title: Text(
                                    product.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Text(
                                    'SKU: ${product.sku} | Stock: ${product.stockQuantity} units',
                                    style: TextStyle(
                                      color: isOutOfStock
                                          ? Colors.red
                                          : Colors.grey,
                                    ),
                                  ),
                                  trailing: Text(
                                    '₹${product.sellingPrice.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  enabled: !isOutOfStock,
                                  onTap: () {
                                    Navigator.of(ctx).pop();
                                    _addToCart(product);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _submit() async {
    if (_isLoading) return;

    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one product item to the invoice.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    // Verify stock limits again
    for (final item in _cart) {
      if (item.quantity > item.product.stockQuantity) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${item.product.name} quantity exceeds available stock (${item.product.stockQuantity}).'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    final totalAmount = _total;

    // Determine initial payment
    double initialPayment = totalAmount;
    if (_initialPaymentController.text.trim().isNotEmpty) {
      final parsed = double.tryParse(_initialPaymentController.text.trim());
      if (parsed == null || parsed < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid initial payment amount.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      if (parsed > totalAmount) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Initial payment cannot exceed invoice total.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      initialPayment = parsed;
    }

    setState(() => _isLoading = true);

    final invoiceId = const Uuid().v4();
    final now = DateTime.now();

    final invoiceItems = _cart.map((cartItem) {
      return InvoiceItem(
        id: const Uuid().v4(),
        invoiceId: invoiceId,
        productId: cartItem.product.id,
        productName: cartItem.product.name,
        productSku: cartItem.product.sku,
        unitPrice: cartItem.unitPrice,
        quantity: cartItem.quantity,
        lineTotal: cartItem.lineTotal,
        createdAt: now,
      );
    }).toList();

    final paidAmount = initialPayment.clamp(0.0, totalAmount);
    final balanceAmount = totalAmount - paidAmount;
    final paymentStatus = (paidAmount >= totalAmount && totalAmount > 0)
        ? 'PAID'
        : (paidAmount > 0 ? 'PARTIAL' : 'UNPAID');

    final invoice = Invoice(
      id: invoiceId,
      invoiceNumber: 0, // Assigned inside AppDatabase.createInvoiceTx
      customerId: _selectedCustomer?.id,
      subtotal: _subtotal,
      discountAmount: _discountAmount,
      discountType: 'FLAT',
      taxAmount: _taxAmount,
      taxType: 'FLAT',
      total: totalAmount,
      paidAmount: paidAmount,
      balanceAmount: balanceAmount,
      paymentStatus: paymentStatus,
      status: 'ACTIVE',
      note: _noteController.text.trim().isNotEmpty
          ? _noteController.text.trim()
          : null,
      createdAt: now,
      updatedAt: now,
      items: invoiceItems,
      payments: [],
    );

    final List<Payment> initialPayments = [];
    if (paidAmount > 0) {
      initialPayments.add(Payment(
        id: const Uuid().v4(),
        invoiceId: invoiceId,
        amount: paidAmount,
        method: _paymentMethod,
        note: 'Initial Checkout Payment',
        createdAt: now,
      ));
    }

    final result = await ref.read(createInvoiceUseCaseProvider).call(
          invoice: invoice,
          initialPayments: initialPayments,
        );

    if (mounted) {
      setState(() => _isLoading = false);
      result.when(
        success: (assignedNumber) {
          final completedInvoice =
              invoice.copyWith(invoiceNumber: assignedNumber);
          setState(() {
            _createdInvoice = completedInvoice;
            _cart.clear();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Tax Invoice #$assignedNumber created & saved successfully!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        failure: (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save invoice: ${failure.message}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);
    final customersAsync = ref.watch(customersProvider);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currencyFormat = NumberFormat.currency(symbol: '₹');

    final availableProducts = productsAsync.value ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create POS Invoice'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Scan Item Barcode',
            onPressed: () => _scanBarcode(availableProducts),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Customer Selector & Barcode Scanner Tile
                    Card(
                      elevation: 0.5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: colorScheme.outlineVariant),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Customer Selection',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            customersAsync.when(
                              data: (customers) {
                                return DropdownButtonFormField<Customer?>(
                                  initialValue: _selectedCustomer,
                                  decoration: const InputDecoration(
                                    labelText:
                                        'Select Customer (Default: Walk-in)',
                                    prefixIcon: Icon(Icons.person_outline),
                                    border: OutlineInputBorder(),
                                  ),
                                  items: [
                                    const DropdownMenuItem<Customer?>(
                                      value: null,
                                      child: Text('Walk-in Customer'),
                                    ),
                                    ...customers.map((c) {
                                      return DropdownMenuItem<Customer?>(
                                        value: c,
                                        child: Text('${c.name} (${c.phone})'),
                                      );
                                    }),
                                  ],
                                  onChanged: (val) {
                                    setState(() {
                                      _selectedCustomer = val;
                                    });
                                  },
                                );
                              },
                              loading: () => const LinearProgressIndicator(),
                              error: (err, _) =>
                                  Text('Error loading customers: $err'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Cart Header & Add Product Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Invoice Line Items (${_cart.length})',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () =>
                              _showAddProductDialog(availableProducts),
                          icon: const Icon(Icons.add_shopping_cart, size: 18),
                          label: const Text('Add Product'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Itemized Cart List
                    if (_cart.isEmpty)
                      Card(
                        elevation: 0,
                        color: colorScheme.surfaceContainerHighest
                            .withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: colorScheme.outlineVariant),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 32.0, horizontal: 16.0),
                          child: Column(
                            children: [
                              Icon(Icons.shopping_bag_outlined,
                                  size: 48, color: Colors.grey),
                              SizedBox(height: 8),
                              Text(
                                'No products in invoice cart.',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Tap "Add Product" or scan a barcode to add line items.',
                                textAlign: TextAlign.center,
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _cart.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = _cart[index];
                          return Card(
                            elevation: 0.5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side:
                                  BorderSide(color: colorScheme.outlineVariant),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.product.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'SKU: ${item.product.sku} | Unit: ₹${item.unitPrice.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                              fontSize: 12, color: Colors.grey),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Total: ₹${item.lineTotal.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.primary,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Quantity Controls
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                            Icons.remove_circle_outline,
                                            size: 22),
                                        color: Colors.redAccent,
                                        onPressed: () =>
                                            _updateQuantity(item, -1),
                                      ),
                                      Text(
                                        '${item.quantity}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                            Icons.add_circle_outline,
                                            size: 22),
                                        color: colorScheme.primary,
                                        onPressed: () =>
                                            _updateQuantity(item, 1),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline,
                                            size: 22),
                                        color: Colors.red,
                                        onPressed: () => _removeFromCart(item),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 20),

                    // Financial Calculations Card
                    Card(
                      elevation: 0.5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: colorScheme.outlineVariant),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Billing & Payment Details',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Subtotal:'),
                                Text(
                                  currencyFormat.format(_subtotal),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _discountController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    decoration: const InputDecoration(
                                      labelText: 'Discount (₹)',
                                      prefixIcon: Icon(Icons.discount_outlined),
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: _taxController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    decoration: const InputDecoration(
                                      labelText: 'Tax (₹)',
                                      prefixIcon: Icon(Icons.percent_rounded),
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Grand Total:',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  currencyFormat.format(_total),
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _initialPaymentController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    decoration: InputDecoration(
                                      labelText: 'Payment Received (₹)',
                                      hintText:
                                          'Default: ${currencyFormat.format(_total)}',
                                      prefixIcon:
                                          const Icon(Icons.currency_rupee),
                                      border: const OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    initialValue: _paymentMethod,
                                    decoration: const InputDecoration(
                                      labelText: 'Payment Method',
                                      prefixIcon: Icon(Icons.payment_outlined),
                                      border: OutlineInputBorder(),
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                          value: 'CASH', child: Text('Cash')),
                                      DropdownMenuItem(
                                          value: 'CARD',
                                          child: Text('Card / POS')),
                                      DropdownMenuItem(
                                          value: 'UPI',
                                          child: Text('UPI / QR')),
                                      DropdownMenuItem(
                                          value: 'BANK_TRANSFER',
                                          child: Text('Bank Transfer')),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() {
                                          _paymentMethod = val;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _noteController,
                              decoration: const InputDecoration(
                                labelText: 'Note / Instructions (Optional)',
                                prefixIcon: Icon(Icons.note_outlined),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Complete Order Action Button
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.check_circle_outline),
                      label: Text(
                        _isLoading
                            ? 'Saving Invoice...'
                            : 'Save & Issue Tax Invoice',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),

                    if (_createdInvoice != null) ...[
                      const SizedBox(height: 28),
                      const Divider(),
                      const SizedBox(height: 12),
                      Text(
                        'Tax Invoice #${_createdInvoice!.invoiceNumber} Actions',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                InvoicePdfService.printOrShareInvoice(
                                  invoice: _createdInvoice!,
                                  customerName: _selectedCustomer?.name,
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
                                  invoice: _createdInvoice!,
                                  customerName: _selectedCustomer?.name,
                                  isThermalReceipt: false,
                                );
                              },
                              icon: const Icon(Icons.picture_as_pdf),
                              label: const Text('Print A4 PDF'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}
