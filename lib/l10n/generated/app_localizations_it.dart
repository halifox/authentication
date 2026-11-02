// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Authentication';

  @override
  String get add => 'Aggiungi';

  @override
  String get scan => 'Scansiona';

  @override
  String get settings => 'Impostazioni';

  @override
  String get scanQRCode => 'Scansiona codice QR';

  @override
  String get secret => 'Segreto';

  @override
  String get algorithm => 'Algoritmo';

  @override
  String get digits => 'Cifre';

  @override
  String get cancel => 'Annulla';

  @override
  String get delete => 'Elimina';

  @override
  String get edit => 'Modifica';

  @override
  String get ok => 'OK';

  @override
  String get codeCopied => 'Codice copiato';

  @override
  String get tip => 'Suggerimento';

  @override
  String get warning => 'Avviso';

  @override
  String get importFailed => 'Importazione fallita';

  @override
  String get importSuccess => 'Importazione riuscita';

  @override
  String get exportSuccess => 'Esportazione riuscita';

  @override
  String get addSuccess => 'Aggiunto con successo';

  @override
  String get updateSuccess => 'Aggiornamento riuscito';

  @override
  String get saveFailed => 'Salvataggio fallito';

  @override
  String get platformNotSupported =>
      'Questa funzione è attualmente supportata solo sulle piattaforme Android e iOS.';

  @override
  String get unsupportedQRCode => 'Questo tipo di codice QR non è supportato';

  @override
  String tokenExists(String issuer, String account) {
    return 'Il token $issuer:$account esiste già. Vuoi sovrascriverlo?';
  }

  @override
  String get deleteWarning =>
      'Stai per eliminare l\'autenticatore a due fattori corrente.\nQuesta azione ti impedirà di usare questo autenticatore per l\'autenticazione.\nAssicurati di avere altri metodi di autenticazione pronti per garantire la sicurezza dell\'account.';

  @override
  String get uploadQRCode => 'Importa codice QR';

  @override
  String get enterKey => 'Inserisci chiave';

  @override
  String get enterProvidedKey => 'Inserisci chiave';

  @override
  String get type => 'Tipo';

  @override
  String get issuer => 'Emittente';

  @override
  String get account => 'Account';

  @override
  String get pin => 'Codice PIN';

  @override
  String get period => 'Periodo (secondi)';

  @override
  String get counter => 'Contatore';

  @override
  String get totp => 'TOTP (Basato sul tempo)';

  @override
  String get hotp => 'HOTP (Basato sul contatore)';

  @override
  String get motp => 'mOTP (OTP Mobile)';

  @override
  String get showCaptchaOnTap => 'Tocca per mostrare';

  @override
  String get copyCaptchaOnTap => 'Tocca per copiare';

  @override
  String get sha1 => 'SHA1';

  @override
  String get sha256 => 'SHA256';

  @override
  String get sha512 => 'SHA512';

  @override
  String get selectIcon => 'Seleziona icona';

  @override
  String get invalidSecret => 'Segreto non valido';

  @override
  String get dismiss => 'Chiudi';

  @override
  String get invalidScheme => 'Schema non valido';

  @override
  String get invalidType => 'Tipo non valido';

  @override
  String get issuerCannotBeEmpty => 'L\'emittente non può essere vuoto';

  @override
  String get accountCannotBeEmpty => 'L\'account non può essere vuoto';

  @override
  String get invalidAlgorithm => 'Algoritmo non valido';

  @override
  String get invalidDigits => 'Numero di cifre non valido';

  @override
  String get invalidPeriod => 'Periodo non valido';

  @override
  String get invalidCounter => 'Contatore non valido';

  @override
  String get invalidPin => 'Codice PIN non valido';

  @override
  String get invalidSecretKey => 'Chiave segreta non valida';

  @override
  String get noData => 'Nessun dato';

  @override
  String get search => 'Cerca';

  @override
  String get exportFailed => 'Esportazione fallita';

  @override
  String get noDataToExport => 'Nessun dato disponibile da esportare';

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
}
