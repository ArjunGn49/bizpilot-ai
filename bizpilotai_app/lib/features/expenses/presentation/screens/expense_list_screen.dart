import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:bizpilotai/core/router/route_constants.dart';
import 'package:bizpilotai/features/expenses/domain/entities/expense.dart';
import 'package:bizpilotai/features/expenses/presentation/providers/expenses_provider.dart';
import 'package:bizpilotai/features/expenses/presentation/providers/expense_controller.dart';
import 'package:bizpilotai/features/expenses/presentation/widgets/expense_card.dart';

class ExpenseListScreen extends ConsumerStatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  ConsumerState<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends ConsumerState<ExpenseListScreen> {
  String _selectedFilterCategory = 'All';
  String _searchQuery = '';

  static const List<String> _filterCategories = [
    'All',
    'Rent',
    'Utilities',
    'Inventory Purchases',
    'Transport',
    'Salaries',
    'Other',
  ];

  Future<void> _confirmDelete(Expense expense) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Expense'),
        content: Text('Are you sure you want to delete ${expense.category} expense of ₹${expense.amount.toStringAsFixed(2)}?'),
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
      final success = await ref.read(expenseControllerProvider.notifier).deleteExpense(expense.id);
      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense deleted'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(expensesProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currencyFormat = NumberFormat.currency(symbol: '₹');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses Tracker'),
      ),
      body: expensesAsync.when(
        data: (expenses) {
          final filteredExpenses = expenses.where((exp) {
            // Category Filter
            if (_selectedFilterCategory != 'All' && exp.category.toLowerCase() != _selectedFilterCategory.toLowerCase()) {
              return false;
            }
            // Search Filter
            if (_searchQuery.isNotEmpty) {
              final q = _searchQuery.toLowerCase();
              return exp.category.toLowerCase().contains(q) || (exp.note != null && exp.note!.toLowerCase().contains(q));
            }
            return true;
          }).toList();

          final totalExpense = filteredExpenses.fold<double>(
            0.0,
            (sum, item) => sum + item.amount,
          );

          return Column(
            children: [
              // Search Input Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search expense note or category...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => _searchQuery = ''))
                        : null,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),

              // Expense Summary Card
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.error.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedFilterCategory == 'All'
                          ? 'Total Business Expenses'
                          : 'Total $_selectedFilterCategory Expense',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currencyFormat.format(totalExpense),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),

              // Category Filter Bar
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filterCategories.length,
                  itemBuilder: (context, index) {
                    final cat = _filterCategories[index];
                    final isSelected = cat == _selectedFilterCategory;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(cat),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedFilterCategory = cat;
                            });
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),

              // Expenses List
              Expanded(
                child: filteredExpenses.isEmpty
                    ? Center(
                        child: Text(
                          _selectedFilterCategory == 'All'
                              ? 'No expenses logged yet. Add one!'
                              : 'No expenses found under $_selectedFilterCategory.',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: filteredExpenses.length,
                        itemBuilder: (context, index) {
                          final expense = filteredExpenses[index];
                          return ExpenseCard(
                            expense: expense,
                            onDelete: () => _confirmDelete(expense),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading expenses: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RoutePaths.expensesAdd),
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }
}
