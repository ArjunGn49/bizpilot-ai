import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:bizpilotai/features/invoices/presentation/providers/invoices_provider.dart';
import 'package:bizpilotai/features/expenses/presentation/providers/expenses_provider.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  int _selectedTab = 0; // 0: Today, 1: This Week, 2: This Month, 3: All Time

  bool _isWithinRange(DateTime date) {
    final now = DateTime.now();
    if (_selectedTab == 0) {
      // Today
      return date.year == now.year && date.month == now.month && date.day == now.day;
    } else if (_selectedTab == 1) {
      // Last 7 Days
      final diff = now.difference(date).inDays;
      return diff >= 0 && diff <= 7;
    } else if (_selectedTab == 2) {
      // This Month
      return date.year == now.year && date.month == now.month;
    }
    return true; // All Time
  }

  Widget _buildFinancialBarChart(double revenue, double expenses, BuildContext context) {
    final maxVal = (revenue > expenses ? revenue : expenses).clamp(1.0, double.infinity);
    final revRatio = (revenue / maxVal).clamp(0.08, 1.0);
    final expRatio = (expenses / maxVal).clamp(0.08, 1.0);

    final currencyFormat = NumberFormat.currency(symbol: '₹');

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sales vs Expense Visualization',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 140,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Revenue Bar
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(currencyFormat.format(revenue), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green)),
                      const SizedBox(height: 6),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        width: 48,
                        height: 90 * revRatio,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('Revenue', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  // Expense Bar
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(currencyFormat.format(expenses), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.orange)),
                      const SizedBox(height: 6),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        width: 48,
                        height: 90 * expRatio,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('Expenses', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final invoicesAsync = ref.watch(invoicesProvider);
    final expensesAsync = ref.watch(expensesProvider);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currencyFormat = NumberFormat.currency(symbol: '₹');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics & Financial Reports'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time Horizon Filter Segmented Button
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 0, label: Text('Today')),
                  ButtonSegment(value: 1, label: Text('7 Days')),
                  ButtonSegment(value: 2, label: Text('Month')),
                  ButtonSegment(value: 3, label: Text('All Time')),
                ],
                selected: {_selectedTab},
                onSelectionChanged: (newVal) {
                  setState(() {
                    _selectedTab = newVal.first;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),

            // Revenue vs Expenses Net Profit Card
            invoicesAsync.when(
              data: (allInvoices) {
                return expensesAsync.when(
                  data: (allExpenses) {
                    final filteredInvoices = allInvoices
                        .where((inv) => !inv.isVoid && _isWithinRange(inv.createdAt))
                        .toList();

                    final filteredExpenses = allExpenses
                        .where((exp) => _isWithinRange(exp.date))
                        .toList();

                    final grossRevenue = filteredInvoices.fold<double>(
                      0.0,
                      (sum, inv) => sum + inv.total,
                    );

                    final totalExpenses = filteredExpenses.fold<double>(
                      0.0,
                      (sum, exp) => sum + exp.amount,
                    );

                    final netProfit = grossRevenue - totalExpenses;
                    final profitMarginPct = grossRevenue > 0 ? (netProfit / grossRevenue) * 100 : 0.0;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Net Profit Summary Card
                        Container(
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            color: netProfit >= 0
                                ? Colors.green.withOpacity(0.12)
                                : Colors.red.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: netProfit >= 0
                                  ? Colors.green.withOpacity(0.3)
                                  : Colors.red.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Net Profit Margin',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: netProfit >= 0 ? Colors.green : Colors.red,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${profitMarginPct.toStringAsFixed(1)}% Margin',
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                currencyFormat.format(netProfit),
                                style: theme.textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: netProfit >= 0 ? Colors.green : Colors.red,
                                ),
                              ),
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildMetric('Gross Sales', currencyFormat.format(grossRevenue), Colors.blue),
                                  _buildMetric('Total Expenses', currencyFormat.format(totalExpenses), Colors.orange),
                                  _buildMetric('Invoices', filteredInvoices.length.toString(), Colors.purple),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Financial Bar Chart
                        _buildFinancialBarChart(grossRevenue, totalExpenses, context),
                        const SizedBox(height: 24),

                        // Expense Category Breakdown Card
                        Text(
                          'Expense Breakdown (${filteredExpenses.length} Logged)',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        if (filteredExpenses.isEmpty)
                          const Card(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(child: Text('No expenses recorded for selected timeframe.')),
                            ),
                          )
                        else
                          Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  for (final entry in _groupExpensesByCategory(filteredExpenses).entries)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w600)),
                                          Text(
                                            currencyFormat.format(entry.value),
                                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Text('Error loading expenses: $err'),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Text('Error loading invoices: $err'),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, double> _groupExpensesByCategory(List dynamicExpenses) {
    final map = <String, double>{};
    for (final exp in dynamicExpenses) {
      map[exp.category] = (map[exp.category] ?? 0.0) + exp.amount;
    }
    return map;
  }

  Widget _buildMetric(String title, String value, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
