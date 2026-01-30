import 'package:base32/base32.dart';

import 'package:auth/db/database.dart';
import 'package:auth/utils/otp.dart';
import 'package:auth/domain/models/auth_validation.dart';
import 'package:auth/domain/services/otp_service.dart';

// --- Extensions ---

extension AuthEntryLogic on AuthEntry {

  void validateThrow() {
    AuthValidator.validate(
      scheme: scheme,
      typeStr: type,
      issuer: issuer,
      account: account,
      algorithmStr: algorithm,
      digits: digits,
      period: period,
      counter: counter,
      secret: secret,
      pin: pin,
    );
  }

  String generateCodeString() {
    final typeLower = type.toLowerCase();
    final algo = AuthEntryUtils.getAlgorithm(algorithm);

    return switch (typeLower) {
      'totp' => OTP.generateTOTPCodeString(secret: secret, digits: digits, algorithm: algo, intervalSeconds: period, isBase32: true),
      'hotp' => OTP.generateHOTPCodeString(secret: secret, digits: digits, algorithm: algo, counter: counter, isBase32: true),
      'motp' => OTP.generateMOTPCodeString(secret: secret, digits: digits, intervalSeconds: period, pin: pin),
      _ => '',
    };
  }

  String toOtpUri() =>
      AuthEntryUtils.generateUri(scheme: scheme, type: type, issuer: issuer, account: account, secret: secret, algorithm: algorithm, digits: digits, period: period, counter: counter, pin: pin);
}

extension AuthEntriesCompanionLogic on AuthEntriesCompanion {

  void validateThrow() {
    AuthValidator.validate(
      scheme: scheme.value,
      typeStr: type.value,
      issuer: issuer.value,
      account: account.value,
      algorithmStr: algorithm.value,
      digits: digits.value,
      period: period.value,
      counter: counter.value,
      secret: secret.value,
      pin: pin.value,
    );
  }

}

// --- Utils ---

class AuthEntryUtils {
  /// Parses a OTP Auth URI string into an [AuthEntriesCompanion].
  static AuthEntriesCompanion parse(String uriString) {
    return OtpService.parseUri(uriString);
  }

  /// Generates a standard OTP Auth URI string.
  static String generateUri({
    required String scheme,
    required String type,
    required String issuer,
    required String account,
    required String secret,
    required String algorithm,
    required int digits,
    required int period,
    required int counter,
    required String pin,
  }) {
    final typeLower = type.toLowerCase();
    final queryParams = {'secret': secret.toUpperCase(), 'issuer': issuer, 'algorithm': algorithm.toLowerCase(), 'digits': digits.toString()};

    if (typeLower == 'totp' || typeLower == 'motp') {
      queryParams['period'] = period.toString();
    }
    if (typeLower == 'hotp') {
      queryParams['counter'] = counter.toString();
    }
    if (typeLower == 'motp' && pin.isNotEmpty) {
      queryParams['pin'] = pin;
    }

    // Standard Label format: Issuer:Account
    final label = issuer.isNotEmpty ? '$issuer:$account' : account;

    return Uri(scheme: scheme.toLowerCase(), host: typeLower, path: '/$label', queryParameters: queryParams).toString();
  }

  /// Verifies if the input string is a valid Base32 encoded string.
  static bool verifyBase32(String? input) {
    if (input == null || input.trim().isEmpty) return false;
    try {
      final cleanInput = input.trim().replaceAll(' ', '').toUpperCase();
      base32.decode(cleanInput);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Algorithm getAlgorithm(String value) {
    return switch (value.toLowerCase()) {
      'sha1' => Algorithm.sha1,
      'sha256' => Algorithm.sha256,
      'sha512' => Algorithm.sha512,
      _ => Algorithm.sha1,
    };
  }
}
