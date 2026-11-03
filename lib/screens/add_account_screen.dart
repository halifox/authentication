import 'package:authentication/actions/qr_actions.dart';

import 'package:authentication/backup/authpro_import.dart';
import 'package:authentication/backup/backup.dart';
import 'package:authentication/backup/backup_provider.dart';
import 'package:authentication/backup/freeotp_import.dart';
import 'package:authentication/backup/grouped_import.dart';
import 'package:authentication/backup/lastpass_import.dart';
import 'package:authentication/backup/legacy_import.dart';
import 'package:authentication/backup/totp_auth_import.dart';
import 'package:authentication/backup/twofas_import.dart';
import 'package:authentication/backup/uri_backup_import.dart';
import 'package:authentication/backup/winauth_import.dart';
import 'package:authentication/l10n/generated/app_localizations.dart';
import 'package:authentication/otp/migration.dart';
import 'package:authentication/otp/otp_provider.dart';
import 'package:authentication/router/app_router.dart';
import 'package:authentication/screens/auth_error_localization.dart';
import 'package:authentication/widgets/action_result_sheet.dart';
import 'package:authentication/widgets/custom_app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// 添加方式选项的模型类。
class AddMethodOption {
  /// 创建一个添加方式选项。
  /// [icon] 选项显示的图标。
  /// [label] 选项显示的文字标签。
  /// [onTap] 点击该选项时触发的回调函数。
  AddMethodOption(this.icon, this.label, this.onTap);

  /// 图标数据
  final IconData icon;

  /// 标签文字
  final String label;

  /// 点击回调
  final VoidCallback onTap;
}

/// 添加账号页面，提供多种添加 2FA 令牌的方式（扫码、上传图片、手动输入等）。
class AddAccountScreen extends ConsumerWidget {
  /// 创建添加账号页面。
  const AddAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final busy =
        ref.watch(accountOperationsProvider).isLoading ||
        ref.watch(backupOperationsProvider).isLoading;

    final List<AddMethodOption> options = [
      AddMethodOption(
        Icons.camera_enhance,
        l10n.scanQRCode,
        () => _handleScan(context, ref),
      ),
      AddMethodOption(
        Icons.photo_library,
        l10n.uploadQRCode,
        () => _handleUpload(context, ref),
      ),
      AddMethodOption(
        Icons.help_outline,
        l10n.migrationGuides,
        () => Navigator.pushNamed(context, AppRoutes.migrationGuides),
      ),
      AddMethodOption(
        Icons.keyboard,
        l10n.enterKey,
        () => Navigator.pushNamed(context, AppRoutes.form),
      ),
      AddMethodOption(
        Icons.file_upload_outlined,
        l10n.importFile,
        () => _handleRestore(context, ref),
      ),
      AddMethodOption(
        Icons.file_download_outlined,
        l10n.exportFile,
        () => _handleBackup(context, ref),
      ),
      AddMethodOption(
        Icons.playlist_add,
        l10n.importUriList,
        () => _handleUriImport(context, ref),
      ),
      AddMethodOption(
        Icons.file_open,
        l10n.legacyImport,
        () => _handleLegacyImport(context, ref),
      ),
      AddMethodOption(
        Icons.file_open_outlined,
        l10n.tokenListImport,
        () => _handleTokenListImport(context, ref),
      ),
      AddMethodOption(
        Icons.file_open_outlined,
        l10n.vaultImport,
        () => _handleVaultImport(context, ref),
      ),
      AddMethodOption(
        Icons.file_open_outlined,
        l10n.groupedImport,
        () => _handleGroupedImport(context, ref),
      ),
      AddMethodOption(
        Icons.file_open_outlined,
        l10n.uriBackupImport,
        () => _handleUriBackupImport(context, ref),
      ),
      AddMethodOption(
        Icons.file_open_outlined,
        l10n.freeOtpImport,
        () => _handleFreeOtpImport(context, ref),
      ),
      AddMethodOption(
        Icons.file_open_outlined,
        l10n.totpAuthImport,
        () => _handleTotpAuthImport(context, ref),
      ),
      AddMethodOption(
        Icons.file_open_outlined,
        l10n.winAuthImport,
        () => _handleWinAuthImport(context, ref),
      ),
      AddMethodOption(
        Icons.file_open_outlined,
        l10n.lastPassImport,
        () => _handleLastPassImport(context, ref),
      ),
      AddMethodOption(
        Icons.file_open_outlined,
        l10n.twoFasImport,
        () => _handleTwoFasImport(context, ref),
      ),
      AddMethodOption(
        Icons.file_open_outlined,
        l10n.authproImport,
        () => _handleAuthproImport(context, ref),
      ),
      AddMethodOption(
        Icons.list_alt,
        l10n.exportUriList,
        () => _handleUriExport(context, ref),
      ),
      AddMethodOption(
        Icons.html,
        l10n.exportHtml,
        () => _handleHtmlExport(context, ref),
      ),
    ];

