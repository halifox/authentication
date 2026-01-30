// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Purity Auth';

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
  String get cannotGetClipboardData =>
      'Impossibile ottenere i dati degli appunti';

  @override
  String importedCount(int count) {
    return '$count elementi importati dagli appunti';
  }

  @override
  String exportedCount(int count) {
    return '$count elementi esportati negli appunti';
  }

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
  String get importFromClipboard => 'Importa dagli appunti';

  @override
  String get exportToClipboard => 'Esporta negli appunti';

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
  String get importWarning =>
      'Stai per importare dati dagli appunti. Se gli stessi account esistono già nel database, verranno sovrascritti. Vuoi continuare?';

  @override
  String get exportFailed => 'Esportazione fallita';

  @override
  String get noDataToExport => 'Nessun dato disponibile da esportare';

  @override
  String get exportWarning =>
      'Stai per esportare tutti gli autenticatori negli appunti. Il contenuto esportato sarà in formato testo semplice. Assicurati che il tuo ambiente sia sicuro e svuota gli appunti in seguito. Vuoi continuare?';
}
