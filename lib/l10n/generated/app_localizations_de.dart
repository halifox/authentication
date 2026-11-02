// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Authentication';

  @override
  String get add => 'Hinzufügen';

  @override
  String get scan => 'Scannen';

  @override
  String get settings => 'Einstellungen';

  @override
  String get scanQRCode => 'QR-Code scannen';

  @override
  String get secret => 'Geheimnis';

  @override
  String get algorithm => 'Algorithmus';

  @override
  String get digits => 'Ziffern';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get delete => 'Löschen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get ok => 'OK';

  @override
  String get codeCopied => 'Code kopiert';

  @override
  String get tip => 'Tipp';

  @override
  String get warning => 'Warnung';

  @override
  String get importFailed => 'Import fehlgeschlagen';

  @override
  String get importSuccess => 'Import erfolgreich';

  @override
  String get exportSuccess => 'Export erfolgreich';

  @override
  String get addSuccess => 'Erfolgreich hinzugefügt';

  @override
  String get updateSuccess => 'Erfolgreich aktualisiert';

  @override
  String get saveFailed => 'Speichern fehlgeschlagen';

  @override
  String get platformNotSupported =>
      'Diese Funktion wird derzeit nur auf Android- und iOS-Plattformen unterstützt.';

  @override
  String get unsupportedQRCode => 'Dieser QR-Code-Typ wird nicht unterstützt';

  @override
  String tokenExists(String issuer, String account) {
    return 'Token $issuer:$account existiert bereits. Möchten Sie es überschreiben?';
  }

  @override
  String get deleteWarning =>
      'Sie sind dabei, den aktuellen Zwei-Faktor-Authentifikator zu löschen.\nDiese Aktion verhindert, dass Sie diesen Authentifikator für die Authentifizierung verwenden können.\nBitte stellen Sie sicher, dass Sie andere Authentifizierungsmethoden bereit haben, um die Kontosicherheit zu gewährleisten.';

  @override
  String get uploadQRCode => 'QR-Code importieren';

  @override
  String get enterKey => 'Schlüssel eingeben';

  @override
  String get enterProvidedKey => 'Schlüssel eingeben';

  @override
  String get type => 'Typ';

  @override
  String get issuer => 'Herausgeber';

  @override
  String get account => 'Konto';

  @override
  String get pin => 'PIN-Code';

  @override
  String get period => 'Zeitraum (Sekunden)';

  @override
  String get counter => 'Zähler';

  @override
  String get totp => 'TOTP (Zeitbasiert)';

  @override
  String get hotp => 'HOTP (Zählerbasiert)';

  @override
  String get motp => 'mOTP (Mobiles OTP)';

  @override
  String get showCaptchaOnTap => 'Tippen zum Anzeigen';

  @override
  String get copyCaptchaOnTap => 'Tippen zum Kopieren';

  @override
  String get sha1 => 'SHA1';

  @override
  String get sha256 => 'SHA256';

  @override
  String get sha512 => 'SHA512';

  @override
  String get selectIcon => 'Symbol auswählen';

  @override
  String get invalidSecret => 'Ungültiges Geheimnis';

  @override
  String get dismiss => 'Schließen';

  @override
  String get invalidScheme => 'Ungültiges Schema';

  @override
  String get invalidType => 'Ungültiger Typ';

  @override
  String get issuerCannotBeEmpty => 'Herausgeber darf nicht leer sein';

  @override
  String get accountCannotBeEmpty => 'Konto darf nicht leer sein';

  @override
  String get invalidAlgorithm => 'Ungültiger Algorithmus';

  @override
  String get invalidDigits => 'Ungültige Ziffernanzahl';

  @override
  String get invalidPeriod => 'Ungültiger Zeitraum';

  @override
  String get invalidCounter => 'Ungültiger Zähler';

  @override
  String get invalidPin => 'Ungültiger PIN-Code';

  @override
  String get invalidSecretKey => 'Ungültiger geheimer Schlüssel';

  @override
  String get noData => 'Keine Daten';

  @override
  String get search => 'Suchen';

  @override
  String get exportFailed => 'Export fehlgeschlagen';

  @override
  String get noDataToExport => 'Keine Daten zum Exportieren verfügbar';

  @override
  String get importFile => 'Import file';

  @override
  String get exportFile => 'Export file';

  @override
  String get backupPasswordTitle => 'Backup password';

  @override
  String get backupPasswordHint => 'Leave empty for an unencrypted file';

  @override
  String get backupPasswordRequired => 'Enter backup password';

  @override
  String get backupPasswordConfirm => 'Confirm password';

  @override
  String get backupPasswordMismatch => 'Passwords do not match';

  @override
  String get backupPlainWarning =>
      'Without a password, this file contains all your secret keys in plain text. Keep it in a safe place.';

  @override
  String get backupReplaceWarning =>
      'Importing replaces accounts with the same issuer and account name. Continue?';

  @override
  String get backupFileTooLarge => 'The backup file is too large.';

  @override
  String get backupFileError =>
      'The file could not be imported. Check the password and file contents.';

  @override
  String get backupSaved => 'Backup file saved.';

  @override
  String get backupImported => 'Backup file imported.';

  @override
  String get backupDownloadStarted =>
      'The browser was asked to download the backup. Check that the download completed.';

  @override
  String get importUriList => 'Import URI list';

  @override
  String get exportUriList => 'Export URI list';

  @override
  String get uriPlainWarning =>
      'This file contains account secrets in plain text. Anyone with the file can generate your codes. Store it securely.';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get noSearchResults => 'No matching accounts';

  @override
  String get settingsLoadError => 'Settings could not be loaded.';

  @override
  String get backupSettingsWarning =>
      'Accounts with the same issuer and account name will be updated. Settings in the backup will also be restored. Continue?';
}
