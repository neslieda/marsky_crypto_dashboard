class AppException implements Exception {
  final String message;
  final int? statusCode;
  const AppException(this.message, {this.statusCode});

  @override
  String toString() => 'AppException($statusCode): $message';
}

class ServerException extends AppException {
  const ServerException(super.message, {super.statusCode});
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection.']);
}

class AuthException extends AppException {
  const AuthException(super.message);
}

class EmailConfirmationException extends AppException {
  const EmailConfirmationException(
      [super.message = 'Please confirm your email to continue.']);
}

class CacheException extends AppException {
  const CacheException([super.message = 'Cache error.']);
}
