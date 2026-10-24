import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bizpilotai/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:bizpilotai/features/auth/data/data_sources/firebase_auth_data_source.dart';

// Fakes to decouple testing from native Firebase dependency
class FakeUser extends Fake implements User {
  @override
  final String uid;
  @override
  final String? email;

  FakeUser(this.uid, this.email);
}

class FakeFirebaseAuth extends Fake implements FirebaseAuth {
  final StreamController<User?> _controller = StreamController<User?>.broadcast();

  @override
  Stream<User?> authStateChanges() => _controller.stream;

  void emitUser(User? user) {
    _controller.add(user);
  }

  void close() {
    _controller.close();
  }
}

void main() {
  late FakeFirebaseAuth fakeFirebaseAuth;
  late ProviderContainer container;

  setUp(() {
    fakeFirebaseAuth = FakeFirebaseAuth();
    container = ProviderContainer(
      overrides: [
        firebaseAuthProvider.overrideWithValue(fakeFirebaseAuth),
      ],
    );
  });

  tearDown(() {
    fakeFirebaseAuth.close();
    container.dispose();
  });

  test('initial state is unknown', () {
    final state = container.read(authStateProvider);
    expect(state.value, isA<AuthState>());
    state.value!.when(
      unknown: () => expect(true, isTrue),
      unauthenticated: () => fail('Should be unknown'),
      authenticated: (_, __) => fail('Should be unknown'),
    );
  });

  test('emits unauthenticated when stream yields null user', () async {
    // Start listening to provider
    container.listen(authStateProvider, (_, __) {});

    // Simulate user signed out
    fakeFirebaseAuth.emitUser(null);

    // Wait for stream to yield and state to update
    await Future.delayed(Duration.zero);

    final state = container.read(authStateProvider);
    state.value!.when(
      unknown: () => fail('Should be unauthenticated'),
      unauthenticated: () => expect(true, isTrue),
      authenticated: (_, __) => fail('Should be unauthenticated'),
    );
  });

  test('emits authenticated when stream yields a valid user', () async {
    container.listen(authStateProvider, (_, __) {});

    final mockUser = FakeUser('test-uid', 'test@example.com');
    fakeFirebaseAuth.emitUser(mockUser);

    await Future.delayed(Duration.zero);

    final state = container.read(authStateProvider);
    state.value!.when(
      unknown: () => fail('Should be authenticated'),
      unauthenticated: () => fail('Should be authenticated'),
      authenticated: (userId, email) {
        expect(userId, 'test-uid');
        expect(email, 'test@example.com');
      },
    );
  });
}
