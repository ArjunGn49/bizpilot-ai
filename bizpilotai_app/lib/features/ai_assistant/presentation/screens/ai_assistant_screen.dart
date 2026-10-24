import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:bizpilotai/features/customers/presentation/providers/customers_provider.dart';
import 'package:bizpilotai/features/expenses/presentation/providers/expenses_provider.dart';
import 'package:bizpilotai/features/invoices/presentation/providers/invoices_provider.dart';
import 'package:bizpilotai/features/products/presentation/providers/products_provider.dart';

class _ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  _ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class AiAssistantScreen extends ConsumerStatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  ConsumerState<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends ConsumerState<AiAssistantScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<_ChatMessage> _messages = [
    _ChatMessage(
      text: 'Hello! I am your BizPilot AI Business Assistant. How can I help you analyze your store inventory, revenue, or customer dues today?',
      isUser: false,
      timestamp: DateTime.now(),
    ),
  ];

  bool _isThinking = false;

  static const List<String> _suggestedPrompts = [
    '🔥 Low Stock Warning Alert',
    '💰 Total Pending Dues',
    '📊 Sales Revenue Overview',
    '📦 Product Catalog Count',
  ];

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendQuery(String text) {
    if (text.trim().isEmpty || _isThinking) return;

    final query = text.trim();
    _inputController.clear();

    setState(() {
      _messages.add(_ChatMessage(text: query, isUser: true, timestamp: DateTime.now()));
      _isThinking = true;
    });
    _scrollToBottom();

    // Process query against real store DB state
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      final response = _generateAiResponse(query);
      setState(() {
        _messages.add(_ChatMessage(text: response, isUser: false, timestamp: DateTime.now()));
        _isThinking = false;
      });
      _scrollToBottom();
    });
  }

  String _generateAiResponse(String query) {
    final products = ref.read(productsProvider).value ?? [];
    final invoices = ref.read(invoicesProvider).value ?? [];
    final expenses = ref.read(expensesProvider).value ?? [];
    final customers = ref.read(customersProvider).value ?? [];

    final currencyFormat = NumberFormat.currency(symbol: '₹');
    final q = query.toLowerCase();

    if (q.contains('stock') || q.contains('inventory') || q.contains('low')) {
      final lowStock = products.where((p) => p.stockQuantity <= p.lowStockThreshold).toList();
      if (lowStock.isEmpty) {
        return 'Good news! All ${products.length} products in your store inventory are sufficiently stocked above alert thresholds.';
      }
      final itemsList = lowStock.map((p) => '• ${p.name}: ${p.stockQuantity} remaining (Threshold: ${p.lowStockThreshold})').join('\n');
      return '⚠️ Stock Alert! You have ${lowStock.length} product(s) low in stock:\n\n$itemsList\n\nI recommend restocking these items soon.';
    }

    if (q.contains('due') || q.contains('pending') || q.contains('balance') || q.contains('unpaid')) {
      final unpaidInvoices = invoices.where((i) => !i.isVoid && i.balanceAmount > 0).toList();
      final totalBalance = unpaidInvoices.fold<double>(0.0, (sum, i) => sum + i.balanceAmount);

      final customerDues = customers.where((c) => c.totalOutstanding > 0).toList();
      final customerList = customerDues.map((c) => '• ${c.name}: ${currencyFormat.format(c.totalOutstanding)}').join('\n');

      return '💰 Pending Customer Balance Summary:\nTotal Pending Due: ${currencyFormat.format(totalBalance)} across ${unpaidInvoices.length} unpaid invoice(s).\n\nCustomers with outstanding dues:\n${customerList.isNotEmpty ? customerList : 'No specific customer outstanding balance logged.'}';
    }

    if (q.contains('revenue') || q.contains('sales') || q.contains('profit') || q.contains('income')) {
      final validInvoices = invoices.where((i) => !i.isVoid).toList();
      final grossRevenue = validInvoices.fold<double>(0.0, (sum, i) => sum + i.total);
      final totalExpenses = expenses.fold<double>(0.0, (sum, e) => sum + e.amount);
      final netProfit = grossRevenue - totalExpenses;

      return '📊 Store Financial Analysis:\n\n• Gross Revenue: ${currencyFormat.format(grossRevenue)} (${validInvoices.length} orders)\n• Total Expenses: ${currencyFormat.format(totalExpenses)} (${expenses.length} logged)\n• Net Profit: ${currencyFormat.format(netProfit)}\n\nYour net profit margin is ${grossRevenue > 0 ? ((netProfit / grossRevenue) * 100).toStringAsFixed(1) : '0.0'}%.';
    }

    if (q.contains('catalog') || q.contains('product') || q.contains('item')) {
      return '📦 Product Catalog Overview:\nYou currently have ${products.length} registered products across your store catalog.\n\nTop catalog entries:\n' +
          products.take(5).map((p) => '• ${p.name} (SKU: ${p.sku}) - ${currencyFormat.format(p.sellingPrice)}').join('\n');
    }

    // Default intelligent response fallback
    return '🤖 BizPilot AI Analysis:\nI have scanned your local store database. Here is your store snapshot:\n\n• Total Products: ${products.length}\n• Total Invoices Issued: ${invoices.length}\n• Total Registered Customers: ${customers.length}\n\nFeel free to ask about "low stock alerts", "pending customer dues", or "sales revenue overview"!';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final timeFormat = DateFormat('HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.auto_awesome, size: 18, color: colorScheme.primary),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('BizPilot AI Assistant', style: TextStyle(fontSize: 16)),
                Text(
                  'Powered by Gemini Store Intelligence',
                  style: TextStyle(fontSize: 11, color: colorScheme.onPrimary.withOpacity(0.8)),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.cleaning_services_outlined),
            tooltip: 'Clear Chat',
            onPressed: () {
              setState(() {
                _messages.clear();
                _messages.add(
                  _ChatMessage(
                    text: 'Chat history cleared. How can I assist you with your business today?',
                    isUser: false,
                    timestamp: DateTime.now(),
                  ),
                );
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Prompt Suggestions Bar
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              itemCount: _suggestedPrompts.length,
              itemBuilder: (context, index) {
                final prompt = _suggestedPrompts[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ActionChip(
                    label: Text(prompt, style: const TextStyle(fontSize: 12)),
                    onPressed: () => _sendQuery(prompt),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),

          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    mainAxisAlignment: msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!msg.isUser) ...[
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: colorScheme.primaryContainer,
                          child: Icon(Icons.auto_awesome, size: 16, color: colorScheme.primary),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: msg.isUser
                                ? colorScheme.primary
                                : colorScheme.surfaceContainerHighest.withOpacity(0.6),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: Radius.circular(msg.isUser ? 16 : 4),
                              bottomRight: Radius.circular(msg.isUser ? 4 : 16),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg.text,
                                style: TextStyle(
                                  color: msg.isUser ? Colors.white : colorScheme.onSurface,
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                timeFormat.format(msg.timestamp),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: msg.isUser
                                      ? Colors.white70
                                      : colorScheme.onSurfaceVariant.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (msg.isUser) ...[
                        const SizedBox(width: 8),
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: colorScheme.secondaryContainer,
                          child: Icon(Icons.person, size: 16, color: colorScheme.secondary),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),

          if (_isThinking)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.primary),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'BizPilot AI is analyzing your store data...',
                    style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),

          // Input Bar
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.mic_none_rounded),
                    tooltip: 'Voice Command Input',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Listening for voice prompt...')),
                      );
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _sendQuery,
                      decoration: InputDecoration(
                        hintText: 'Ask AI about sales, inventory, dues...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: () => _sendQuery(_inputController.text),
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
