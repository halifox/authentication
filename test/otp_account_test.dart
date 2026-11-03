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
  test('recognizes Steam provisioning URI markers', () {
    for (final suffix in [
      'issuer=Steam',
      'issuer=Example&steam',
      'issuer=Example&encoder=steam',
    ]) {
      final account = parseOtpUri(
        'otpauth://totp/user?secret=63BEDWCQZKTQWPESARIERL5DTTQFCJTK&$suffix',
        detectSteam: true,
      );
      account.validate();
      expect(account.type, 'steam');
      expect(account.digits, 5);
      expect(account.generateCodeString().length, 5);
    }
    expect(
      () => parseOtpUri(
        'otpauth://totp/user?secret=JBSWY3DPEHPK3PXP&issuer=Steam&period=60',
        detectSteam: true,
      ),
      throwsA(isA<AuthFailure>()),
    );
  });
  test('validates PIN-bearing provisioning links without retaining a PIN', () {
    const uri =
        'otpauth://yaotp/person?secret=LA2V6KMCGYMWWVEW64RNP3JA3IAAAAAAHTSG4HRZPI&pin_length=4';
    final parsed = parseYandexProvisioning(uri);
    expect(parsed.pinLength, 4);
    expect(parsed.account.pin, isEmpty);
    expect(parsed.account.account, 'person');
    expect(
      () => parseYandexProvisioning('$uri&pin_length=5'),
      throwsFormatException,
    );
    expect(
      () => parseYandexProvisioning('$uri&pin=1234'),
      throwsFormatException,
    );
    expect(
      () => parseYandexProvisioning(
        uri.replaceAll('pin_length=4', 'pin_length=3'),
      ),
      throwsFormatException,
    );
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
