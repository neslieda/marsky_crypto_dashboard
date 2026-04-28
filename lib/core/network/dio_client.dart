import 'package:dio/dio.dart';

import '../config/app_env.dart';
import 'currency_interceptor.dart';
import 'dio_interceptors.dart';

class DioClient {
  DioClient._(this.dio);

  final Dio dio;

  factory DioClient.coinRanking({Interceptor? cacheInterceptor}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppEnv.coinRankingBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'x-access-token': AppEnv.coinRankingApiKey,
          'Accept': 'application/json',
        },
      ),
    );
    dio.interceptors.add(CurrencyInterceptor());
    if (cacheInterceptor != null) {
      dio.interceptors.add(cacheInterceptor);
    }
    dio.interceptors.add(LoggingInterceptor());
    return DioClient._(dio);
  }
}
