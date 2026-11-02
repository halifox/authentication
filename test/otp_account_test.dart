import 'package:authentication/otp/account.dart';
import 'package:authentication/otp/validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
