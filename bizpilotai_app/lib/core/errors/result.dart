import 'package:freezed_annotation/freezed_annotation.dart';
import 'failure.dart';

part 'result.freezed.dart';

@freezed
class Result<T> with _$Result<T> {
  const factory Result.success(T data) = Success<T>;
  
  // Named `FailureResult` because `Failure` alone collides with the abstract class
  // defined in failure.dart. This complies with docs/07_Architecture.md conceptually.
  const factory Result.failure(Failure failure) = FailureResult<T>;
}
