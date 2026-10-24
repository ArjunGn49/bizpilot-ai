import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bizpilotai/core/errors/result.dart';
import 'package:bizpilotai/features/auth/domain/repositories/auth_repository.dart';
import 'package:bizpilotai/features/auth/data/repositories/auth_repository_impl.dart';

final signInWithGoogleUseCaseProvider = Provider<SignInWithGoogleUseCase>((ref) {
  return SignInWithGoogleUseCase(ref.watch(authRepositoryProvider));
});

class SignInWithGoogleUseCase {
  final AuthRepository _repository;

  SignInWithGoogleUseCase(this._repository);

  Future<Result<void>> call() {
    return _repository.signInWithGoogle();
  }
}
