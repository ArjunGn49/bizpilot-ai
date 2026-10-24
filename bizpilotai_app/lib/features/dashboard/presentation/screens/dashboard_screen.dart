import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:bizpilotai/core/router/route_constants.dart';
import 'package:bizpilotai/core/sync/sync_service.dart';
import 'package:bizpilotai/core/widgets/barcode_scanner_dialog.dart';
import 'package:bizpilotai/features/auth/presentation/providers/auth_controller.dart';
import 'package:bizpilotai/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:bizpilotai/features/invoices/presentation/providers/invoices_provider.dart';
import 'package:bizpilotai/features/products/presentation/providers/products_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _isSyncing = false;
  int _selectedTimeRange = 3; // 0: Today, 1: 7 Days, 2: Month, 3: All Time

  bool _isWithinDashboardRange(DateTime date) {
    final now = DateTime.now();
    if (_selectedTimeRange == 0) {
      return date.year == now.year && date.month == now.month && date.day == now.day;
    } else if (_selectedTimeRange == 1) {
      final diff = now.difference(date).inDays;
      return diff >= 0 && diff <= 7;
    } else if (_selectedTimeRange == 2) {
      return date.year == now.year && date.month == now.month;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    // Start periodic background cloud sync
    Future.microtask(() {
      ref.read(syncServiceProvider).startPeriodicSync();
    });
  }

  Future<void> _manualSync() async {
    setState(() => _isSyncing = true);
    await ref.read(syncServiceProvider).syncPendingData();
    if (mounted) {
      setState(() => _isSyncing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cloud sync completed!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _scanBarcodeShortcut() async {
    final barcode = await BarcodeScannerDialog.scan(context);
    if (barcode != null && barcode.isNotEmpty && mounted) {
      context.push(RoutePaths.products);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isLoggingOut = ref.watch(authControllerProvider).isLoading;
    final invoicesAsync = ref.watch(invoicesProvider);
    final lowStockAsync = ref.watch(lowStockProductsProvider);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currencyFormat = NumberFormat.currency(symbol: '₹');

    return Scaffold(
      appBar: AppBar(
        title: const Text('BizPilot AI Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'BizPilot AI Assistant',
            onPressed: () => context.push(RoutePaths.aiAssistant),
          ),
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            tooltip: 'Sales Analytics & Reports',
            onPressed: () => context.push(RoutePaths.analytics),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'App & Store Settings',
            onPressed: () => context.push(RoutePaths.settings),
          ),
          IconButton(
            icon: _isSyncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.cloud_sync_outlined),
            tooltip: 'Sync Cloud Data',
            onPressed: _isSyncing ? null : _manualSync,
          ),
          IconButton(
            icon: isLoggingOut
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: isLoggingOut
                ? null
                : () {
                    ref.read(authControllerProvider.notifier).signOut();
                  },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Greeting
            authState.when(
              data: (state) => state.maybeWhen(
                authenticated: (userId, email) => Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: colorScheme.primaryContainer,
                      child: Icon(Icons.person, color: colorScheme.primary),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          email ?? 'User',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                orElse: () => const SizedBox.shrink(),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 20),

            // Revenue Summary
            invoicesAsync.when(
              data: (invoices) {
                final validInvoices = invoices.where((inv) => !inv.isVoid && _isWithinDashboardRange(inv.createdAt)).toList();
                final totalRevenue = validInvoices.fold<double>(
                  0.0,
                  (sum, inv) => sum + inv.total,
                );
                final totalPaid = validInvoices.fold<double>(
                  0.0,
                  (sum, inv) => sum + inv.paidAmount,
                );
                final totalBalance = validInvoices.fold<double>(
                  0.0,
                  (sum, inv) => sum + inv.balanceAmount,
                );

                return Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Sales Revenue',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                currencyFormat.format(totalRevenue),
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () => context.push(RoutePaths.analytics),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.analytics_rounded, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem('Collected', currencyFormat.format(totalPaid), Colors.green),
                          _buildStatItem('Pending Due', currencyFormat.format(totalBalance), Colors.redAccent),
                          _buildStatItem('Invoices', validInvoices.length.toString(), Colors.blue),
                        ],
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Text('Error loading revenue stats: $err'),
            ),
            const SizedBox(height: 20),

            // Low Stock Alert Banner
            lowStockAsync.when(
              data: (lowStockItems) {
                if (lowStockItems.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Card(
                    color: colorScheme.errorContainer.withOpacity(0.6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: Icon(Icons.warning_amber_rounded, color: colorScheme.error),
                      title: Text(
                        '${lowStockItems.length} Product(s) Low in Stock!',
                        style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.error),
                      ),
                      subtitle: Text(
                        lowStockItems.map((p) => '${p.name} (${p.stockQuantity})').join(', '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push(RoutePaths.products),
                    ),
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            // Quick POS Action Shortcuts
            Text(
              'Quick POS Shortcuts',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildShortcutButton(
                    context,
                    label: 'Create Invoice',
                    icon: Icons.point_of_sale_rounded,
                    color: Colors.indigo,
                    onTap: () => context.push(RoutePaths.invoicesCreate),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildShortcutButton(
                    context,
                    label: 'Scan Barcode',
                    icon: Icons.qr_code_scanner_rounded,
                    color: Colors.purple,
                    onTap: _scanBarcodeShortcut,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildShortcutButton(
                    context,
                    label: 'Add Product',
                    icon: Icons.add_box_rounded,
                    color: Colors.teal,
                    onTap: () => context.push(RoutePaths.productsAdd),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildShortcutButton(
                    context,
                    label: 'Add Customer',
                    icon: Icons.person_add_rounded,
                    color: Colors.orange,
                    onTap: () => context.push(RoutePaths.customersAdd),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Core Module Navigation Cards
            Text(
              'Management Modules',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12.0,
              crossAxisSpacing: 12.0,
              children: [
                _buildDashboardCard(
                  context,
                  title: 'Products',
                  icon: Icons.inventory_2_rounded,
                  color: Colors.blue,
                  onTap: () => context.push(RoutePaths.products),
                ),
                _buildDashboardCard(
                  context,
                  title: 'Customers',
                  icon: Icons.people_alt_rounded,
                  color: Colors.green,
                  onTap: () => context.push(RoutePaths.customers),
                ),
                _buildDashboardCard(
                  context,
                  title: 'Invoices',
                  icon: Icons.receipt_long_rounded,
                  color: Colors.orange,
                  onTap: () => context.push(RoutePaths.invoices),
                ),
                _buildDashboardCard(
                  context,
                  title: 'Expenses',
                  icon: Icons.money_off_rounded,
                  color: Colors.red,
                  onTap: () => context.push(RoutePaths.expenses),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildShortcutButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        backgroundColor: color.withOpacity(0.12),
        foregroundColor: color,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: Icon(icon, size: 20),
      label: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
