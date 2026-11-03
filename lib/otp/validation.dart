import 'package:base32/base32.dart';

enum AuthErrorCode {
  invalidScheme,
  duplicateParameters,
  invalidType,
  issuerCannotBeEmpty,
  accountCannotBeEmpty,
  invalidAlgorithm,
  invalidDigits,
  invalidPeriod,
  invalidCounter,
  invalidPin,
  invalidSecretKey,
  noData,
  unknown,
}

class AuthFailure implements Exception {
  final AuthErrorCode code;
  final String? message;
  AuthFailure(this.code, [this.message]);

  @override
  String toString() => 'AuthFailure($code, $message)';
}

class AuthValidator {
  static void validate({
    required String scheme,
    required String typeStr,
    required String issuer,
    required String account,
    required String algorithmStr,
    required int digits,
    required int period,
    required int counter,
    required String secret,
    required String pin,
  }) {
    if (scheme.toLowerCase() != 'otpauth') {
      throw AuthFailure(AuthErrorCode.invalidScheme);
    }

    final type = typeStr.toLowerCase();
    if (!const ['totp', 'hotp', 'motp', 'steam', 'yandex'].contains(type)) {
      throw AuthFailure(AuthErrorCode.invalidType);
    }

    if (issuer.trim().isEmpty)
      throw AuthFailure(AuthErrorCode.issuerCannotBeEmpty);
    if (account.trim().isEmpty)
      throw AuthFailure(AuthErrorCode.accountCannotBeEmpty);

    final algorithm = algorithmStr.toLowerCase();
    if (!const ['sha1', 'sha256', 'sha512'].contains(algorithm)) {
      throw AuthFailure(AuthErrorCode.invalidAlgorithm);
    }

    switch (type) {
      case 'totp':
        if (digits < 6 || digits > 10)
          throw AuthFailure(AuthErrorCode.invalidDigits);
        if (period <= 0) throw AuthFailure(AuthErrorCode.invalidPeriod);
      case 'hotp':
        if (digits < 6 || digits > 8)
          throw AuthFailure(AuthErrorCode.invalidDigits);
        if (counter < 0) throw AuthFailure(AuthErrorCode.invalidCounter);
      case 'motp':
        if (digits != 6) throw AuthFailure(AuthErrorCode.invalidDigits);
        if (pin.isEmpty) throw AuthFailure(AuthErrorCode.invalidPin);
        if (period <= 0) throw AuthFailure(AuthErrorCode.invalidPeriod);
      case 'steam':
        if (digits != 5) throw AuthFailure(AuthErrorCode.invalidDigits);
        if (period != 30) throw AuthFailure(AuthErrorCode.invalidPeriod);
      case 'yandex':
        if (digits != 8) throw AuthFailure(AuthErrorCode.invalidDigits);
        if (period != 30) throw AuthFailure(AuthErrorCode.invalidPeriod);
        if (pin.isEmpty) throw AuthFailure(AuthErrorCode.invalidPin);
        try {
          if (base32.decode(secret).length < 16) {
            throw AuthFailure(AuthErrorCode.invalidSecretKey);
          }
        } catch (_) {
          throw AuthFailure(AuthErrorCode.invalidSecretKey);
        }
    }

    // Secret (Base32) check
    if (type == 'motp' ? secret.isEmpty : !_verifyBase32(secret)) {
      throw AuthFailure(AuthErrorCode.invalidSecretKey);
    }
  }

  static bool _verifyBase32(String? input) {
    if (input == null || input.trim().isEmpty) return false;
    try {
      final cleanInput = input
          .trim()
          .replaceAll(RegExp(r'\s+'), '')
          .toUpperCase();
      base32.decode(cleanInput);
      return true;
    } catch (e) {
      return false;
    }
  }
}
