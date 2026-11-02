// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Authentication';

  @override
  String get add => 'Añadir';

  @override
  String get scan => 'Escanear';

  @override
  String get settings => 'Configuración';

  @override
  String get scanQRCode => 'Escanear código QR';

  @override
  String get secret => 'Secreto';

  @override
  String get algorithm => 'Algoritmo';

  @override
  String get digits => 'Dígitos';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get edit => 'Editar';

  @override
  String get ok => 'Aceptar';

  @override
  String get codeCopied => 'Código copiado';

  @override
  String get tip => 'Consejo';

  @override
  String get warning => 'Advertencia';

  @override
  String get importFailed => 'Importación fallida';

  @override
  String get importSuccess => 'Importación exitosa';

  @override
  String get exportSuccess => 'Exportación exitosa';

  @override
  String get addSuccess => 'Añadido con éxito';

  @override
  String get updateSuccess => 'Actualización exitosa';

  @override
  String get saveFailed => 'Error al guardar';

  @override
  String get platformNotSupported =>
      'Esta función actualmente solo es compatible con plataformas Android e iOS.';

  @override
  String get unsupportedQRCode => 'Este tipo de código QR no es compatible';

  @override
  String tokenExists(String issuer, String account) {
    return 'El token $issuer:$account ya existe. ¿Desea sobrescribirlo?';
  }

  @override
  String get deleteWarning =>
      'Está a punto de eliminar el autenticador de dos factores actual.\nEsta acción le impedirá usar este autenticador para la autenticación.\nPor favor, asegúrese de tener otros métodos de autenticación listos para garantizar la seguridad de la cuenta.';

  @override
  String get uploadQRCode => 'Importar código QR';

  @override
  String get enterKey => 'Ingresar clave';

  @override
  String get enterProvidedKey => 'Ingresar clave';

  @override
  String get type => 'Tipo';

  @override
  String get issuer => 'Emisor';

  @override
  String get account => 'Cuenta';

  @override
  String get pin => 'Código PIN';

  @override
  String get period => 'Período (segundos)';

  @override
  String get counter => 'Contador';

  @override
  String get totp => 'TOTP (Basado en tiempo)';

  @override
  String get hotp => 'HOTP (Basado en contador)';

  @override
  String get motp => 'mOTP (OTP Móvil)';

  @override
  String get showCaptchaOnTap => 'Tocar para mostrar';

  @override
  String get copyCaptchaOnTap => 'Tocar para copiar';

  @override
  String get sha1 => 'SHA1';

  @override
  String get sha256 => 'SHA256';

  @override
  String get sha512 => 'SHA512';

  @override
  String get selectIcon => 'Seleccionar icono';

  @override
  String get invalidSecret => 'Secreto inválido';

  @override
  String get dismiss => 'Cerrar';

  @override
  String get invalidScheme => 'Esquema inválido';

  @override
  String get invalidType => 'Tipo inválido';

  @override
  String get issuerCannotBeEmpty => 'El emisor no puede estar vacío';

  @override
  String get accountCannotBeEmpty => 'La cuenta no puede estar vacía';

  @override
  String get invalidAlgorithm => 'Algoritmo inválido';

  @override
  String get invalidDigits => 'Número de dígitos inválido';

  @override
  String get invalidPeriod => 'Período inválido';

  @override
  String get invalidCounter => 'Contador inválido';

  @override
  String get invalidPin => 'Código PIN inválido';

  @override
  String get invalidSecretKey => 'Clave secreta inválida';

  @override
  String get noData => 'Sin datos';

  @override
  String get search => 'Buscar';

  @override
  String get exportFailed => 'Error al exportar';

  @override
  String get noDataToExport => 'No hay datos disponibles para exportar';

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

  @override
  String get showAccountName => 'Show account name';

  @override
  String get hideCodeAfter => 'Automatically hide revealed codes';

  @override
  String get never => 'Never';

  @override
  String seconds(int count) {
    return '$count seconds';
  }

  @override
  String get advanceHotpOnCopy => 'Advance HOTP after copying';

  @override
  String get resetCopyCount => 'Reset copy count';

  @override
  String get resetCopyCountWarning => 'Reset this account’s copy count?';

  @override
  String copyCount(int count) {
    return 'Copies: $count';
  }

  @override
  String get copyFailed => 'Could not copy the code.';

  @override
  String get copyRecordFailed =>
      'Code copied, but the count or HOTP counter could not be updated. Check the account before copying again.';

  @override
  String get sortAccounts => 'Sort accounts';

  @override
  String get sortCustom => 'Custom order';

  @override
  String get sortNameAscending => 'Name A–Z';

  @override
  String get sortNameDescending => 'Name Z–A';

  @override
  String get sortCopiesAscending => 'Fewest copies';

  @override
  String get sortCopiesDescending => 'Most copies';

  @override
  String get lockSorting => 'Lock custom order';

  @override
  String get unlockSorting => 'Unlock custom order';

  @override
  String get clearSearchToReorder => 'Clear the search to reorder accounts.';

  @override
  String get reorderFailed => 'Could not reorder accounts. Try again.';

  @override
  String get dragToReorder => 'Drag to reorder';
}
