import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bizpilotai/core/theme/theme_provider.dart';
import 'package:bizpilotai/core/sync/sync_service.dart';
import 'package:bizpilotai/features/settings/presentation/providers/settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _taxLabelController = TextEditingController();
  final _receiptFooterController = TextEditingController(text: 'Thank you for shopping with us!');

  String _selectedCurrency = '₹';
  bool _isSaving = false;
  bool _isSyncing = false;
  bool _isInitialized = false;

  static const List<String> _currencies = ['₹', '\$', '€', '£', 'A\$', 'R\$'];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _taxLabelController.dispose();
    _receiptFooterController.dispose();
    super.dispose();
  }

  void _populateSettings(Map<String, String> settings) {
    if (_isInitialized) return;
    _nameController.text = settings['business_name'] ?? 'BizPilot AI Store';
    _phoneController.text = settings['business_phone'] ?? '+91 98765 43210';
    _addressController.text = settings['business_address'] ?? '123 Main Market, New Delhi';
    _taxLabelController.text = settings['tax_label'] ?? 'GST';
    if (settings['receipt_footer'] != null) {
      _receiptFooterController.text = settings['receipt_footer']!;
    }
    if (_currencies.contains(settings['currency_symbol'])) {
      _selectedCurrency = settings['currency_symbol']!;
    }
    _isInitialized = true;
  }

  Future<void> _saveBusinessProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    await ref.read(settingsControllerProvider).saveBusinessDetails(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          taxLabel: _taxLabelController.text.trim(),
          currencySymbol: _selectedCurrency,
        );

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Store settings saved successfully!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _triggerSync() async {
    setState(() => _isSyncing = true);
    await ref.read(syncServiceProvider).syncPendingData();
    if (mounted) {
      setState(() => _isSyncing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cloud sync complete!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);
    final currentThemeMode = ref.watch(themeModeProvider);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('App & Store Settings'),
      ),
      body: settingsAsync.when(
        data: (settingsMap) {
          _populateSettings(settingsMap);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Theme & Appearance Section
                Text(
                  'Appearance & Theme Mode',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Choose App Theme',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 12),
                        SegmentedButton<ThemeMode>(
                          segments: const [
                            ButtonSegment(
                              value: ThemeMode.system,
                              label: Text('System'),
                              icon: Icon(Icons.brightness_auto),
                            ),
                            ButtonSegment(
                              value: ThemeMode.light,
                              label: Text('Light'),
                              icon: Icon(Icons.light_mode),
                            ),
                            ButtonSegment(
                              value: ThemeMode.dark,
                              label: Text('Dark'),
                              icon: Icon(Icons.dark_mode),
                            ),
                          ],
                          selected: {currentThemeMode},
                          onSelectionChanged: (newSelection) {
                            ref
                                .read(themeModeProvider.notifier)
                                .setThemeMode(newSelection.first);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Store Business Profile
                Text(
                  'Business & Store Details',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Business Name',
                              prefixIcon: Icon(Icons.storefront_outlined),
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) =>
                                v == null || v.trim().isEmpty ? 'Business name is required' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _phoneController,
                            decoration: const InputDecoration(
                              labelText: 'Business Phone Number',
                              prefixIcon: Icon(Icons.phone_outlined),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _addressController,
                            decoration: const InputDecoration(
                              labelText: 'Business Address',
                              prefixIcon: Icon(Icons.location_on_outlined),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _selectedCurrency,
                                  decoration: const InputDecoration(
                                    labelText: 'Currency Symbol',
                                    prefixIcon: Icon(Icons.currency_exchange),
                                    border: OutlineInputBorder(),
                                  ),
                                  items: _currencies.map((curr) {
                                    return DropdownMenuItem(
                                      value: curr,
                                      child: Text(curr),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        _selectedCurrency = val;
                                      });
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _taxLabelController,
                                  decoration: const InputDecoration(
                                    labelText: 'Tax Label (GST/VAT)',
                                    prefixIcon: Icon(Icons.receipt_outlined),
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _receiptFooterController,
                            decoration: const InputDecoration(
                              labelText: 'Receipt Footer Message',
                              prefixIcon: Icon(Icons.notes_outlined),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Store logo picker opened.')),
                              );
                            },
                            icon: const Icon(Icons.image_outlined),
                            label: const Text('Upload Store Logo'),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isSaving ? null : _saveBusinessProfile,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: _isSaving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.save_outlined),
                              label: const Text('Save Business Profile', style: TextStyle(fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Cloud Sync & System
                Text(
                  'Cloud Sync & System Status',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: colorScheme.primaryContainer,
                            child: Icon(Icons.cloud_sync_outlined, color: colorScheme.primary),
                          ),
                          title: const Text('Firebase Cloud Sync', style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: const Text('Sync offline SQLite data with Firebase Cloud Firestore'),
                          trailing: ElevatedButton.icon(
                            onPressed: _isSyncing ? null : _triggerSync,
                            icon: _isSyncing
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.sync_rounded, size: 18),
                            label: const Text('Sync Now'),
                          ),
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('App Version', style: TextStyle(color: Colors.grey)),
                            Text('v1.0.0+1', style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.primary)),
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
        error: (err, stack) => Center(child: Text('Error loading settings: $err')),
      ),
    );
  }
}
