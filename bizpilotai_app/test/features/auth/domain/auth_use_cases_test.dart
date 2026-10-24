// §7 Use Case Rules: Testing domain layers
import 'package:flutter_test/flutter_test.dart';
import 'package:bizpilotai/core/errors/result.dart';
import 'package:bizpilotai/core/errors/failure.dart';
import 'package:bizpilotai/features/auth/domain/repositories/auth_repository.dart';
import 'package:bizpilotai/features/auth/domain/use_cases/sign_in_use_case.dart';
import 'package:bizpilotai/features/auth/domain/use_cases/sign_up_use_case.dart';
import 'package:bizpilotai/features/auth/domain/use_cases/sign_in_with_google_use_case.dart';
import 'package:bizpilotai/features/auth/domain/use_cases/sign_out_use_case.dart';
import 'package:bizpilotai/features/auth/domain/use_cases/send_password_reset_email_use_case.dart';

class FakeAuthRepository extends Fake implements AuthRepository {
  bool shouldFail = false;

  @override
  Future<Result<void>> signIn({required String email, required String password}) async {
    if (shouldFail) return const Result.failure(AuthFailure('Failed'));
    return const Result.success(null);
  }

  @override
  Future<Result<void>> signUp({required String email, required String password}) async {
    if (shouldFail) return const Result.failure(AuthFailure('Failed'));
    return const Result.success(null);
  }

  @override
  Future<Result<void>> signInWithGoogle() async {
    if (shouldFail) return const Result.failure(AuthFailure('Failed'));
    return const Result.success(null);
  }

  @override
  Future<Result<void>> signOut() async {
    if (shouldFail) return const Result.failure(AuthFailure('Failed'));
    return const Result.success(null);
  }

  @override
  Future<Result<void>> sendPasswordResetEmail({required String email}) async {
    if (shouldFail) return const Result.failure(AuthFailure('Failed'));
    return const Result.success(null);
  }
}

void main() {
  late FakeAuthRepository fakeRepository;

  setUp(() {
    fakeRepository = FakeAuthRepository();
  });

  group('SignInUseCase', () {
    test('returns success when repository succeeds', () async {
      final useCase = SignInUseCase(fakeRepository);
      final result = await useCase.call(email: 'test@example.com', password: 'password');
      expect(result, isA<Success<void>>());
    });

    test('returns failure when repository fails', () async {
      fakeRepository.shouldFail = true;
      final useCase = SignInUseCase(fakeRepository);
      final result = await useCase.call(email: 'test@example.com', password: 'password');
      expect(result, isA<FailureResult<void>>());
    });
  });

  group('SignUpUseCase', () {
    test('returns success when repository succeeds', () async {
      final useCase = SignUpUseCase(fakeRepository);
      final result = await useCase.call(email: 'test@example.com', password: 'password');
      expect(result, isA<Success<void>>());
    });

    test('returns failure when repository fails', () async {
      fakeRepository.shouldFail = true;
      final useCase = SignUpUseCase(fakeRepository);
      final result = await useCase.call(email: 'test@example.com', password: 'password');
      expect(result, isA<FailureResult<void>>());
    });
  });

  group('SignInWithGoogleUseCase', () {
    test('returns success when repository succeeds', () async {
      final useCase = SignInWithGoogleUseCase(fakeRepository);
      final result = await useCase.call();
      expect(result, isA<Success<void>>());
    });

    test('returns failure when repository fails', () async {
      fakeRepository.shouldFail = true;
      final useCase = SignInWithGoogleUseCase(fakeRepository);
      final result = await useCase.call();
      expect(result, isA<FailureResult<void>>());
    });
  });

  group('SignOutUseCase', () {
    test('returns success when repository succeeds', () async {
      final useCase = SignOutUseCase(fakeRepository);
      final result = await useCase.call();
      expect(result, isA<Success<void>>());
    });

    test('returns failure when repository fails', () async {
      fakeRepository.shouldFail = true;
      final useCase = SignOutUseCase(fakeRepository);
      final result = await useCase.call();
      expect(result, isA<FailureResult<void>>());
    });
  });

  group('SendPasswordResetEmailUseCase', () {
    test('returns success when repository succeeds', () async {
      final useCase = SendPasswordResetEmailUseCase(fakeRepository);
      final result = await useCase.call(email: 'test@example.com');
      expect(result, isA<Success<void>>());
    });

    test('returns failure when repository fails', () async {
      fakeRepository.shouldFail = true;
      final useCase = SendPasswordResetEmailUseCase(fakeRepository);
      final result = await useCase.call(email: 'test@example.com');
      expect(result, isA<FailureResult<void>>());
    });
  });
}
