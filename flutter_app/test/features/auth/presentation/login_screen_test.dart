// CLAUDE.md §14, §8 Riverpod Rules
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/core/errors/failure.dart';
import 'package:flutter_app/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter_app/features/auth/presentation/providers/auth_controller.dart';
import 'package:flutter_app/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:flutter_app/features/auth/presentation/widgets/auth_button.dart';

class MockAuthController extends AuthController {
  bool shouldFail = false;

  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  @override
  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncValue.loading();
    if (shouldFail) {
      state = AsyncValue.error(const AuthFailure('Invalid credentials'), StackTrace.current);
    } else {
      state = const AsyncValue.data(null);
    }
  }
}

void main() {
  testWidgets('LoginScreen shows error on sign in failure', (tester) async {
    final mockController = MockAuthController()..shouldFail = true;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(() => mockController),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    expect(find.byType(AuthTextField), findsNWidgets(2));

    await tester.enterText(find.byType(AuthTextField).first, 'test@example.com');
    await tester.enterText(find.byType(AuthTextField).last, 'password');

    await tester.tap(find.widgetWithText(AuthButton, 'Sign In'));
    await tester.pump(); // trigger loading
    await tester.pump(); // trigger error

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Invalid credentials'), findsOneWidget);
  });
}
