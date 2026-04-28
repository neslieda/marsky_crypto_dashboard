import 'package:intl/intl.dart';

import '../settings/currency.dart';

class Formatters {
  const Formatters._();

  static final NumberFormat _percent =
      NumberFormat.decimalPercentPattern(decimalDigits: 2);

  static String price(num? value) {
    if (value == null) return '-';
    final symbol = CurrencyHolder.instance.current.symbol;
    if (value.abs() < 1) {
      return NumberFormat.currency(symbol: symbol, decimalDigits: 6)
          .format(value);
    }
    return NumberFormat.currency(symbol: symbol, decimalDigits: 2).format(value);
  }

  static String compactPrice(num? value) {
    if (value == null) return '-';
    final symbol = CurrencyHolder.instance.current.symbol;
    return NumberFormat.compactCurrency(symbol: symbol).format(value);
  }

  static String percent(num? value) {
    if (value == null) return '-';
    final v = value / 100; // CoinRanking returns "5.21" meaning 5.21%
    return _percent.format(v);
  }

  static String date(DateTime? value) {
    if (value == null) return '-';
    return DateFormat.yMMMd().format(value);
  }
}
