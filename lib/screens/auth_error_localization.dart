import 'package:authentication/l10n/generated/app_localizations.dart';
import 'package:authentication/otp/validation.dart';
import 'package:flutter/widgets.dart';

export 'package:authentication/otp/validation.dart';

extension AuthErrorLocalization on AuthErrorCode {
  String getLocalizedMessage(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return switch (this) {
      AuthErrorCode.invalidScheme => l10n.invalidScheme,
      AuthErrorCode.duplicateParameters => l10n.duplicateParameters,
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
