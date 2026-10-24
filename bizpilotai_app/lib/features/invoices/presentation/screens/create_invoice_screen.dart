import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bizpilotai/features/invoices/domain/entities/invoice.dart';
import 'package:bizpilotai/features/invoices/domain/use_cases/create_invoice_use_case.dart';
import 'package:bizpilotai/features/invoices/presentation/services/invoice_pdf_service.dart';
import 'package:bizpilotai/core/widgets/barcode_scanner_dialog.dart';
import 'package:uuid/uuid.dart';

class CreateInvoiceScreen extends ConsumerStatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  ConsumerState<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends ConsumerState<CreateInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerController = TextEditingController();
  final _subtotalController = TextEditingController();
  final _taxController = TextEditingController();
  final _scannedBarcodeController = TextEditingController();

  bool _isLoading = false;
  Invoice? _createdInvoice;

  @override
  void dispose() {
    _customerController.dispose();
    _subtotalController.dispose();
    _taxController.dispose();
    _scannedBarcodeController.dispose();
    super.dispose();
  }

  Future<void> _scanBarcode() async {
    final scannedCode = await BarcodeScannerDialog.scan(context);
    if (!mounted) return;
    if (scannedCode != null && scannedCode.isNotEmpty) {
      setState(() {
        _scannedBarcodeController.text = scannedCode;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Scanned Item Barcode: $scannedCode')),
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final subtotal = double.tryParse(_subtotalController.text) ?? 0.0;
    final tax = double.tryParse(_taxController.text) ?? 0.0;
    final total = subtotal + tax;

    final invoice = Invoice(
      id: const Uuid().v4(),
      invoiceNumber: DateTime.now().millisecondsSinceEpoch % 100000,
      customerId: _customerController.text.isNotEmpty ? _customerController.text : null,
      subtotal: subtotal,
      discountAmount: 0,
      discountType: 'FLAT',
      taxAmount: tax,
      taxType: 'FLAT',
      total: total,
      paidAmount: total,
      balanceAmount: 0,
      paymentStatus: 'PAID',
      status: 'ACTIVE',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      items: [],
      payments: [],
    );

    final result = await ref.read(createInvoiceUseCaseProvider).call(
      invoice: invoice,
      initialPayments: [],
    );

    if (mounted) {
      setState(() => _isLoading = false);
      result.when(
        success: (_) {
          setState(() {
            _createdInvoice = invoice;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invoice created successfully!')),
          );
        },
        failure: (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(failure.message)),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create POS Invoice'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Scan Barcode',
            onPressed: _scanBarcode,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Barcode Scan Banner
                    Card(
                      elevation: 1,
                      color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            const Icon(Icons.search_rounded),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _scannedBarcodeController.text.isEmpty
                                    ? 'Tap camera button to scan barcode'
                                    : 'Scanned: ${_scannedBarcodeController.text}',
                                style: TextStyle(
                                  fontWeight: _scannedBarcodeController.text.isNotEmpty
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: _scanBarcode,
                              icon: const Icon(Icons.camera_alt_outlined, size: 18),
                              label: const Text('Scan'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Inputs
                    TextFormField(
                      controller: _customerController,
                      decoration: const InputDecoration(
                        labelText: 'Customer Name / Phone (Optional)',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _subtotalController,
                      decoration: const InputDecoration(
                        labelText: 'Subtotal Amount (₹)',
                        prefixIcon: Icon(Icons.currency_rupee),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a subtotal';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _taxController,
                      decoration: const InputDecoration(
                        labelText: 'Tax Amount (₹)',
                        prefixIcon: Icon(Icons.percent_rounded),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 28),

                    // Submit Button
                    ElevatedButton.icon(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Save & Complete Invoice', style: TextStyle(fontSize: 16)),
                    ),

                    if (_createdInvoice != null) ...[
                      const SizedBox(height: 28),
                      const Divider(),
                      const SizedBox(height: 12),
                      Text(
                        'Invoice #${_createdInvoice!.invoiceNumber} Actions',
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
                                  customerName: _customerController.text,
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
                                  customerName: _customerController.text,
                                  isThermalReceipt: false,
                                );
                              },
                              icon: const Icon(Icons.picture_as_pdf),
                              label: const Text('Print PDF'),
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
