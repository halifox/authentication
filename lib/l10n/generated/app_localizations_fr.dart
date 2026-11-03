// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Authentication';

  @override
  String get add => 'Ajouter';

  @override
  String get scan => 'Scanner';

  @override
  String get settings => 'Paramètres';

  @override
  String get scanQRCode => 'Scanner le QR code';

  @override
  String get secret => 'Secret';

  @override
  String get algorithm => 'Algorithme';

  @override
  String get digits => 'Chiffres';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get edit => 'Modifier';

  @override
  String get ok => 'OK';

  @override
  String get codeCopied => 'Code copié';

  @override
  String get tip => 'Astuce';

  @override
  String get warning => 'Avertissement';

  @override
  String get importFailed => 'Échec de l\'importation';

  @override
  String get importSuccess => 'Importation réussie';

  @override
  String get exportSuccess => 'Exportation réussie';

  @override
  String get addSuccess => 'Ajout réussi';

  @override
  String get updateSuccess => 'Mise à jour réussie';

  @override
  String get saveFailed => 'Échec de la sauvegarde';

  @override
  String get platformNotSupported =>
      'Cette fonctionnalité n\'est actuellement prise en charge que sur les plateformes Android et iOS.';

  @override
  String get unsupportedQRCode =>
      'Ce type de QR code n\'est pas pris en charge';

  @override
  String tokenExists(String issuer, String account) {
    return 'Le jeton $issuer:$account existe déjà. Voulez-vous l\'écraser ?';
  }

  @override
  String get deleteWarning =>
      'Vous êtes sur le point de supprimer l\'authentificateur à deux facteurs actuel.\nCette action vous empêchera d\'utiliser cet authentificateur pour l\'authentification.\nVeuillez vous assurer que vous avez d\'autres méthodes d\'authentification prêtes pour assurer la sécurité de votre compte.';

  @override
  String get uploadQRCode => 'Importer QR code';

  @override
  String get enterKey => 'Entrer la clé';

  @override
  String get enterProvidedKey => 'Entrer la clé';

  @override
  String get type => 'Type';

  @override
  String get issuer => 'Émetteur';

  @override
  String get account => 'Compte';

  @override
  String get pin => 'Code PIN';

  @override
  String get period => 'Période (secondes)';

  @override
  String get counter => 'Compteur';

  @override
  String get totp => 'TOTP (Basé sur le temps)';

  @override
  String get hotp => 'HOTP (Basé sur un compteur)';

  @override
  String get motp => 'mOTP (OTP Mobile)';

  @override
  String get showCaptchaOnTap => 'Appuyer pour afficher';

  @override
  String get copyCaptchaOnTap => 'Appuyer pour copier';

  @override
  String get sha1 => 'SHA1';

  @override
  String get sha256 => 'SHA256';

  @override
  String get sha512 => 'SHA512';

  @override
  String get selectIcon => 'Sélectionner une icône';

  @override
  String get invalidSecret => 'Secret invalide';

  @override
  String get dismiss => 'Fermer';

  @override
  String get invalidScheme => 'Schéma invalide';

  @override
  String get invalidType => 'Type invalide';

  @override
  String get issuerCannotBeEmpty => 'L\'émetteur ne peut pas être vide';

  @override
  String get accountCannotBeEmpty => 'Le compte ne peut pas être vide';

  @override
  String get invalidAlgorithm => 'Algorithme invalide';

  @override
  String get invalidDigits => 'Nombre de chiffres invalide';

  @override
  String get invalidPeriod => 'Période invalide';

  @override
  String get invalidCounter => 'Compteur invalide';

  @override
  String get invalidPin => 'Code PIN invalide';

  @override
  String get invalidSecretKey => 'Clé secrète invalide';

  @override
  String get noData => 'Aucune donnée';

  @override
  String get search => 'Rechercher';

  @override
  String get exportFailed => 'Échec de l\'exportation';

  @override
  String get noDataToExport => 'Aucune donnée disponible à exporter';

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
  String get languageChoice => 'Langue';

  @override
  String get languageSystem => 'Selon le système';

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
  String get authproImport => '导入 .authpro 文件';

  @override
  String authproImportWarning(int count) {
    return '导入 $count 个账户？同名账户将更新，已有分类和元数据保留，来源分类按名称合并。空账户名使用发行方名称；来源图标和分类内顺序不会导入。';
  }

  @override
  String get authproImportError => '导入失败。请检查文件、密码及账户参数；无效、重复或不受支持的记录会导致整批拒绝。';

  @override
  String authproLegacyWarning(int count) {
    return '导入 $count 个账户？同名账户将更新，已有分类和元数据保留，来源分类按名称合并。空账户名使用发行方名称；来源图标和分类内顺序不会导入。 此旧版加密无法验证文件完整性。';
  }

  @override
  String pinLengthRequired(int count) {
    return 'PIN 必须为 $count 个字符';
  }

  @override
  String get twoFasImport => '导入 2FAS 备份';

  @override
  String twoFasImportWarning(int count) {
    return '导入 $count 个账户？同名账户将更新，已有元数据保留；分组按名称合并为分类。加密文件中的分组名称没有完整性认证。缺少账户名时使用服务名称；来源图标和显示顺序不会导入。';
  }

  @override
  String get twoFasImportError => '导入失败。请检查文件、密码和账户信息；无效、重复或不受支持的记录会导致整批拒绝。';
}
