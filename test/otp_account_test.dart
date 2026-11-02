import 'package:authentication/otp/account.dart';
import 'package:authentication/otp/validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Steam and Yandex accounts validate and survive URI round trips', () {
    for (final account in [
      const OtpAccount(
        type: 'steam',
        issuer: 'Steam',
        account: 'user',
        secret: '63BEDWCQZKTQWPESARIERL5DTTQFCJTK',
        digits: 5,
      ),
      const OtpAccount(
        type: 'yandex',
        issuer: 'Yandex',
        account: 'user',
        secret: 'LA2V6KMCGYMWWVEW64RNP3JA3IAAAAAAHTSG4HRZPI',
        pin: '7586',
        digits: 8,
      ),
    ]) {
      account.validate();
      final restored = parseOtpUri(account.toOtpUri());
      restored.validate();
      expect(restored.type, account.type);
      expect(restored.pin, account.pin);
      expect(restored.generateCodeString().length, account.digits);
    }
  });
  test('parses and validates an OTP URI without a database', () {
    final account = parseOtpUri(
      'otpauth://totp/Example:user?secret=jbswy3dpehpk3pxp&issuer=Example',
    );
    expect(account.secret, 'JBSWY3DPEHPK3PXP');
    expect(account.account, 'user');
    account.validate();
  });
  test('invalid digits are rejected', () {
    expect(
      () => parseOtpUri(
        'otpauth://totp/Example:user?secret=JBSWY3DPEHPK3PXP&digits=x',
      ),
      throwsA(isA<AuthFailure>()),
    );
  });
}
