import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bizpilotai/core/router/route_constants.dart';
import 'package:bizpilotai/core/errors/failure.dart';
import 'package:bizpilotai/features/auth/presentation/providers/auth_controller.dart';
import 'package:bizpilotai/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:bizpilotai/features/auth/presentation/widgets/auth_button.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _agreeTerms = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the Terms of Service to continue.')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      ref.read(authControllerProvider.notifier).signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    ref.listen<AsyncValue<void>>(authControllerProvider, (_, state) {
      if (state.hasError) {
        final error = state.error;
        final message = error is Failure ? error.message : error.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                elevation: 3,
                shadowColor: colorScheme.shadow.withOpacity(0.12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header Icon & Title
                        Center(
                          child: Container(
                            height: 56,
                            width: 56,
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.person_add_rounded,
                              size: 28,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Create Account',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Join BizPilot AI & streamline your business',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Form Inputs
                        AuthTextField(
                          controller: _fullNameController,
                          label: 'Full Name',
                          prefixIcon: const Icon(Icons.person_outline),
                          textInputAction: TextInputAction.next,
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Full Name is required' : null,
                        ),
                        const SizedBox(height: 16),
                        AuthTextField(
                          controller: _emailController,
                          label: 'Email',
                          prefixIcon: const Icon(Icons.email_outlined),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Email is required' : null,
                        ),
                        const SizedBox(height: 16),
                        AuthTextField(
                          controller: _passwordController,
                          label: 'Password',
                          obscureText: true,
                          prefixIcon: const Icon(Icons.lock_outlined),
                          textInputAction: TextInputAction.next,
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Password is required' : null,
                        ),
                        const SizedBox(height: 16),
                        AuthTextField(
                          controller: _confirmPasswordController,
                          label: 'Confirm Password',
                          obscureText: true,
                          prefixIcon: const Icon(Icons.lock_reset_outlined),
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Please confirm password';
                            if (v != _passwordController.text) return 'Passwords do not match';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Terms & Conditions Checkbox
                        Row(
                          children: [
                            Checkbox(
                              value: _agreeTerms,
                              onChanged: (val) {
                                if (val != null) setState(() => _agreeTerms = val);
                              },
                            ),
                            Expanded(
                              child: Text(
                                'I agree to the Terms of Service & Privacy Policy',
                                style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Action Button
                        AuthButton(
                          onPressed: _submit,
                          text: 'Create Account',
                          isLoading: authState.isLoading,
                          icon: Icons.person_add_alt_1_rounded,
                        ),
                        const SizedBox(height: 20),

                        // Section Divider
                        Row(
                          children: [
                            Expanded(child: Divider(color: colorScheme.outlineVariant)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Text(
                                'OR',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.outline,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: colorScheme.outlineVariant)),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Google Sign-In Button
                        OutlinedButton.icon(
                          onPressed: authState.isLoading
                              ? null
                              : () {
                                  ref.read(authControllerProvider.notifier).signInWithGoogle();
                                },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: colorScheme.outlineVariant),
                          ),
                          icon: const Icon(Icons.g_mobiledata_rounded, size: 28, color: Colors.redAccent),
                          label: Text(
                            'Sign up with Google',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Footer Link
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                if (context.canPop()) {
                                  context.pop();
                                } else {
                                  context.go(RoutePaths.login);
                                }
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Sign In',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
