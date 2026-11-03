import 'package:authentication/otp/otp.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Steam and Yandex interoperability vectors', () {
    const steamSecret = '63BEDWCQZKTQWPESARIERL5DTTQFCJTK';
    expect(
      OTP.generateSteamCode(
        secret: steamSecret,
        unixMilliseconds: 1511200518000,
      ),
      'FR8RV',
    );
    expect(
      OTP.generateSteamCode(
        secret: steamSecret,
        unixMilliseconds: 1511200714000,
      ),
      '9P3VP',
    );
    const yandexSecret = 'LA2V6KMCGYMWWVEW64RNP3JA3IAAAAAAHTSG4HRZPI';
    expect(
      OTP.generateYandexCode(
        secret: yandexSecret,
        pin: '7586',
        unixMilliseconds: 1581064020000,
      ),
      'oactmacq',
    );
    expect(
      OTP.generateYandexCode(
        secret: yandexSecret,
        pin: '7586',
        unixMilliseconds: 1581090810000,
      ),
      'wemdwrix',
    );
  });
  test('TOTP supports nine and ten digits with leading zeros', () {
    expect(
      OTP.generateTOTPCodeString(
        secret: '12345678901234567890',
        unixMilliseconds: 59000,
        digits: 9,
        algorithm: Algorithm.sha1,
      ),
      '094287082',
    );
    expect(
      OTP.generateTOTPCodeString(
        secret: '12345678901234567890',
        unixMilliseconds: 1111111109000,
        digits: 10,
        algorithm: Algorithm.sha1,
      ),
      '0907081804',
    );
  });
  test('mOTP MD5 vector', () {
    expect(
      OTP.generateMOTPCodeString(
        secret: 'abcdef',
        pin: '1234',
        unixMilliseconds: 1234567890000,
      ),
      '9A4885',
    );
  });
  test('RFC 4226 HOTP vectors', () {
    const expected = [
      '755224',
      '287082',
      '359152',
      '969429',
      '338314',
      '254676',
      '287922',
      '162583',
      '399871',
      '520489',
    ];
    for (var i = 0; i < expected.length; i++) {
      expect(
        OTP.generateHOTPCodeString(secret: '12345678901234567890', counter: i),
        expected[i],
      );
    }
  });

  test('RFC 6238 TOTP vectors for all supported algorithms', () {
    const timestamps = [
      59,
      1111111109,
      1111111111,
      1234567890,
      2000000000,
      20000000000,
    ];
    const vectors = {
      Algorithm.sha1: [
        '94287082',
        '07081804',
        '14050471',
        '89005924',
        '69279037',
        '65353130',
      ],
      Algorithm.sha256: [
        '46119246',
        '68084774',
        '67062674',
        '91819424',
        '90698825',
        '77737706',
      ],
      Algorithm.sha512: [
        '90693936',
        '25091201',
        '99943326',
        '93441116',
        '38618901',
        '47863826',
      ],
    };
    final secrets = {
      Algorithm.sha1: '12345678901234567890',
      Algorithm.sha256: '12345678901234567890123456789012',
      Algorithm.sha512:
          '1234567890123456789012345678901234567890123456789012345678901234',
    };
    for (final algorithm in vectors.keys) {
      for (var i = 0; i < timestamps.length; i++) {
        expect(
          OTP.generateTOTPCodeString(
            secret: secrets[algorithm]!,
            unixMilliseconds: timestamps[i] * 1000,
            digits: 8,
            algorithm: algorithm,
          ),
          vectors[algorithm]![i],
        );
      }
    }
  });
}
