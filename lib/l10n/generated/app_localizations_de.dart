// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Purity Auth';

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
  String get cannotGetClipboardData =>
      'Zwischenablage-Daten können nicht abgerufen werden';

  @override
  String importedCount(int count) {
    return '$count Elemente aus der Zwischenablage importiert';
  }

  @override
  String exportedCount(int count) {
    return '$count Elemente in die Zwischenablage exportiert';
  }

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
  String get importFromClipboard => 'Aus Zwischenablage importieren';

  @override
  String get exportToClipboard => 'In Zwischenablage exportieren';

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
  String get importWarning =>
      'Sie sind dabei, Daten aus der Zwischenablage zu importieren. Wenn bereits dieselben Konten in der Datenbank vorhanden sind, werden diese überschrieben. Möchten Sie fortfahren?';

  @override
  String get exportFailed => 'Export fehlgeschlagen';

  @override
  String get noDataToExport => 'Keine Daten zum Exportieren verfügbar';

  @override
  String get exportWarning =>
      'Sie sind dabei, alle Authentifikatoren in die Zwischenablage zu exportieren. Der exportierte Inhalt liegt im Klartextformat vor. Bitte stellen Sie sicher, dass Ihre Umgebung sicher ist, und löschen Sie anschließend die Zwischenablage. Möchten Sie fortfahren?';
}
