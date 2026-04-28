import 'package:flutter/foundation.dart';

/// Reference currency that the CoinRanking API should return prices in.
/// Note: CoinRanking free plan only supports USD as reference currency.
/// EUR / TRY require a paid plan.
enum AppCurrency {
  usd(uuid: 'yhjMzLPhuIDl', symbol: r'$', code: 'USD');

  const AppCurrency({
    required this.uuid,
    required this.symbol,
    required this.code,
  });

  final String uuid;
  final String symbol;
  final String code;

  static AppCurrency fromCode(String? code) {
    return AppCurrency.values.firstWhere(
      (c) => c.code == code,
      orElse: () => AppCurrency.usd,
    );
  }
}

/// App-wide holder so non-Bloc layers (Dio interceptor, Formatters) can read
/// the currently active reference currency without a BuildContext.
class CurrencyHolder {
  CurrencyHolder._();
  static final CurrencyHolder instance = CurrencyHolder._();

  final ValueNotifier<AppCurrency> notifier =
      ValueNotifier<AppCurrency>(AppCurrency.usd);

  AppCurrency get current => notifier.value;

  void set(AppCurrency value) {
    if (notifier.value == value) return;
    notifier.value = value;
  }
}