    return Scaffold(
      appBar: CustomAppBar(title: l10n.add),
      body: GridView.builder(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 700,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          mainAxisExtent: 90,
        ),
        itemCount: options.length,
        itemBuilder: (BuildContext context, int index) {
          final AddMethodOption option = options[index];
          return AddMethodTile(
            option.icon,
            option.label,
            busy ? null : option.onTap,
          );
        },
      ),
    );
  }

  Future<String?> _scanNext(BuildContext context) async {
    final capture = await Navigator.pushNamed<BarcodeCapture>(
      context,
      AppRoutes.scan,
    );
    if (capture == null || capture.barcodes.isEmpty) return null;
    return capture.barcodes.first.rawValue;
  }

  Future<String?> _uploadNext(BuildContext context) async {
    final file = await pickQrImage();
    if (file == null) return null;
    final codes = await analyzeQrFile(file.xFile.path);
    if (codes.isNotEmpty) return codes.first;
    if (context.mounted) {
      await _showResult(
        context,
        0,
        AppLocalizations.of(context)!.tip,
        AppLocalizations.of(context)!.unsupportedQRCode,
      );
    }
    return null;
  }

  Future<void> _handleScan(BuildContext context, WidgetRef ref) async {
    if (!ref.read(qrPlatformSupportedProvider)) {
      await _showNotSupported(context);
      return;
    }
    final code = await _scanNext(context);
    if (code != null && context.mounted) {
      await _processQrCode(context, ref, code, next: () => _scanNext(context));
    }
  }

  Future<void> _handleUpload(BuildContext context, WidgetRef ref) async {
    if (kIsWeb || !ref.read(qrPlatformSupportedProvider)) {
      await _showNotSupported(context);
      return;
    }
    try {
      final code = await _uploadNext(context);
      if (code != null && context.mounted) {
        await _processQrCode(
          context,
          ref,
          code,
          next: () => _uploadNext(context),
        );
      }
    } catch (_) {
      if (context.mounted) {
        await _showResult(
          context,
          0,
          AppLocalizations.of(context)!.tip,
          AppLocalizations.of(context)!.unsupportedQRCode,
        );
      }
    }
  }

  Future<void> _handleMigration(
    BuildContext context,
    WidgetRef ref,
    String code,
    Future<String?> Function()? next,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final collector = MigrationCollector();
    try {
      collector.add(parseMigrationUri(code));
      while (!collector.complete) {
        if (next == null || !context.mounted) return;
        final proceed = await showCupertinoModalPopup<bool>(
          context: context,
          builder: (_) => ActionResultSheet(
            state: 0,
            title: l10n.migrationTitle,
            message: l10n.migrationNext(collector.received, collector.size),
            falseButtonVisible: true,
          ),
        );
        if (proceed != true || !context.mounted) return;
        final nextCode = await next();
        if (nextCode == null || !context.mounted) return;
        collector.add(parseMigrationUri(nextCode));
      }
      final accounts = collector.finish();
      if (!context.mounted) return;
      final preview = await ref
          .read(backupOperationsProvider.notifier)
          .previewAccounts(accounts);
      if (!context.mounted) return;
      final proceed = await showCupertinoModalPopup<bool>(
        context: context,
        builder: (_) => ActionResultSheet(
          state: 0,
          title: l10n.warning,
          message:
              '${l10n.migrationConfirm(accounts.length)}\n\n'
              '${l10n.importAccountCounts(preview.newCount, preview.updateCount)}',
          falseButtonVisible: true,
        ),
      );
      if (proceed != true || !context.mounted) return;
      final count = await ref
          .read(accountOperationsProvider.notifier)
          .importMigration(accounts, expectedRevision: preview.revision);
      if (context.mounted) {
        await _showResult(
          context,
          1,
          l10n.importSuccess,
          l10n.migrationImported(count),
        );
        if (context.mounted) Navigator.pop(context);
      }
    } on ImportPreviewExpired {
      if (context.mounted) {
        await _showResult(
          context,
          0,
          l10n.importFailed,
          l10n.importPreviewExpired,
        );
      }
    } catch (_) {
      if (context.mounted) {
        await _showResult(context, 0, l10n.importFailed, l10n.migrationInvalid);
      }
    }
  }

  Future<void> _processQrCode(
    BuildContext context,
    WidgetRef ref,
    String code, {
    bool forceUpdate = false,
    Future<String?> Function()? next,
  }) async {
    if (Uri.tryParse(code)?.scheme.toLowerCase() == 'otpauth-migration') {
      await _handleMigration(context, ref, code, next);
      return;
    }
    final uri = Uri.tryParse(code);
    if (uri?.scheme.toLowerCase() == 'otpauth' &&
        uri?.host.toLowerCase() == 'yaotp') {
      await Navigator.push(context, externalAccountRoute(code));
      return;
    }
    final result = await ref
        .read(accountOperationsProvider.notifier)
        .scan(code, forceUpdate: forceUpdate);

    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context)!;

    if (result is QrProcessSuccess) {
      if (context.mounted) {
        await _showResult(context, 1, l10n.tip, l10n.addSuccess);
        if (context.mounted) Navigator.pop(context);
      }
    } else if (result is QrProcessConflict) {
      if (context.mounted) {
        final confirm = await showCupertinoModalPopup<bool>(
          context: context,
          builder: (ctx) => ActionResultSheet(
            state: 0,
            title: l10n.warning,
            message: l10n.tokenExists(
              result.pending.issuer,
              result.pending.account,
            ),
            falseButtonVisible: true,
          ),
        );
        if (confirm == true && context.mounted) {
          await _processQrCode(context, ref, code, forceUpdate: true);
        }
      }
    } else if (result is QrProcessError) {
      if (context.mounted) {
        await _showResult(
          context,
          0,
          l10n.tip,
          result.code.getLocalizedMessage(context),
        );
      }
    }
  }

  Future<String?> _passwordDialog(
    BuildContext context, {
    required bool export,
  }) async {
    return showDialog<String>(
      context: context,
      builder: (_) => _BackupPasswordDialog(export: export),
    );
  }

  Future<void> _handleRestore(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final bytes = await ref
          .read(backupOperationsProvider.notifier)
          .pickFile();
      if (bytes == null || !context.mounted) return;
      if (!context.mounted) return;
      String? password;
      if (Backup.isEncrypted(bytes)) {
        password = await _passwordDialog(context, export: false);
        if (password == null || !context.mounted) return;
      }
      final document = password == null
          ? await decodeBackupDocument(bytes, null)
          : await _decryptWithProgress(
              context,
              () => decodeBackupDocument(bytes, password),
            );
      if (!context.mounted) return;
      final preview = await ref
          .read(backupOperationsProvider.notifier)
          .previewAccounts(document.accounts);
      if (!context.mounted) return;
      final proceed = await showCupertinoModalPopup<bool>(
        context: context,
        builder: (_) => ActionResultSheet(
          state: 0,
          title: l10n.warning,
          message:
              '${l10n.backupSettingsWarning}\n\n'
              '${l10n.importAccountCounts(preview.newCount, preview.updateCount)}',
          falseButtonVisible: true,
        ),
      );
      if (proceed != true || !context.mounted) return;
      await ref
          .read(backupOperationsProvider.notifier)
          .importDocument(document, expectedRevision: preview.revision);
      if (context.mounted) {
        await _showResult(context, 1, l10n.importSuccess, l10n.backupImported);
      }
    } on ImportPreviewExpired {
      if (context.mounted) {
        await _showResult(
          context,
          0,
          l10n.importFailed,
          l10n.importPreviewExpired,
        );
      }
    } catch (_) {
      if (context.mounted) {
        await _showResult(context, 0, l10n.importFailed, l10n.backupFileError);
      }
    }
  }

  Future<void> _handleBackup(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final password = await _passwordDialog(context, export: true);
    if (password == null || !context.mounted) return;
    try {
      final saved = await ref
          .read(backupOperationsProvider.notifier)
          .exportFile(password.isEmpty ? null : password);
      if (context.mounted && saved) {
        await _showResult(
          context,
          1,
          l10n.exportSuccess,
          kIsWeb ? l10n.backupDownloadStarted : l10n.backupSaved,
        );
      }
    } catch (_) {
      if (context.mounted) {
        await _showResult(context, 0, l10n.exportFailed, l10n.exportFailed);
      }
    }
  }

  Future<void> _handleLegacyImport(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final format = await showDialog<LegacyBackupFormat>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(l10n.legacyImportFormat),
        children: [
          for (final choice in [
            (LegacyBackupFormat.plain, l10n.legacyPlain),
            (LegacyBackupFormat.encrypted, l10n.legacyEncrypted),
            (LegacyBackupFormat.encryptedOld, l10n.legacyEncryptedOld),
          ])
            SimpleDialogOption(
              onPressed: () => Navigator.pop(dialogContext, choice.$1),
              child: Text(choice.$2),
            ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
    if (format == null || !context.mounted) return;
    try {
      final bytes = await ref
          .read(backupOperationsProvider.notifier)
          .pickFile();
      if (bytes == null || !context.mounted) return;
      String? password;
      if (format != LegacyBackupFormat.plain) {
        password = await _passwordDialog(context, export: false);
        if (password == null || !context.mounted) return;
      }
      final plaintext = format == LegacyBackupFormat.plain
          ? await decryptLegacyBackup(bytes, format)
          : await _decryptWithProgress(
              context,
              () => decryptLegacyBackup(bytes, format, password: password),
            );
      final document = parseLegacyBackup(plaintext);
      if (!context.mounted) return;
      await _confirmImportedAccounts(context, ref, document);
    } catch (_) {
      if (context.mounted) {
        await _showResult(
          context,
          0,
          l10n.importFailed,
          l10n.legacyImportError,
        );
      }
    }
  }

  Future<void> _handleTokenListImport(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final bytes = await ref
          .read(backupOperationsProvider.notifier)
          .pickFile();
      if (bytes == null || !context.mounted) return;
      final document = parseTokenListBackup(bytes);
      await _confirmImportedAccounts(context, ref, document);
    } catch (_) {
      if (context.mounted) {
        await _showResult(
          context,
          0,
          l10n.importFailed,
          l10n.tokenListImportError,
        );
      }
    }
  }

  Future<void> _handleUriBackupImport(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final bytes = await ref
          .read(backupOperationsProvider.notifier)
          .pickFile();
      if (bytes == null || !context.mounted) return;
      String? password;
      if (isUriBackupEncrypted(bytes)) {
        password = await _passwordDialog(context, export: false);
        if (password == null || !context.mounted) return;
      }
      final plaintext = password == null
          ? await decryptUriBackup(bytes)
          : await _decryptWithProgress(
              context,
              () => decryptUriBackup(bytes, password: password),
            );
      final document = parseUriBackup(plaintext);
      if (!context.mounted) return;
      await _confirmImportedAccounts(
        context,
        ref,
        document,
        warning: l10n.uriBackupImportWarning(document.accounts.length),
      );
    } catch (_) {
      if (context.mounted) {
        await _showResult(
          context,
          0,
          l10n.importFailed,
          l10n.uriBackupImportError,
        );
      }
    }
  }

  Future<void> _handleGroupedImport(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final bytes = await ref
          .read(backupOperationsProvider.notifier)
          .pickFile();
      if (bytes == null || !context.mounted) return;
      String? password;
      if (isGroupedBackupEncrypted(bytes)) {
        password = await _passwordDialog(context, export: false);
        if (password == null || !context.mounted) return;
      }
      final document = await _decryptWithProgress(
        context,
        () => parseGroupedBackupAsync(bytes, password: password),
        message: l10n.backupProcessing,
      );
      if (!context.mounted) return;
      await _confirmImportedAccounts(
        context,
        ref,
        document,
        warning: l10n.groupedImportWarning(document.accounts.length),
      );
    } catch (_) {
      if (context.mounted) {
        await _showResult(
          context,
          0,
          l10n.importFailed,
          l10n.groupedImportError,
        );
      }
    }
  }

  Future<void> _handleFreeOtpImport(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final bytes = await ref
          .read(backupOperationsProvider.notifier)
          .pickFile();
      if (bytes == null || !context.mounted) return;
      final password = await _passwordDialog(context, export: false);
      if (password == null || !context.mounted) return;
      final document = await _decryptWithProgress(
        context,
        () => parseFreeOtpBackup(bytes, password),
      );
      if (!context.mounted) return;
      await _confirmImportedAccounts(
        context,
        ref,
        document,
        warning: l10n.freeOtpImportWarning(document.accounts.length),
      );
    } catch (_) {
      if (context.mounted) {
        await _showResult(
          context,
          0,
          l10n.importFailed,
          l10n.freeOtpImportError,
        );
      }
    }
  }

  Future<void> _handleTotpAuthImport(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final bytes = await ref
          .read(backupOperationsProvider.notifier)
          .pickFile();
      if (bytes == null || !context.mounted) return;
      final password = await _passwordDialog(context, export: false);
      if (password == null || !context.mounted) return;
      final document = parseTotpAuthBackup(bytes, password);
      await _confirmImportedAccounts(
        context,
        ref,
        document,
        warning: l10n.totpAuthImportWarning(document.accounts.length),
      );
    } catch (_) {
      if (context.mounted) {
        await _showResult(
          context,
          0,
          l10n.importFailed,
          l10n.totpAuthImportError,
        );
      }
    }
  }

  Future<void> _handleWinAuthImport(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final bytes = await ref
          .read(backupOperationsProvider.notifier)
          .pickFile();
      if (bytes == null || !context.mounted) return;
      String? password;
      if (isWinAuthZip(bytes)) {
        password = await _passwordDialog(context, export: false);
        if (password == null || !context.mounted) return;
      }
      final document = password == null
          ? parseWinAuthBackup(bytes)
          : await _decryptWithProgress(
              context,
              () => parseWinAuthBackupAsync(bytes, password: password),
            );
      if (!context.mounted) return;
      await _confirmImportedAccounts(
        context,
        ref,
        document,
        warning: l10n.winAuthImportWarning(document.accounts.length),
      );
    } catch (_) {
      if (context.mounted) {
        await _showResult(
          context,
          0,
          l10n.importFailed,
          l10n.winAuthImportError,
        );
      }
    }
  }

  Future<void> _handleLastPassImport(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final bytes = await ref
          .read(backupOperationsProvider.notifier)
          .pickFile();
      if (bytes == null || !context.mounted) return;
      final document = parseLastPassBackup(bytes);
      await _confirmImportedAccounts(
        context,
        ref,
        document,
        warning: l10n.lastPassImportWarning(document.accounts.length),
      );
    } catch (_) {
      if (context.mounted) {
        await _showResult(
          context,
          0,
          l10n.importFailed,
          l10n.lastPassImportError,
        );
      }
    }
  }

  Future<void> _handleTwoFasImport(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final bytes = await ref
          .read(backupOperationsProvider.notifier)
          .pickFile();
      if (bytes == null || !context.mounted) return;
      final encrypted = isTwoFasEncrypted(bytes);
      String? password;
      if (encrypted) {
        password = await _passwordDialog(context, export: false);
        if (password == null || !context.mounted) return;
      }
      final document = password == null
          ? await parseTwoFasBackup(bytes)
          : await _decryptWithProgress(
              context,
              () => parseTwoFasBackup(bytes, password: password),
            );
      if (!context.mounted) return;
      await _confirmImportedAccounts(
        context,
        ref,
        document,
        warning: l10n.twoFasImportWarning(document.accounts.length),
      );
    } catch (_) {
      if (context.mounted) {
        await _showResult(
          context,
          0,
          l10n.importFailed,
          l10n.twoFasImportError,
        );
      }
    }
  }

  Future<void> _handleAuthproImport(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final bytes = await ref
          .read(backupOperationsProvider.notifier)
          .pickFile();
      if (bytes == null || !context.mounted) return;
      final kind = authproEncryption(bytes);
      String? password;
      if (kind != AuthproEncryption.none) {
        password = await _passwordDialog(context, export: false);
        if (password == null || !context.mounted) return;
      }
      final document = await _decryptWithProgress(context, () async {
        final plaintext = password == null
            ? bytes
            : await decryptAuthpro(bytes, password: password);
        return compute(parseAuthpro, plaintext);
      }, message: l10n.backupProcessing);
      if (!context.mounted) return;
      await _confirmImportedAccounts(
        context,
        ref,
        document,
        warning: kind == AuthproEncryption.legacy
            ? l10n.authproLegacyWarning(document.accounts.length)
            : l10n.authproImportWarning(document.accounts.length),
      );
    } catch (_) {
      if (context.mounted) {
        await _showResult(
          context,
          0,
          l10n.importFailed,
          l10n.authproImportError,
        );
      }
    }
  }

  Future<void> _handleVaultImport(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final bytes = await ref
          .read(backupOperationsProvider.notifier)
          .pickFile();
      if (bytes == null || !context.mounted) return;
      final result = parseVaultBackup(bytes);
      await _confirmImportedAccounts(
        context,
        ref,
        result.document,
        warning: l10n.vaultImportWarning(
          result.document.accounts.length,
          result.skipped,
        ),
      );
    } catch (_) {
      if (context.mounted) {
        await _showResult(context, 0, l10n.importFailed, l10n.vaultImportError);
      }
    }
  }

  Future<void> _confirmImportedAccounts(
    BuildContext context,
    WidgetRef ref,
    LegacyImport document, {
    String? warning,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final preview = await ref
        .read(backupOperationsProvider.notifier)
        .previewLegacyImport(document);
    if (!context.mounted) return;
    final proceed = await showCupertinoModalPopup<bool>(
      context: context,
      builder: (_) => ActionResultSheet(
        state: 0,
        title: l10n.warning,
        message:
            '${warning ?? l10n.legacyImportWarning(document.accounts.length)}\n\n'
            '${l10n.importAccountCounts(preview.newCount, preview.updateCount)}',
        falseButtonVisible: true,
      ),
    );
    if (proceed != true || !context.mounted) return;
    late final int count;
    try {
      count = await ref
          .read(backupOperationsProvider.notifier)
          .importLegacyAccounts(document, expectedRevision: preview.revision);
    } on ImportPreviewExpired {
      if (context.mounted) {
        await _showResult(
          context,
          0,
          l10n.importFailed,
          l10n.importPreviewExpired,
        );
      }
      return;
    }
    if (context.mounted) {
      await _showResult(
        context,
        1,
        l10n.importSuccess,
        l10n.migrationImported(count),
      );
    }
  }

  Future<T> _decryptWithProgress<T>(
    BuildContext context,
    Future<T> Function() action, {
    String? message,
  }) async {
    final navigator = Navigator.of(context);
    final l10n = AppLocalizations.of(context)!;
    final route = DialogRoute<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Expanded(child: Text(message ?? l10n.backupDecrypting)),
            ],
          ),
        ),
      ),
    );
    navigator.push(route);
    await WidgetsBinding.instance.endOfFrame;
    try {
      return await action();
    } finally {
      if (navigator.mounted && route.isActive) navigator.removeRoute(route);
    }
  }

  Future<void> _handleUriImport(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final bytes = await ref
          .read(backupOperationsProvider.notifier)
          .pickFile();
      if (bytes == null || !context.mounted) return;
      // Validate the complete file before presenting the conflict policy.
      final accounts = decodeUriList(bytes);
      final preview = await ref
          .read(backupOperationsProvider.notifier)
          .previewAccounts(accounts);
      if (!context.mounted) return;
      final proceed = await showCupertinoModalPopup<bool>(
        context: context,
        builder: (_) => ActionResultSheet(
          state: 0,
          title: l10n.warning,
          message:
              '${l10n.backupReplaceWarning}\n\n'
              '${l10n.importAccountCounts(preview.newCount, preview.updateCount)}',
          falseButtonVisible: true,
        ),
      );
      if (proceed != true || !context.mounted) return;
      await ref
          .read(backupOperationsProvider.notifier)
          .importUriFile(bytes, expectedRevision: preview.revision);
      if (context.mounted) {
        await _showResult(context, 1, l10n.importSuccess, l10n.backupImported);
      }
    } on ImportPreviewExpired {
      if (context.mounted) {
        await _showResult(
          context,
          0,
          l10n.importFailed,
          l10n.importPreviewExpired,
        );
      }
    } catch (_) {
      if (context.mounted) {
        await _showResult(context, 0, l10n.importFailed, l10n.backupFileError);
      }
    }
  }

  Future<void> _handleUriExport(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final proceed = await showCupertinoModalPopup<bool>(
      context: context,
      builder: (_) => ActionResultSheet(
        state: 0,
        title: l10n.warning,
        message: l10n.uriPlainWarning,
        falseButtonVisible: true,
      ),
    );
    if (proceed != true || !context.mounted) return;
    try {
      final saved = await ref
          .read(backupOperationsProvider.notifier)
          .exportUriFile();
      if (context.mounted && saved) {
        await _showResult(
          context,
          1,
          l10n.exportSuccess,
          kIsWeb ? l10n.backupDownloadStarted : l10n.backupSaved,
        );
      }
    } catch (_) {
      if (context.mounted) {
        await _showResult(context, 0, l10n.exportFailed, l10n.exportFailed);
      }
    }
  }

  Future<void> _handleHtmlExport(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final proceed = await showCupertinoModalPopup<bool>(
      context: context,
      builder: (_) => ActionResultSheet(
        state: 0,
        title: l10n.warning,
        message: l10n.htmlPlainWarning,
        falseButtonVisible: true,
      ),
    );
    if (proceed != true || !context.mounted) return;
    try {
      final saved = await ref
          .read(backupOperationsProvider.notifier)
          .exportHtmlFile(
            title: l10n.htmlBackupTitle,
            warning: l10n.htmlPlainWarning,
          );
      if (context.mounted && saved) {
        await _showResult(
          context,
          1,
          l10n.exportSuccess,
          kIsWeb ? l10n.backupDownloadStarted : l10n.backupSaved,
        );
      }
    } catch (_) {
      if (context.mounted) {
        await _showResult(context, 0, l10n.exportFailed, l10n.htmlExportFailed);
      }
    }
  }

  Future<void> _showResult(
    BuildContext context,
    int state,
    String title,
    String message,
  ) async {
    return await showCupertinoModalPopup(
      context: context,
      builder: (ctx) =>
          ActionResultSheet(state: state, title: title, message: message),
    );
  }

  Future<void> _showNotSupported(BuildContext context) async {
    await _showResult(
      context,
      0,
      AppLocalizations.of(context)!.tip,
      AppLocalizations.of(context)!.platformNotSupported,
    );
  }
}

