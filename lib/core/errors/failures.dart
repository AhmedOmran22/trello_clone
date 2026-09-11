import 'package:equatable/equatable.dart';

import 'exceptions.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Maps an exception thrown by a datasource (already normalized through
/// [mapToAppException]) to the matching [Failure], so repositories don't
/// each re-implement the same type switch.
Failure mapExceptionToFailure(Object error) {
  if (error is NetworkException) return NetworkFailure(error.message);
  if (error is AuthException) return AuthFailure(error.message);
  if (error is CacheException) return CacheFailure(error.message);
  if (error is ServerException) return ServerFailure(error.message);
  return ServerFailure(error.toString());
}
