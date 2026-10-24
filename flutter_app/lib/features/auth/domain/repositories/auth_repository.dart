// §6 Repository Rules: Abstract interface returning Result<void>
import 'package:flutter_app/core/errors/result.dart';

abstract class AuthRepository {
  Future<Result<void>> signIn({required String email, required String password});
  Future<Result<void>> signUp({required String email, required String password});
  Future<Result<void>> signOut();
  Future<Result<void>> sendPasswordResetEmail({required String email});
}
