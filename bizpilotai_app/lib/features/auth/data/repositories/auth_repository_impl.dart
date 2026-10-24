// §6 Repository Rules: Handle exceptions internally and map to Failures
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bizpilotai/core/errors/failure.dart';
import 'package:bizpilotai/core/errors/result.dart';
import 'package:bizpilotai/features/auth/domain/repositories/auth_repository.dart';
import 'package:bizpilotai/features/auth/data/data_sources/firebase_auth_data_source.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(firebaseAuthProvider));
});

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;

  AuthRepositoryImpl(this._firebaseAuth);

  @override
  Future<Result<void>> signIn({required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      return const Result.success(null);
    } on FirebaseAuthException catch (e) {
      return Result.failure(AuthFailure(_mapFirebaseAuthError(e.code)));
    } catch (_) {
      return const Result.failure(AuthFailure('Something went wrong. Please try again.'));
    }
  }

  @override
  Future<Result<void>> signUp({required String email, required String password}) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      return const Result.success(null);
    } on FirebaseAuthException catch (e) {
      return Result.failure(AuthFailure(_mapFirebaseAuthError(e.code)));
    } catch (_) {
      return const Result.failure(AuthFailure('Something went wrong. Please try again.'));
    }
  }

  @override
  Future<Result<void>> signInWithGoogle() async {
    try {
      final googleProvider = GoogleAuthProvider();
      await _firebaseAuth.signInWithProvider(googleProvider);
      return const Result.success(null);
    } on FirebaseAuthException catch (e) {
      return Result.failure(AuthFailure(_mapFirebaseAuthError(e.code)));
    } catch (_) {
      return const Result.failure(AuthFailure('Google Sign-In failed or was cancelled.'));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _firebaseAuth.signOut();
      return const Result.success(null);
    } on FirebaseAuthException catch (e) {
      return Result.failure(AuthFailure(_mapFirebaseAuthError(e.code)));
    } catch (_) {
      return const Result.failure(AuthFailure('Something went wrong. Please try again.'));
    }
  }

  @override
  Future<Result<void>> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return const Result.success(null);
    } on FirebaseAuthException catch (e) {
      return Result.failure(AuthFailure(_mapFirebaseAuthError(e.code)));
    } catch (_) {
      return const Result.failure(AuthFailure('Something went wrong. Please try again.'));
    }
  }

  String _mapFirebaseAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'The email address is not valid.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
