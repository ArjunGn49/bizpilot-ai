import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bizpilotai/core/router/route_constants.dart';
import 'package:bizpilotai/features/settings/presentation/providers/settings_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  final _formKey1 = GlobalKey<FormState>();
  final _storeNameController = TextEditingController(text: 'BizPilot Store');
  final _phoneController = TextEditingController(text: '+91 98765 43210');
  final _addressController = TextEditingController(text: 'Main Market Road');

  String _selectedCurrency = '₹';
  String _taxLabel = 'GST';

  static const List<String> _currencies = ['₹', '\$', '€', '£', 'A\$', 'R\$'];

  @override
  void dispose() {
    _pageController.dispose();
    _storeNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (!_formKey1.currentState!.validate()) return;
    }

    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    await ref.read(settingsControllerProvider).saveBusinessDetails(
          name: _storeNameController.text.trim(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          taxLabel: _taxLabel,
          currencySymbol: _selectedCurrency,
        );

    if (mounted) {
      context.go(RoutePaths.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Store Onboarding Setup'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: List.generate(3, (index) {
                  final isActive = index <= _currentStep;
                  return Expanded(
                    child: Container(
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: isActive ? colorScheme.primary : colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Page View Wizard
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (idx) {
                  setState(() => _currentStep = idx);
                },
                children: [
                  // Step 1: Store Details
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Step 1 of 3: Store Profile', style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text('Enter your business profile information', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _storeNameController,
                            decoration: const InputDecoration(labelText: 'Store / Business Name', prefixIcon: Icon(Icons.storefront_outlined), border: OutlineInputBorder()),
                            validator: (v) => v == null || v.trim().isEmpty ? 'Store name is required' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _phoneController,
                            decoration: const InputDecoration(labelText: 'Business Phone Number', prefixIcon: Icon(Icons.phone_outlined), border: OutlineInputBorder()),
                            validator: (v) => v == null || v.trim().isEmpty ? 'Phone number is required' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _addressController,
                            decoration: const InputDecoration(labelText: 'Business Address', prefixIcon: Icon(Icons.location_on_outlined), border: OutlineInputBorder()),
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Step 2: Currency & Tax Setup
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Step 2 of 3: Currency & Tax', style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text('Configure billing & currency settings', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 24),
                        DropdownButtonFormField<String>(
                          value: _selectedCurrency,
                          decoration: const InputDecoration(labelText: 'Store Currency Symbol', prefixIcon: Icon(Icons.currency_exchange), border: OutlineInputBorder()),
                          items: _currencies.map((c) => DropdownMenuItem(value: c, child: Text('$c Currency'))).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedCurrency = val);
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: _taxLabel,
                          decoration: const InputDecoration(labelText: 'Tax Name / Label (e.g. GST, VAT)', prefixIcon: Icon(Icons.percent), border: OutlineInputBorder()),
                          onChanged: (val) => _taxLabel = val,
                        ),
                      ],
                    ),
                  ),

                  // Step 3: Confirmation
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(color: colorScheme.primaryContainer, shape: BoxShape.circle),
                          child: Icon(Icons.check_circle_rounded, size: 64, color: colorScheme.primary),
                        ),
                        const SizedBox(height: 24),
                        Text('Ready to Pilot Your Business!', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(
                          'Your store configuration is saved. Start issuing tax invoices, tracking inventory, and organizing customer accounts.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Navigation Actions
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  if (_currentStep > 0) ...[
                    OutlinedButton(
                      onPressed: () {
                        _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                      },
                      child: const Text('Back'),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _nextStep,
                      icon: Icon(_currentStep == 2 ? Icons.rocket_launch_rounded : Icons.arrow_forward),
                      label: Text(_currentStep == 2 ? 'Go to Dashboard' : 'Next Step'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
