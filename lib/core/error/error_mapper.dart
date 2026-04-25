import 'package:dio/dio.dart';

import '../error/exceptions.dart';
import '../error/failures.dart';

/// Maps a [DioException] to a domain [AppException].
AppException mapDioToException(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
      return const NetworkException();
    case DioExceptionType.badCertificate:
      return const ServerException('Invalid SSL certificate.');
    case DioExceptionType.badResponse:
      final code = error.response?.statusCode;
      final data = error.response?.data;
      String message = 'Server error.';
      if (data is Map && data['message'] is String) {
        message = data['message'] as String;
      } else if (data is Map && data['error'] is String) {
        message = data['error'] as String;
      }
      if (code == 401 || code == 403) {
        return AuthException(message);
      }
      return ServerException(message, statusCode: code);
    case DioExceptionType.cancel:
      return const ServerException('Request cancelled.');
    case DioExceptionType.unknown:
      return const ServerException('Unknown error occurred.');
  }
}

/// Maps any [Object] (Exception/Error) to a [Failure].
Failure mapExceptionToFailure(Object error) {
  if (error is NetworkException) return NetworkFailure(error.message);
  if (error is AuthException) return AuthFailure(error.message);
  if (error is ServerException) {
    return ServerFailure(error.message, statusCode: error.statusCode);
  }
  if (error is CacheException) return CacheFailure(error.message);
  if (error is DioException) {
    return mapExceptionToFailure(mapDioToException(error));
  }
  return UnknownFailure(error.toString());
}