/// 添加方式的列表项组件。
class AddMethodTile extends StatelessWidget {
  /// 创建一个添加方式的列表项。
  /// [icon] 图标。
  /// [label] 文字。
  /// [onTap] 点击回调。
  const AddMethodTile(this.icon, this.label, this.onTap, {super.key});

  /// 图标数据
  final IconData icon;

  /// 标签文字
  final String label;

  /// 点击回调
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: const BorderRadius.all(Radius.circular(24)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 48,
            width: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
            child: Icon(
              icon,
              size: 24,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                height: 0,
                fontSize: 18,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    ),
  );
}

class _BackupPasswordDialog extends HookWidget {
  const _BackupPasswordDialog({required this.export});
  final bool export;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final password = useTextEditingController();
    final confirmation = useTextEditingController();
    final obscured = useState(true);
    useListenable(password);
    useListenable(confirmation);
    final mismatch = export && password.text != confirmation.text;
    return AlertDialog(
      title: Text(l10n.backupPasswordTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: password,
            obscureText: obscured.value,
            decoration: InputDecoration(
              labelText: export
                  ? l10n.backupPasswordHint
                  : l10n.backupPasswordRequired,
              suffixIcon: IconButton(
                tooltip: obscured.value
                    ? l10n.revealPassword
                    : l10n.hidePassword,
                onPressed: () => obscured.value = !obscured.value,
                icon: Icon(
                  obscured.value ? Icons.visibility_off : Icons.visibility,
                ),
              ),
            ),
          ),
          if (export)
            TextField(
              controller: confirmation,
              obscureText: obscured.value,
              decoration: InputDecoration(
                labelText: l10n.backupPasswordConfirm,
                errorText: mismatch ? l10n.backupPasswordMismatch : null,
              ),
            ),
          if (export && password.text.isEmpty) Text(l10n.backupPlainWarning),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: mismatch || (!export && password.text.isEmpty)
              ? null
              : () => Navigator.pop(context, password.text),
          child: Text(l10n.ok),
        ),
      ],
    );
  }
}
