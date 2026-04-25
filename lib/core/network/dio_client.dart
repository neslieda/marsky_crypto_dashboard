import 'package:dio/dio.dart';

import '../config/app_env.dart';
import 'dio_interceptors.dart';

class DioClient {
  DioClient._(this.dio);

  final Dio dio;

  factory DioClient.coinRanking() {
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
    dio.interceptors.add(LoggingInterceptor());
    return DioClient._(dio);
  }
}
