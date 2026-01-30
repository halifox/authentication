import 'package:auth/l10n/generated/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:base32/base32.dart';

enum AuthErrorCode {
  invalidScheme,
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
  unknown;

  String getLocalizedMessage(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return switch (this) {
      AuthErrorCode.invalidScheme => l10n.invalidScheme,
      AuthErrorCode.invalidType => l10n.invalidType,
      AuthErrorCode.issuerCannotBeEmpty => l10n.issuerCannotBeEmpty,
      AuthErrorCode.accountCannotBeEmpty => l10n.accountCannotBeEmpty,
      AuthErrorCode.invalidAlgorithm => l10n.invalidAlgorithm,
      AuthErrorCode.invalidDigits => l10n.invalidDigits,
      AuthErrorCode.invalidPeriod => l10n.invalidPeriod,
      AuthErrorCode.invalidCounter => l10n.invalidCounter,
      AuthErrorCode.invalidPin => l10n.invalidPin,
      AuthErrorCode.invalidSecretKey => l10n.invalidSecretKey,
      AuthErrorCode.noData => l10n.noData,
      AuthErrorCode.unknown => 'Unknown Error',
    };
  }
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
    if (!const ['totp', 'hotp', 'motp'].contains(type)) {
      throw AuthFailure(AuthErrorCode.invalidType);
    }

    if (issuer.trim().isEmpty) throw AuthFailure(AuthErrorCode.issuerCannotBeEmpty);
    if (account.trim().isEmpty) throw AuthFailure(AuthErrorCode.accountCannotBeEmpty);

    final algorithm = algorithmStr.toLowerCase();
    if (!const ['sha1', 'sha256', 'sha512'].contains(algorithm)) {
      throw AuthFailure(AuthErrorCode.invalidAlgorithm);
    }

    switch (type) {
      case 'totp':
        if (digits < 6 || digits > 8) throw AuthFailure(AuthErrorCode.invalidDigits);
        if (period <= 0) throw AuthFailure(AuthErrorCode.invalidPeriod);
      case 'hotp':
        if (digits < 6 || digits > 8) throw AuthFailure(AuthErrorCode.invalidDigits);
        if (counter < 0) throw AuthFailure(AuthErrorCode.invalidCounter);
      case 'motp':
        if (digits == 6) throw AuthFailure(AuthErrorCode.invalidDigits);
        if (pin.isEmpty) throw AuthFailure(AuthErrorCode.invalidPin);
    }

    // Secret (Base32) check
    if (!_verifyBase32(secret)) {
      throw AuthFailure(AuthErrorCode.invalidSecretKey);
    }
  }

  static bool _verifyBase32(String? input) {
    if (input == null || input.trim().isEmpty) return false;
    try {
      final cleanInput = input.trim().replaceAll(' ', '').toUpperCase();
      base32.decode(cleanInput);
      return true;
    } catch (e) {
      return false;
    }
  }
}
