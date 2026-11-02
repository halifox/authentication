import 'package:authentication/utils/otp.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('generates the RFC 6238 SHA-1 code at 59 seconds', () {
    expect(
      OTP.generateTOTPCodeString(
        secret: '12345678901234567890',
        unixMilliseconds: 59000,
        digits: 8,
        algorithm: Algorithm.sha1,
      ),
      '94287082',
    );
  });
}
