import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marsky_crypto_dashboard/core/error/error_mapper.dart';
import 'package:marsky_crypto_dashboard/core/error/exceptions.dart';
import 'package:marsky_crypto_dashboard/core/error/failures.dart';

void main() {
  final reqOptions = RequestOptions(path: '/test');

  group('mapDioToException', () {
    test('connectionTimeout maps to NetworkException', () {
      final err = DioException(
        requestOptions: reqOptions,
        type: DioExceptionType.connectionTimeout,
      );
      expect(mapDioToException(err), isA<NetworkException>());
    });

    test('sendTimeout maps to NetworkException', () {
      final err = DioException(
        requestOptions: reqOptions,
        type: DioExceptionType.sendTimeout,
      );
      expect(mapDioToException(err), isA<NetworkException>());
    });

    test('receiveTimeout maps to NetworkException', () {
      final err = DioException(
        requestOptions: reqOptions,
        type: DioExceptionType.receiveTimeout,
      );
      expect(mapDioToException(err), isA<NetworkException>());
    });

    test('connectionError maps to NetworkException', () {
      final err = DioException(
        requestOptions: reqOptions,
        type: DioExceptionType.connectionError,
      );
      expect(mapDioToException(err), isA<NetworkException>());
    });

    test('badCertificate maps to ServerException', () {
      final err = DioException(
        requestOptions: reqOptions,
        type: DioExceptionType.badCertificate,
      );
      final result = mapDioToException(err);
      expect(result, isA<ServerException>());
      expect(result.message, contains('SSL'));
    });

    test('badResponse with 401 maps to AuthException', () {
      final err = DioException(
        requestOptions: reqOptions,
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: reqOptions,
          statusCode: 401,
          data: {'message': 'Unauthorized'},
        ),
      );
      final result = mapDioToException(err);
      expect(result, isA<AuthException>());
      expect(result.message, 'Unauthorized');
    });

    test('badResponse with 403 maps to AuthException', () {
      final err = DioException(
        requestOptions: reqOptions,
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: reqOptions,
          statusCode: 403,
          data: {'error': 'Forbidden'},
        ),
      );
      final result = mapDioToException(err);
      expect(result, isA<AuthException>());
      expect(result.message, 'Forbidden');
    });

    test('badResponse with 500 maps to ServerException', () {
      final err = DioException(
        requestOptions: reqOptions,
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: reqOptions,
          statusCode: 500,
          data: {'message': 'Server crashed'},
        ),
      );
      final result = mapDioToException(err);
      expect(result, isA<ServerException>());
      expect(result.statusCode, 500);
      expect(result.message, 'Server crashed');
    });

    test('cancel maps to ServerException', () {
      final err = DioException(
        requestOptions: reqOptions,
        type: DioExceptionType.cancel,
      );
      expect(mapDioToException(err), isA<ServerException>());
    });

    test('unknown maps to ServerException', () {
      final err = DioException(
        requestOptions: reqOptions,
        type: DioExceptionType.unknown,
      );
      expect(mapDioToException(err), isA<ServerException>());
    });
  });

  group('mapExceptionToFailure', () {
    test('NetworkException maps to NetworkFailure', () {
      expect(
        mapExceptionToFailure(const NetworkException('no net')),
        isA<NetworkFailure>(),
      );
    });

    test('AuthException maps to AuthFailure', () {
      final result = mapExceptionToFailure(const AuthException('bad creds'));
      expect(result, isA<AuthFailure>());
      expect(result.message, 'bad creds');
    });

    test('ServerException maps to ServerFailure with status code', () {
      final result = mapExceptionToFailure(
        const ServerException('boom', statusCode: 500),
      );
      expect(result, isA<ServerFailure>());
      expect((result as ServerFailure).statusCode, 500);
    });

    test('CacheException maps to CacheFailure', () {
      expect(
        mapExceptionToFailure(const CacheException()),
        isA<CacheFailure>(),
      );
    });

    test('DioException is mapped recursively', () {
      final err = DioException(
        requestOptions: reqOptions,
        type: DioExceptionType.connectionTimeout,
      );
      expect(mapExceptionToFailure(err), isA<NetworkFailure>());
    });

    test('Unknown error maps to UnknownFailure', () {
      expect(
        mapExceptionToFailure(Exception('weird')),
        isA<UnknownFailure>(),
      );
    });
  });
}
