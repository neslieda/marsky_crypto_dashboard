import 'package:dio/dio.dart';

import '../settings/currency.dart';

/// Adds `referenceCurrencyUuid` to every CoinRanking GET request based on
/// the user's selected currency.
class CurrencyInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.method.toUpperCase() == 'GET') {
      options.queryParameters.putIfAbsent(
        'referenceCurrencyUuid',
        () => CurrencyHolder.instance.current.uuid,
      );
    }
    handler.next(options);
  }
}
