import 'package:auth/l10n/generated/app_localizations.dart';
import 'package:auth/providers/add_account_controller.dart';
import 'package:auth/providers/data_transfer_controller.dart';
import 'package:auth/providers/data_transfer_state.dart';
import 'package:auth/providers/qr_code_controller.dart';
import 'package:auth/router/app_router.dart';
import 'package:auth/ui/action_result_sheet.dart';
import 'package:auth/ui/custom_app_bar.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
    // We keep the addAccountController alive with watch because its method is passed directly as a callback.
    final addAccountController = ref.watch(addAccountControllerProvider.notifier);
    
    final l10n = AppLocalizations.of(context)!;

    final List<AddMethodOption> options = [
      AddMethodOption(Icons.camera_enhance, l10n.scanQRCode, () => _handleScan(context, ref)),
      AddMethodOption(Icons.photo_library, l10n.uploadQRCode, () => _handleUpload(context, ref)),
      AddMethodOption(Icons.keyboard, l10n.enterKey, addAccountController.enter),
      AddMethodOption(Icons.file_upload_outlined, l10n.importFromClipboard, () => _handleRestore(context, ref)),
      AddMethodOption(Icons.file_download_outlined, l10n.exportToClipboard, () => _handleBackup(context, ref)),
    ];

    return Scaffold(
      appBar: CustomAppBar(title: l10n.add),
      body: GridView.builder(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 700, mainAxisSpacing: 16, crossAxisSpacing: 16, mainAxisExtent: 90),
        itemCount: options.length,
        itemBuilder: (BuildContext context, int index) {
          final AddMethodOption option = options[index];
          return AddMethodTile(option.icon, option.label, option.onTap);
        },
      ),
    );
  }

  Future<void> _handleScan(BuildContext context, WidgetRef ref) async {
    final controller = ref.read(qrCodeControllerProvider.notifier);
    if (!controller.isPlatformSupported) {
      _showNotSupported(context);
      return;
    }
    
    final BarcodeCapture? barcodeCapture = await context.pushNamed(AppRoutes.scanName);
    if (barcodeCapture != null && barcodeCapture.barcodes.isNotEmpty) {
      final code = barcodeCapture.barcodes.first.rawValue;
      if (code != null && context.mounted) {
        await _processQrCode(context, ref, code);
      }
    }
  }

  Future<void> _handleUpload(BuildContext context, WidgetRef ref) async {
    final controller = ref.read(qrCodeControllerProvider.notifier);
    if (!controller.isPlatformSupported) {
      _showNotSupported(context);
      return;
    }

    final XFile? file = await controller.pickImage();
    if (file == null) return;

    final codes = await controller.analyzeFile(file.path);
    if (codes.isNotEmpty && context.mounted) {
      await _processQrCode(context, ref, codes.first);
    } else if (context.mounted) {
       _showResult(context, 0, AppLocalizations.of(context)!.tip, AppLocalizations.of(context)!.unsupportedQRCode);
    }
  }

  Future<void> _processQrCode(BuildContext context, WidgetRef ref, String code, {bool forceUpdate = false}) async {
    final controller = ref.read(qrCodeControllerProvider.notifier);
    final result = await controller.processCode(code, forceUpdate: forceUpdate);
    
    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context)!;

    if (result is QrProcessSuccess) {
      if (context.mounted) {
        context.pop(); // Pop AddScreen
        await _showResult(context, 1, l10n.tip, l10n.addSuccess);
      }
    } else if (result is QrProcessConflict) {
      if (context.mounted) {
        final confirm = await showCupertinoModalPopup<bool>(
          context: context,
          builder: (ctx) => ActionResultSheet(
            state: 0,
            title: l10n.warning,
            message: l10n.tokenExists(result.pending.issuer.value, result.pending.account.value),
            falseButtonVisible: true,
          ),
        );
        if (confirm == true && context.mounted) {
          await _processQrCode(context, ref, code, forceUpdate: true);
        }
      }
    } else if (result is QrProcessError) {
      if (context.mounted) {
        await _showResult(context, 0, l10n.tip, result.code.getLocalizedMessage(context));
      }
    }
  }

  Future<void> _handleRestore(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    // 1. Confirm
    final bool? proceed = await showCupertinoModalPopup<bool?>(
      context: context,
      builder: (ctx) => ActionResultSheet(
        state: 0,
        title: l10n.warning,
        message: l10n.importWarning,
        falseButtonVisible: true,
      ),
    );
    if (proceed != true) return;

    // 2. Execute
    final result = await ref.read(dataTransferControllerProvider.notifier).restore();
    if (!context.mounted) return;

    switch (result) {
      case DataTransferSuccess(count: final count):
        await _showResult(context, 1, l10n.importSuccess, l10n.importedCount(count));
      case DataTransferFailure(error: _):
        await _showResult(context, 0, l10n.importFailed, l10n.importFailed); // Simplified error message for UI
      case DataTransferNoData():
        await _showResult(context, 0, l10n.importFailed, l10n.cannotGetClipboardData);
      case DataTransferConfirmationRequired():
        // Not used in this simplified flow
        break;
    }
  }

  Future<void> _handleBackup(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;

    // 1. Confirm
    final bool? proceed = await showCupertinoModalPopup<bool?>(
      context: context,
      builder: (ctx) => ActionResultSheet(
        state: 0,
        title: l10n.warning,
        message: l10n.exportWarning,
        falseButtonVisible: true,
      ),
    );
    if (proceed != true) return;

    // 2. Execute
    final result = await ref.read(dataTransferControllerProvider.notifier).backup();
    if (!context.mounted) return;

    switch (result) {
      case DataTransferSuccess(count: final count):
        await _showResult(context, 1, l10n.exportSuccess, l10n.exportedCount(count));
      case DataTransferNoData():
        await _showResult(context, 0, l10n.exportFailed, l10n.noDataToExport);
      case _:
        break;
    }
  }

  Future<void> _showResult(BuildContext context, int state, String title, String message) async {
    return await showCupertinoModalPopup(
      context: context,
      builder: (ctx) => ActionResultSheet(state: state, title: title, message: message),
    );
  }

  Future<void> _showNotSupported(BuildContext context) async {
    await _showResult(context, 0, AppLocalizations.of(context)!.tip, AppLocalizations.of(context)!.platformNotSupported);
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
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: const BorderRadius.all(Radius.circular(24))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 48,
            width: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: const BorderRadius.all(Radius.circular(12))),
            child: Icon(icon, size: 24, color: Theme.of(context).colorScheme.onPrimary),
          ),
          const SizedBox(width: 16),
          Text(
            label,
            maxLines: 1,
            style: TextStyle(height: 0, fontSize: 18, color: Theme.of(context).colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 16),
        ],
      ),
    ),
  );
}