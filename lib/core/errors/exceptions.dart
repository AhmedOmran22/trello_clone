import 'dart:io';

class ServerException implements Exception {
  final String message;

  const ServerException(this.message);

  @override
  String toString() => 'ServerException: $message';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}

class CacheException implements Exception {
  final String message;

  const CacheException(this.message);

  @override
  String toString() => 'CacheException: $message';
}

const noInternetMessage = 'No internet connection. Please check your network and try again.';

/// Normalizes a caught error into one of our app exceptions, so a raw
/// [SocketException] (thrown when the device has no internet) surfaces as a
/// [NetworkException] instead of a generic, unfriendly [ServerException].
Exception mapToAppException(Object error) {
  if (error is NetworkException ||
      error is ServerException ||
      error is AuthException ||
      error is CacheException) {
    return error as Exception;
  }
  if (error is SocketException) {
    return const NetworkException(noInternetMessage);
  }
  return ServerException(error.toString());
}
