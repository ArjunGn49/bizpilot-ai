// §8 Riverpod Rules: Notifier handles its own errors
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/features/auth/domain/usecases/sign_in_use_case.dart';
import 'package:flutter_app/features/auth/domain/usecases/sign_up_use_case.dart';
import 'package:flutter_app/features/auth/domain/usecases/sign_out_use_case.dart';
import 'package:flutter_app/features/auth/domain/usecases/send_password_reset_email_use_case.dart';

final authControllerProvider = NotifierProvider<AuthController, AsyncValue<void>>(
  AuthController.new,
);

class AuthController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncValue.loading();
    final result = await ref.read(signInUseCaseProvider).call(email: email, password: password);
    result.when(
      success: (_) {
        state = const AsyncValue.data(null);
      },
      failure: (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
      },
    );
  }

  Future<void> signUp({required String email, required String password}) async {
    state = const AsyncValue.loading();
    final result = await ref.read(signUpUseCaseProvider).call(email: email, password: password);
    result.when(
      success: (_) {
        state = const AsyncValue.data(null);
      },
      failure: (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
      },
    );
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    final result = await ref.read(signOutUseCaseProvider).call();
    result.when(
      success: (_) {
        state = const AsyncValue.data(null);
      },
      failure: (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
      },
    );
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    state = const AsyncValue.loading();
    final result = await ref.read(sendPasswordResetEmailUseCaseProvider).call(email: email);
    result.when(
      success: (_) {
        state = const AsyncValue.data(null);
      },
      failure: (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
      },
    );
  }
}
