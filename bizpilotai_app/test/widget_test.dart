import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bizpilotai/app/app.dart';
import 'package:bizpilotai/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bizpilotai/features/auth/presentation/screens/login_screen.dart';

// Mock notifier to simulate an unknown user session
class MockUnknownNotifier extends AuthStateNotifier {
  @override
  AsyncValue<AuthState> build() => const AsyncValue.data(AuthState.unknown());
}

// Mock notifier to simulate an unauthenticated user session
class MockUnauthenticatedNotifier extends AuthStateNotifier {
  @override
  AsyncValue<AuthState> build() => const AsyncValue.data(AuthState.unauthenticated());
}

void main() {
  testWidgets('App loads placeholder screen on unknown auth state', (WidgetTester tester) async {
    // Build the app overriding the AuthStateNotifier to bypass Firebase
    await tester.pumpWidget(
      BizPilotApp(
        overrides: [
          authStateProvider.overrideWith(() => MockUnknownNotifier()),
        ],
      ),
    );

    // Verify that the router resolves the '/' route and does not force a redirect
    expect(find.byType(Placeholder), findsOneWidget);
  });

  testWidgets('App redirects to login when unauthenticated', (WidgetTester tester) async {
    // Build the app while overriding the AuthStateNotifier to bypass Firebase
    await tester.pumpWidget(
      BizPilotApp(
        overrides: [
          authStateProvider.overrideWith(() => MockUnauthenticatedNotifier()),
        ],
      ),
    );
    
    // Wait for the GoRouter navigation and redirect to settle
    await tester.pumpAndSettle();

    // Verify the redirect intercepted the path and navigated to the login screen
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
