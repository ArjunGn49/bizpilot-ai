import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bizpilotai/core/router/route_constants.dart';
import 'package:bizpilotai/features/customers/presentation/providers/customers_provider.dart';
import 'package:bizpilotai/features/customers/presentation/widgets/customer_card.dart';

class CustomerListScreen extends ConsumerWidget {
  const CustomerListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersAsync = ref.watch(customersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers Directory'),
      ),
      body: customersAsync.when(
        data: (customers) {
          if (customers.isEmpty) {
            return const Center(child: Text('No customers found. Add one!'));
          }
          return ListView.builder(
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final customer = customers[index];
              return CustomerCard(
                customer: customer,
                onTap: () {
                  final location = RoutePaths.customerDetail.replaceAll(':id', customer.id);
                  context.push(location);
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading customers: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(RoutePaths.customersAdd),
        child: const Icon(Icons.add),
      ),
    );
  }
}
