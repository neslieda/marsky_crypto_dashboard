import 'package:flutter_test/flutter_test.dart';
import 'package:marsky_crypto_dashboard/core/error/failures.dart';

void main() {
  test('failures expose their message and props', () {
    expect(const NetworkFailure('no net').message, 'no net');
    expect(const ServerFailure('boom', statusCode: 500).statusCode, 500);
    expect(const AuthFailure('bad') == const AuthFailure('bad'), isTrue);
  });
}
