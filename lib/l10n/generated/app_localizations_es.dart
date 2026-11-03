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
      'Accounts with the same issuer and account name will be updated. If included, categories will be merged by name, memberships for imported accounts replaced, and settings and default category restored. Continue?';

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

  @override
  String get codeGrouping => 'Code grouping';

  @override
  String get groupNone => 'No grouping';

  @override
  String groupEvery(int count) {
    return 'Every $count characters';
  }

  @override
  String get groupHalves => 'Two equal groups';

  @override
  String get groupThirds => 'Three equal groups';

  @override
  String get codeHidden => 'Code hidden';

  @override
  String get dynamicColor => 'Use system dynamic colors';

  @override
  String get themeChoice => 'Theme';

  @override
  String get themeSystem => 'Follow system';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeBlack => 'Black';

  @override
  String get themeSystemBlack => 'System with black dark mode';

  @override
  String get accentChoice => 'Accent color';

  @override
  String get accentDefault => 'Default';

  @override
  String get accentRed => 'Red';

  @override
  String get accentOrange => 'Orange';

  @override
  String get accentGreen => 'Green';

  @override
  String get accentTeal => 'Teal';

  @override
  String get accentBlue => 'Blue';

  @override
  String get accentIndigo => 'Indigo';

  @override
  String get accentPink => 'Pink';

  @override
  String get accentPriority =>
      'System dynamic colors take priority when enabled and available.';

  @override
  String get showSavedAccountQr => 'Show saved account QR code';

  @override
  String get qrSecretWarning =>
      'This QR code contains the saved account secret in plain text. Anyone who scans or photographs it can generate your codes. Show it only to a trusted device. Unsaved edits are not included. The receiving app may ignore some code settings; verify them after scanning.';

  @override
  String get qrUnsupportedAccount =>
      'QR export is available only for time-based and counter-based accounts.';

  @override
  String get qrAccountUnavailable => 'The saved account could not be loaded.';

  @override
  String get qrTooLarge =>
      'The QR code cannot be displayed at a scannable size.';

  @override
  String get qrSecretSemantics => 'QR code containing an account secret';

  @override
  String get qrUnsupportedParameters =>
      'Standard QR codes require account and issuer names without colons and a 6- or 8-digit code.';

  @override
  String get exportHtml => 'Export HTML backup';

  @override
  String get htmlBackupTitle => 'Account QR backup';

  @override
  String get htmlPlainWarning =>
      'This unencrypted HTML file contains account secrets in QR codes. Anyone with the file can generate your codes. Store it securely. It does not include categories, icons, settings or statistics, and cannot be restored as a backup file. Some apps may ignore code settings.';

  @override
  String get htmlExportFailed =>
      'The file could not be created. Check that all accounts support standard QR codes and the backup is not too large.';

  @override
  String get migrationTitle => 'Scan migration codes';

  @override
  String migrationNext(int received, int total) {
    return 'Received $received of $total codes. Continue to scan the next code, or cancel to discard this import.';
  }

  @override
  String migrationConfirm(int count) {
    return 'Import $count accounts? Accounts with the same issuer and account name will be updated; existing icons, order and copy counts will be retained.';
  }

  @override
  String migrationImported(int count) {
    return 'Imported $count accounts.';
  }

  @override
  String get migrationInvalid =>
      'The migration data is invalid, unsupported, duplicated or incomplete. No accounts were imported.';

  @override
  String get languageChoice => 'Idioma';

  @override
  String get languageSystem => 'Seguir el sistema';

  @override
  String get categories => 'Categories';

  @override
  String get categoryCreate => 'Create category';

  @override
  String get categoryRename => 'Rename category';

  @override
  String get categoryName => 'Category name';

  @override
  String get categoryOperationFailed =>
      'Could not save the category. Check its name and try again.';

  @override
  String get categoryLoadFailed => 'Could not load categories.';

  @override
  String get categoryEmpty => 'No categories yet.';

  @override
  String get categoryDefault => 'Default';

  @override
  String get categoryActions => 'Category actions';

  @override
  String get categoryClearDefault => 'Clear default';

  @override
  String get categorySetDefault => 'Set as default';

  @override
  String get categoryDelete => 'Delete category';

  @override
  String get categoryDeleteWarning =>
      'Delete this category? Accounts will remain.';

  @override
  String get assignCategories => 'Assign categories';

  @override
  String get assignAccounts => 'Assign accounts';

  @override
  String get categorySelectionEmpty => 'Nothing to select.';

  @override
  String get allCategories => 'All accounts';

  @override
  String get uncategorized => 'Uncategorized';

  @override
  String get categoryFilter => 'Filter categories';

  @override
  String get clearFilterToReorder =>
      'Show all accounts and clear search to reorder.';

  @override
  String get backupReminders => 'Backup reminders';

  @override
  String get backupReminderMessage => 'Your data has changed. Create a backup.';

  @override
  String get accountView => 'Account view';

  @override
  String get viewDefault => 'Default';

  @override
  String get viewCompact => 'Compact';

  @override
  String get viewTiles => 'Tiles';

  @override
  String get externalAccount => 'External account link';

  @override
  String get externalAccountInvalid =>
      'The link is invalid or unsupported. No account was imported.';

  @override
  String get externalAccountUnavailable =>
      'Could not receive external account links.';

  @override
  String get systemCodeFont => 'Use system font for codes';

  @override
  String get legacyImport => 'Import andOTP backup';

  @override
  String get legacyImportFormat => 'Choose backup format';

  @override
  String get legacyPlain => 'Plain JSON';

  @override
  String get legacyEncrypted => 'Encrypted backup (0.6.3 or later)';

  @override
  String get legacyEncryptedOld => 'Old encrypted backup (0.6.2 or earlier)';

  @override
  String legacyImportWarning(int count) {
    return 'Import $count accounts? Matching issuer and account names will be updated; existing icons, order, copy counts, and categories are preserved. Source categories are merged by name; source icons and usage statistics are not imported.';
  }

  @override
  String get legacyImportError =>
      'Import failed. Check the file, password, and format. Only TOTP, HOTP, and Steam accounts with an issuer and account name are supported; duplicate accounts, invalid tags, or unsupported entries reject the entire file.';

  @override
  String get revealPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get tokenListImport => 'Import FreeOTP+ backup';

  @override
  String get tokenListImportError =>
      'Import failed. Check the plain JSON file. Accounts, order, secrets, categories, and OTP parameters must be valid; duplicates, missing records, or unsupported entries reject the entire file.';

  @override
  String get vaultImport => 'Import Bitwarden JSON';

  @override
  String vaultImportWarning(int count, int skipped) {
    return 'Import $count verification accounts and skip $skipped non-login or no-code items? Matching accounts are updated, existing categories and metadata are preserved, and folders merge into categories. Passwords, notes, attachments, and other data are not imported.';
  }

  @override
  String get vaultImportError =>
      'Import failed. Choose an unencrypted JSON export and check the codes, folders, and account names. Duplicate or unsupported codes reject the entire file.';

  @override
  String get groupedImport => 'Import Aegis backup';

  @override
  String groupedImportWarning(int count) {
    return 'Import $count accounts? Matching accounts are updated; existing categories and account metadata are preserved. Source groups merge into categories; icons, notes, and favorites are not imported.';
  }

  @override
  String get groupedImportError =>
      'Import failed. Check the file, password, groups, and OTP parameters. Unsupported encryption parameters, invalid entries, or duplicates reject the entire file.';

  @override
  String get backupDecrypting => 'Decrypting backup. Please wait.';

  @override
  String get uriBackupImport => 'Import Proton Authenticator backup';

  @override
  String uriBackupImportWarning(int count) {
    return 'Import $count accounts? Matching accounts are updated and existing categories and metadata are preserved. Unnamed Steam accounts use “Steam” as their account name; source notes are not imported.';
  }

  @override
  String get uriBackupImportError =>
      'Import failed. Check the file, password, and account names. Duplicate, invalid, or unsupported records reject the entire file.';

  @override
  String get authproImport => 'Import .authpro file';

  @override
  String authproImportWarning(int count) {
    return 'Import $count accounts? Matching accounts are updated; existing categories and metadata remain. Source categories are merged. Unnamed accounts use the issuer as their name. New accounts keep supported custom images; existing account icons remain. Source built-in icons and category-specific ordering are not imported.';
  }

  @override
  String get authproImportError =>
      'Import failed. Check the file, password, and account parameters. Invalid, duplicate, or unsupported records reject the entire file.';

  @override
  String authproLegacyWarning(int count) {
    return 'Import $count accounts? Matching accounts are updated; existing categories and metadata remain. Source categories are merged. Unnamed accounts use the issuer as their name. New accounts keep supported custom images; existing account icons remain. Source built-in icons and category-specific ordering are not imported. This legacy encryption cannot verify file integrity.';
  }

  @override
  String pinLengthRequired(int count) {
    return 'PIN must contain $count characters';
  }

  @override
  String get twoFasImport => 'Import 2FAS backup';

  @override
  String twoFasImportWarning(int count) {
    return 'Import $count accounts? Matching accounts are updated and existing metadata is preserved. Groups merge into categories; group names are not authenticated in encrypted files. Missing account names use the service name. Source icons and display order are not imported.';
  }

  @override
  String get twoFasImportError =>
      'Import failed. Check the file, password, and account details. Invalid, duplicate, or unsupported entries reject the entire file.';

  @override
  String get lastPassImport => 'Import LastPass Authenticator backup';

  @override
  String lastPassImportWarning(int count) {
    return 'Import $count accounts? Matching accounts are updated; existing metadata remains. Folders merge into categories. Missing issuer or account names use the other name. Source favorites, icons and folder ordering are not imported.';
  }

  @override
  String get lastPassImportError =>
      'Import failed. Only version 3 files with supported 6–10 digit accounts can be imported. Invalid, duplicate or unsupported entries reject the entire file.';

  @override
  String get winAuthImport => 'Import WinAuth backup';

  @override
  String winAuthImportWarning(int count) {
    return 'Import $count accounts? Matching accounts are updated and existing metadata is preserved. Missing issuer or account names use the other name. Source icons and other metadata are not imported. Older ZIP encryption uses CRC and cannot authenticate file integrity.';
  }

  @override
  String get winAuthImportError =>
      'Import failed. Check the file, password and account details. Unsupported, invalid or duplicate entries reject the entire file.';

  @override
  String get totpAuthImport => 'Import TOTP Authenticator backup';

  @override
  String totpAuthImportWarning(int count) {
    return 'Import $count accounts? Matching accounts are updated and existing metadata is preserved. Missing issuer or account names use the other name. Source icons and other metadata are not imported. This older encryption cannot authenticate file integrity.';
  }

  @override
  String get totpAuthImportError =>
      'Import failed. Check the password and account details. Invalid, duplicate or unsupported records reject the entire file.';

  @override
  String get chooseCustomIcon => 'Choose image';

  @override
  String get invalidCustomIcon =>
      'Choose a valid PNG or JPEG image up to 4096 pixels per side.';

  @override
  String get backupProcessing => 'Processing backup. Please wait.';

  @override
  String get importIconPack => 'Import icon pack';

  @override
  String get iconLoadError => 'Could not load icons.';

  @override
  String iconPackImportConfirm(String name, int count) {
    return 'Import “$name” with $count icons? An existing pack with the same name will be replaced.';
  }

  @override
  String get iconPackImported => 'Icon pack imported.';

  @override
  String get iconPackError =>
      'Could not process the icon pack. Check its format and images.';

  @override
  String iconPackDeleteConfirm(String name) {
    return 'Delete “$name”? Icons already assigned to accounts will remain.';
  }

  @override
  String get freeOtpImport => 'Import FreeOTP backup';

  @override
  String freeOtpImportWarning(int count) {
    return 'Import $count accounts? Matching accounts are updated and existing metadata is preserved. Missing issuers use the account label; source icons and ordering are not imported.';
  }

  @override
  String get freeOtpImportError =>
      'Import failed. Check the password and backup. Unsupported, invalid or duplicate records reject the entire file.';

  @override
  String importAccountCounts(int newCount, int updateCount) {
    return 'New accounts: $newCount. Existing accounts to update: $updateCount.';
  }

  @override
  String get importPreviewExpired =>
      'Accounts or settings changed. Select the file again to review the updated counts.';

  @override
  String get migrationGuides => 'Migration guides';

  @override
  String get migrationGuideIntro =>
      'Follow the steps for your existing service. Keep your existing access and recovery options until the new setup works.';

  @override
  String get authyGuide =>
      'Authy does not provide token export. For each service:\n\n1. Sign in using your existing verification method.\n2. In that service’s security settings, turn off two-factor authentication and enable it again.\n3. Scan the new QR code in this app, or enter the new setup key manually.\n4. Verify a new code with the service before removing the old entry.\n\nServices may offer different recovery options. If you cannot sign in, contact that service’s support.\n\nOfficial help: https://help.twilio.com/hc/en-us/articles/19753420684059-Export-or-Import-Tokens-in-the-Authy-app-Not-Supported';

  @override
  String get steamGuide =>
      'Steam’s official transfer moves its mobile authenticator to the Steam app on a new device; it does not export its secret to this app.\n\n1. Install Steam Mobile on the new phone and sign in.\n2. On the Steam Guard screen, choose Move Authenticator and follow the confirmation steps.\n3. Store the new recovery code safely. If the old device is unavailable, follow Steam’s recovery instructions or contact Steam Support.\n\nThis app can generate Steam codes if you already have a compatible secret, but this guide does not retrieve one. Steam’s official transfer may impose temporary trading restrictions.\n\nOfficial help: https://help.steampowered.com/en/faqs/view/29A9-9EEE-09F0-75F9';

  @override
  String get blizzardGuide =>
      'Blizzard account authentication is managed through its official mobile app. This guide does not extract or import its secret.\n\n1. Keep your existing authenticator and recovery information available.\n2. On the new device, sign in to the official app and follow its authenticator setup or recovery prompts.\n3. If you cannot approve the sign-in or restore access, use Blizzard Support’s account recovery process before removing the old authenticator.\n\nCheck the provider’s current instructions before making changes: https://us.support.blizzard.com/';

  @override
  String get userGuide => 'Using the app';

  @override
  String get guideAddTitle => 'Add an account';

  @override
  String get guideAddBody =>
      'Choose Add to scan a setup QR code, select a supported image, or enter the setup key. Verify a code with the service before removing your previous method.';

  @override
  String get guideCodesTitle => 'Use your codes';

  @override
  String get guideCodesBody =>
      'Enter the current code at the service. Time-based codes change automatically; counter-based codes can be advanced manually. Search, categories, and sorting help organize accounts.';

  @override
  String get guideBackupTitle => 'Keep a backup';

  @override
  String get guideBackupBody =>
      'Export a password-protected backup and store it safely. Test recovery before replacing your device. Unencrypted exports and QR codes reveal account secrets.';

  @override
  String get guideMigrationTitle => 'Move existing accounts';

  @override
  String get guideMigrationBody =>
      'Choose Add to import a supported file or follow the migration guides. Imports show a confirmation and conflict policy before saving.';

  @override
  String get welcomeTitle => 'Welcome';

  @override
  String get welcomeIntro =>
      'Set up verification codes, keep a protected backup, and retain recovery options for your accounts.';

  @override
  String get getStarted => 'Get started';

  @override
  String get aboutApp => 'About';

  @override
  String get aboutDescription =>
      'An offline app for managing verification codes.';

  @override
  String get sourceCode => 'Source code';

  @override
  String get openSourceLicenses => 'Open-source licenses';

  @override
  String get aboutPrivacy =>
      'Account secrets are encrypted on this device. Exported files and QR codes may reveal them.';

  @override
  String get googleGuide =>
      'On the old device, open Google Authenticator, choose the menu, then Transfer codes (or Transfer accounts) and Export. Unlock the device, select the accounts, and continue to display the QR code.\n\nIn this app, return to Add and choose Scan QR code. Scan every code from the same export; this app asks for confirmation after the complete batch is received. Check the import summary and verify codes with the services before removing the old setup.\n\nThe QR codes contain account secrets. Keep them private. Camera support varies by platform; unsupported or incomplete batches are not imported. If the old device is unavailable, use each service’s recovery options.\n\nOfficial help: https://support.google.com/accounts/answer/1066447';

  @override
  String get automaticBackup => 'Automatic backup';

  @override
  String get autoBackupIntro =>
      'Choose a local storage folder and a backup password. The app saves a new encrypted file after changes while it is running. Keep the password separately; losing it prevents recovery. Old files are not deleted and keep their original password.';

  @override
  String get autoBackupUnsupported =>
      'Automatic backup is not available on this platform.';

  @override
  String get autoBackupDisabled => 'Automatic backup is off.';

  @override
  String get autoBackupReady => 'Automatic backup is enabled.';

  @override
  String get autoBackupSaving => 'Saving an encrypted backup…';

  @override
  String get autoBackupFailed =>
      'Automatic backup failed. Check storage permission and try again or choose the folder again.';

  @override
  String get autoBackupConfigure => 'Choose folder and enable';

  @override
  String get autoBackupRetry => 'Back up now';

  @override
  String get autoBackupDisable => 'Turn off';

  @override
  String get autoBackupLocalOnly =>
      'Choose a local device storage folder, not a cloud provider.';

  @override
  String get autoBackupSaved => 'Encrypted backup saved and verified.';
}
