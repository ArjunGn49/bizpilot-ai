// §6 Repository Rules: Error Handling
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/core/errors/result.dart';
import 'package:flutter_app/features/auth/data/repositories/auth_repository_impl.dart';

class FakeFirebaseAuth extends Fake implements FirebaseAuth {
  String? errorCodeToThrow;
  bool throwGenericError = false;

  void _checkThrow() {
    if (errorCodeToThrow != null) {
      throw FirebaseAuthException(code: errorCodeToThrow!);
    }
    if (throwGenericError) {
      throw Exception('Generic error');
    }
  }

  @override
  Future<UserCredential> signInWithEmailAndPassword({required String email, required String password}) async {
    _checkThrow();
    return FakeUserCredential();
  }

  @override
  Future<UserCredential> createUserWithEmailAndPassword({required String email, required String password}) async {
    _checkThrow();
    return FakeUserCredential();
  }

  @override
  Future<void> signOut() async {
    _checkThrow();
  }

  @override
  Future<void> sendPasswordResetEmail({required String email, ActionCodeSettings? actionCodeSettings}) async {
    _checkThrow();
  }
}

class FakeUserCredential extends Fake implements UserCredential {}

void main() {
  late FakeFirebaseAuth fakeFirebaseAuth;
  late AuthRepositoryImpl repository;

  setUp(() {
    fakeFirebaseAuth = FakeFirebaseAuth();
    repository = AuthRepositoryImpl(fakeFirebaseAuth);
  });

  test('signIn returns success when FirebaseAuth succeeds', () async {
    final result = await repository.signIn(email: 'test@test.com', password: 'password');
    expect(result, isA<Success<void>>());
  });

  test('signIn maps FirebaseAuthException code user-not-found', () async {
    fakeFirebaseAuth.errorCodeToThrow = 'user-not-found';
    final result = await repository.signIn(email: 'test@test.com', password: 'password');

    expect(result, isA<FailureResult<void>>());
    final failureResult = result as FailureResult<void>;
    expect(failureResult.failure.message, 'No user found with this email.');
  });

  test('signIn maps generic exception', () async {
    fakeFirebaseAuth.throwGenericError = true;
    final result = await repository.signIn(email: 'test@test.com', password: 'password');

    expect(result, isA<FailureResult<void>>());
    final failureResult = result as FailureResult<void>;
    expect(failureResult.failure.message, 'Something went wrong. Please try again.');
  });
}
