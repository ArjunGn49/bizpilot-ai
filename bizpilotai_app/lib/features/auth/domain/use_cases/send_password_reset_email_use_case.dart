// §7 Use Case Rules, §3 Naming
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bizpilotai/core/errors/result.dart';
import 'package:bizpilotai/features/auth/domain/repositories/auth_repository.dart';
import 'package:bizpilotai/features/auth/data/repositories/auth_repository_impl.dart';

final sendPasswordResetEmailUseCaseProvider = Provider<SendPasswordResetEmailUseCase>((ref) {
  return SendPasswordResetEmailUseCase(ref.watch(authRepositoryProvider));
});

class SendPasswordResetEmailUseCase {
  final AuthRepository _repository;

  SendPasswordResetEmailUseCase(this._repository);

  Future<Result<void>> call({required String email}) {
    return _repository.sendPasswordResetEmail(email: email);
  }
}
