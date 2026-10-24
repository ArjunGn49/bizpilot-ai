import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app/core/router/route_constants.dart';
import 'package:flutter_app/features/auth/presentation/providers/auth_state_provider.dart';

import 'package:flutter_app/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter_app/features/auth/presentation/screens/signup_screen.dart';
import 'package:flutter_app/features/auth/presentation/screens/password_reset_screen.dart';

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
            unauthenticated: () => isPublicRoute ? null : RoutePaths.login,
            authenticated: (userId, email) => (isPublicRoute || isAtRoot) ? RoutePaths.dashboard : null,
          );
        },
      );
    },
    routes: [
      GoRoute(
        path: RoutePaths.root,
        name: RouteNames.root,
        builder: (context, state) => const Placeholder(),
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
        builder: (context, state) => const Scaffold(body: Center(child: Text('Dashboard Placeholder'))),
      ),
      // Future feature routes scaffolded as placeholders
      GoRoute(
        path: RoutePaths.products,
        name: RouteNames.products,
        builder: (context, state) => const Placeholder(),
      ),
      GoRoute(
        path: RoutePaths.productsAdd,
        name: RouteNames.productsAdd,
        builder: (context, state) => const Placeholder(),
      ),
      GoRoute(
        path: RoutePaths.productDetail,
        name: RouteNames.productDetail,
        builder: (context, state) => const Placeholder(),
      ),
      GoRoute(
        path: RoutePaths.invoices,
        name: RouteNames.invoices,
        builder: (context, state) => const Placeholder(),
      ),
      GoRoute(
        path: RoutePaths.invoicesCreate,
        name: RouteNames.invoicesCreate,
        builder: (context, state) => const Placeholder(),
      ),
      GoRoute(
        path: RoutePaths.customers,
        name: RouteNames.customers,
        builder: (context, state) => const Placeholder(),
      ),
      GoRoute(
        path: RoutePaths.expenses,
        name: RouteNames.expenses,
        builder: (context, state) => const Placeholder(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(child: Text(state.error.toString())),
    ),
  );
});
