import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bizpilotai/core/router/route_constants.dart';
import 'package:bizpilotai/features/auth/presentation/providers/auth_state_provider.dart';

import 'package:bizpilotai/features/splash/presentation/screens/splash_screen.dart';
import 'package:bizpilotai/features/ai_assistant/presentation/screens/ai_assistant_screen.dart';
import 'package:bizpilotai/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:bizpilotai/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:bizpilotai/features/post/presentation/screens/create_post_screen.dart';
import 'package:bizpilotai/features/auth/presentation/screens/login_screen.dart';
import 'package:bizpilotai/features/auth/presentation/screens/signup_screen.dart';
import 'package:bizpilotai/features/auth/presentation/screens/password_reset_screen.dart';
import 'package:bizpilotai/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:bizpilotai/features/products/presentation/screens/product_list_screen.dart';
import 'package:bizpilotai/features/products/presentation/screens/add_edit_product_screen.dart';
import 'package:bizpilotai/features/products/presentation/screens/product_detail_screen.dart';
import 'package:bizpilotai/features/products/domain/entities/product.dart';
import 'package:bizpilotai/features/invoices/presentation/screens/invoice_list_screen.dart';
import 'package:bizpilotai/features/invoices/presentation/screens/create_invoice_screen.dart';
import 'package:bizpilotai/features/invoices/presentation/screens/invoice_detail_screen.dart';
import 'package:bizpilotai/features/customers/presentation/screens/customer_list_screen.dart';
import 'package:bizpilotai/features/customers/presentation/screens/add_edit_customer_screen.dart';
import 'package:bizpilotai/features/customers/presentation/screens/customer_detail_screen.dart';
import 'package:bizpilotai/features/customers/domain/entities/customer.dart';
import 'package:bizpilotai/features/expenses/presentation/screens/expense_list_screen.dart';
import 'package:bizpilotai/features/expenses/presentation/screens/add_expense_screen.dart';
import 'package:bizpilotai/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:bizpilotai/features/settings/presentation/screens/settings_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  // Watching the auth state causes the GoRouter to rebuild its redirect logic 
  // when the user's authentication status changes.
  final authStateAsync = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RoutePaths.root,
    redirect: (context, state) {
      final path = state.uri.path;
      final isGoingToLogin = path == RoutePaths.login;
      final isGoingToSignup = path == RoutePaths.signup;
      final isGoingToPasswordReset = path == RoutePaths.passwordReset;
      final isAtRoot = path == RoutePaths.root;

      final isPublicRoute = isGoingToLogin || isGoingToSignup || isGoingToPasswordReset;

      return authStateAsync.when(
        loading: () => null,
        error: (_, __) => null,
        data: (authState) {
          return authState.when(
            unknown: () => null,
            unauthenticated: () => (isPublicRoute || isAtRoot) ? null : RoutePaths.login,
            authenticated: (userId, email) => isPublicRoute ? RoutePaths.dashboard : null,
          );
        },
      );
    },
    routes: [
      GoRoute(
        path: RoutePaths.root,
        name: RouteNames.root,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.signup,
        name: RouteNames.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: RoutePaths.passwordReset,
        name: RouteNames.passwordReset,
        builder: (context, state) => const PasswordResetScreen(),
      ),
      GoRoute(
        path: RoutePaths.dashboard,
        name: RouteNames.dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: RoutePaths.aiAssistant,
        name: RouteNames.aiAssistant,
        builder: (context, state) => const AiAssistantScreen(),
      ),
      GoRoute(
        path: RoutePaths.onboarding,
        name: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RoutePaths.notifications,
        name: RouteNames.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: RoutePaths.post,
        name: RouteNames.post,
        builder: (context, state) => const CreatePostScreen(),
      ),
      GoRoute(
        path: RoutePaths.products,
        name: RouteNames.products,
        builder: (context, state) => const ProductListScreen(),
      ),
      GoRoute(
        path: RoutePaths.productsAdd,
        name: RouteNames.productsAdd,
        builder: (context, state) {
          final product = state.extra as Product?;
          return AddEditProductScreen(product: product);
        },
      ),
      GoRoute(
        path: RoutePaths.productDetail,
        name: RouteNames.productDetail,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ProductDetailScreen(productId: id);
        },
      ),
      GoRoute(
        path: RoutePaths.invoices,
        name: RouteNames.invoices,
        builder: (context, state) => const InvoiceListScreen(),
      ),
      GoRoute(
        path: RoutePaths.invoicesCreate,
        name: RouteNames.invoicesCreate,
        builder: (context, state) => const CreateInvoiceScreen(),
      ),
      GoRoute(
        path: RoutePaths.invoiceDetail,
        name: RouteNames.invoiceDetail,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return InvoiceDetailScreen(invoiceId: id);
        },
      ),
      GoRoute(
        path: RoutePaths.customers,
        name: RouteNames.customers,
        builder: (context, state) => const CustomerListScreen(),
      ),
      GoRoute(
        path: RoutePaths.customersAdd,
        name: RouteNames.customersAdd,
        builder: (context, state) {
          final customer = state.extra as Customer?;
          return AddEditCustomerScreen(customer: customer);
        },
      ),
      GoRoute(
        path: RoutePaths.customerDetail,
        name: RouteNames.customerDetail,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return CustomerDetailScreen(customerId: id);
        },
      ),
      GoRoute(
        path: RoutePaths.expenses,
        name: RouteNames.expenses,
        builder: (context, state) => const ExpenseListScreen(),
      ),
      GoRoute(
        path: RoutePaths.expensesAdd,
        name: RouteNames.expensesAdd,
        builder: (context, state) => const AddExpenseScreen(),
      ),
      GoRoute(
        path: RoutePaths.analytics,
        name: RouteNames.analytics,
        builder: (context, state) => const AnalyticsScreen(),
      ),
      GoRoute(
        path: RoutePaths.settings,
        name: RouteNames.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(child: Text(state.error.toString())),
    ),
  );
});
