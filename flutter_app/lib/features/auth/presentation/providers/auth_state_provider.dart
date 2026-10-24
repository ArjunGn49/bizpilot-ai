import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/features/auth/data/datasources/firebase_auth_datasource.dart';

part 'auth_state_provider.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.unknown() = _Unknown;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.authenticated({
    required String userId,
    String? email,
  }) = _Authenticated;
}

class AuthStateNotifier extends Notifier<AsyncValue<AuthState>> {
  @override
  AsyncValue<AuthState> build() {
    final authStream = ref.watch(firebaseAuthProvider).authStateChanges();

    final subscription = authStream.listen(
      (user) {
        if (user == null) {
          state = const AsyncValue.data(AuthState.unauthenticated());
        } else {
          state = AsyncValue.data(AuthState.authenticated(
            userId: user.uid,
            email: user.email,
          ));
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        state = AsyncValue.error(error, stackTrace);
      },
    );

    ref.onDispose(subscription.cancel);

    return const AsyncValue.data(AuthState.unknown());
  }
}

final authStateProvider = NotifierProvider<AuthStateNotifier, AsyncValue<AuthState>>(
  AuthStateNotifier.new,
);
