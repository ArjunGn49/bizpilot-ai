import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bizpilotai/core/router/route_constants.dart';
import 'package:bizpilotai/features/invoices/presentation/providers/invoices_provider.dart';
import 'package:bizpilotai/features/invoices/presentation/widgets/invoice_card.dart';

class InvoiceListScreen extends ConsumerStatefulWidget {
  const InvoiceListScreen({super.key});

  @override
  ConsumerState<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends ConsumerState<InvoiceListScreen> {
  String _selectedStatusFilter = 'All';
  String _searchQuery = '';

  static const List<String> _statusFilters = ['All', 'Paid', 'Pending', 'Void'];

  @override
  Widget build(BuildContext context) {
    final invoicesAsync = ref.watch(invoicesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices Management'),
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search invoice # or customer ID...',
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
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Status Filter Chips
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _statusFilters.length,
              itemBuilder: (context, index) {
                final status = _statusFilters[index];
                final isSelected = status == _selectedStatusFilter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(status),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedStatusFilter = status;
                        });
                      }
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: invoicesAsync.when(
              data: (invoices) {
                final filtered = invoices.where((inv) {
                  // Status Filter
                  if (_selectedStatusFilter == 'Paid' && inv.paymentStatus != 'PAID') return false;
                  if (_selectedStatusFilter == 'Pending' && (inv.paymentStatus == 'PAID' || inv.isVoid)) return false;
                  if (_selectedStatusFilter == 'Void' && !inv.isVoid) return false;

                  // Search Filter
                  if (_searchQuery.isEmpty) return true;
                  final q = _searchQuery.toLowerCase();
                  return inv.invoiceNumber.toString().contains(q) ||
                      (inv.customerId != null && inv.customerId!.toLowerCase().contains(q));
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      _searchQuery.isEmpty && _selectedStatusFilter == 'All'
                          ? 'No invoices found. Create one!'
                          : 'No matching invoices found.',
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final invoice = filtered[index];
                    return InvoiceCard(
                      invoice: invoice,
                      onTap: () {
                        final location = RoutePaths.invoiceDetail.replaceAll(':id', invoice.id);
                        context.push(location);
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error loading invoices: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(RoutePaths.invoicesCreate),
        child: const Icon(Icons.add),
      ),
    );
  }
}
