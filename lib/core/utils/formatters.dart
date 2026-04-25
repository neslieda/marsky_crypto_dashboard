import 'package:intl/intl.dart';

class Formatters {
  const Formatters._();

  static final NumberFormat _usd = NumberFormat.simpleCurrency(name: 'USD');
  static final NumberFormat _compact =
      NumberFormat.compactSimpleCurrency(name: 'USD');
  static final NumberFormat _percent =
      NumberFormat.decimalPercentPattern(decimalDigits: 2);

  static String price(num? value) {
    if (value == null) return '-';
    if (value.abs() < 1) {
      return NumberFormat.currency(symbol: r'$', decimalDigits: 6).format(value);
    }
    return _usd.format(value);
  }

  static String compactPrice(num? value) {
    if (value == null) return '-';
    return _compact.format(value);
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
