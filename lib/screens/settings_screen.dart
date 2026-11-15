import 'package:authentication/backup/automatic_backup.dart';
import 'package:authentication/l10n/generated/app_localizations.dart';
import 'package:authentication/router/app_router.dart';
import 'package:authentication/settings/settings.dart';
import 'package:authentication/settings/settings_provider.dart';
import 'package:authentication/storage/device_key_store.dart';
import 'package:authentication/widgets/app_scaffold.dart';
import 'package:authentication/widgets/custom_app_bar.dart';
import 'package:authentication/widgets/glass_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart' show HookConsumerWidget;

/// 设置项的数据模型。
class SettingsItemModel {
  /// 创建一个设置项模型。
  /// [label] 设置项名称。
  /// [value] 当前布尔值状态。
  /// [onTap] 切换状态时的回调。
  const SettingsItemModel({
    required this.label,
    required this.value,
    required this.onTap,
  });

  /// 标签名称
  final String label;

  /// 布尔值
  final bool value;

  /// 点击回调
  final VoidCallback onTap;
}

/// 设置页面，用于配置应用的全局偏好（如点击显示验证码、点击复制等）。
class SettingsScreen extends ConsumerWidget {
  /// 创建设置页面。
  const SettingsScreen({super.key, this.root = false});

  final bool root;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final integerSettings = ref.watch(integerSettingsProvider);
    final busy = ref.watch(settingsOperationsProvider).isLoading;
    Widget loadState({String? message}) => AppPageScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: message == null
                ? const CircularProgressIndicator()
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(message, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () {
                          ref.invalidate(settingsProvider);
                          ref.invalidate(integerSettingsProvider);
                        },
                        child: Text(l10n.screenProtectionRetry),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
    ref.listen(settingsOperationsProvider, (previous, next) {
      if (next.hasError && context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.saveFailed)));
      }
    });
    final isShowCaptchaOnTap = ref.watch(isShowCaptchaOnTapProvider);
    final isCopyCaptchaOnTap = ref.watch(isCopyCaptchaOnTapProvider);
    final showAccountName = ref.watch(showAccountNameProvider);
    final advanceHotp = settings.value?[advanceHotpOnCopyKey] ?? false;
    final dynamicColor = settings.value?[dynamicColorKey] ?? true;
    final systemCodeFont = settings.value?[systemCodeFontKey] ?? false;
    final screenSupported = ref.watch(screenProtectionSupportedProvider);
    final screenProtected = settings.value?[screenProtectionKey] ?? true;
    final Map<String, SettingsItemModel> options = {
      showCaptchaOnTapKey: SettingsItemModel(
        label: AppLocalizations.of(context)!.showCaptchaOnTap,
        value: isShowCaptchaOnTap,
        onTap: () => ref
            .read(settingsOperationsProvider.notifier)
            .update(showCaptchaOnTapKey, !isShowCaptchaOnTap),
      ),
      copyCaptchaOnTapKey: SettingsItemModel(
        label: AppLocalizations.of(context)!.copyCaptchaOnTap,
        value: isCopyCaptchaOnTap,
        onTap: () => ref
            .read(settingsOperationsProvider.notifier)
            .update(copyCaptchaOnTapKey, !isCopyCaptchaOnTap),
      ),
      showAccountNameKey: SettingsItemModel(
        label: l10n.showAccountName,
        value: showAccountName,
        onTap: () => ref
            .read(settingsOperationsProvider.notifier)
            .update(showAccountNameKey, !showAccountName),
      ),
      advanceHotpOnCopyKey: SettingsItemModel(
        label: l10n.advanceHotpOnCopy,
        value: advanceHotp,
        onTap: () => ref
            .read(settingsOperationsProvider.notifier)
            .update(advanceHotpOnCopyKey, !advanceHotp),
      ),
      dynamicColorKey: SettingsItemModel(
        label: l10n.dynamicColor,
        value: dynamicColor,
        onTap: () => ref
            .read(settingsOperationsProvider.notifier)
            .update(dynamicColorKey, !dynamicColor),
      ),
      systemCodeFontKey: SettingsItemModel(
        label: l10n.systemCodeFont,
        value: systemCodeFont,
        onTap: () => ref
            .read(settingsOperationsProvider.notifier)
            .update(systemCodeFontKey, !systemCodeFont),
      ),
      if (screenSupported)
        screenProtectionKey: SettingsItemModel(
          label: l10n.screenProtection,
          value: screenProtected,
          onTap: () => ref
              .read(settingsOperationsProvider.notifier)
              .update(screenProtectionKey, !screenProtected),
        ),
    };

    return AppScaffold(
      largeTitle: true,
      appBar: CustomAppBar(
        title: l10n.settings,
        leftIcon: root ? null : Icons.arrow_back,
      ),
      body: settings.when(
        loading: () => loadState(),
        error: (_, _) => loadState(message: l10n.settingsLoadError),
        data: (_) => integerSettings.when(
          loading: () => loadState(),
          error: (_, _) => loadState(message: l10n.settingsLoadError),
          data: (values) {
            Widget choice(String settingKey) => AppChoiceTile<int>(
              key: ValueKey(settingKey),
              label: switch (settingKey) {
                hideCodeAfterKey => l10n.hideCodeAfter,
                codeGroupingKey => l10n.codeGrouping,
                themeModeKey => l10n.themeChoice,
                accentColorKey => l10n.accentChoice,
                languageKey => l10n.languageChoice,
                _ => l10n.accountView,
              },
              value: values[settingKey] ?? 0,
              options: switch (settingKey) {
                hideCodeAfterKey => {
                  0: l10n.never,
                  for (final seconds in hideCodeDelayOptions.skip(1))
                    seconds: l10n.seconds(seconds),
                },
                codeGroupingKey => {
                  0: l10n.groupNone,
                  for (final n in [2, 3, 4]) n: l10n.groupEvery(n),
                  5: l10n.groupHalves,
                  6: l10n.groupThirds,
                },
                themeModeKey => {
                  0: l10n.themeSystem,
                  1: l10n.themeLight,
                  2: l10n.themeDark,
                  3: l10n.themeBlack,
                  4: l10n.themeSystemBlack,
                },
                accentColorKey => {
                  0: l10n.accentDefault,
                  1: l10n.accentRed,
                  2: l10n.accentOrange,
                  3: l10n.accentGreen,
                  4: l10n.accentTeal,
                  5: l10n.accentBlue,
                  6: l10n.accentIndigo,
                  7: l10n.accentPink,
                },
                languageKey => {
                  0: l10n.languageSystem,
                  for (var i = 0; i < languageNames.length; i++)
                    i + 1: languageNames[i],
                },
                _ => {
                  0: l10n.viewDefault,
                  1: l10n.viewCompact,
                  2: l10n.viewTiles,
                },
              },
              onChanged: busy
                  ? null
                  : (value) => ref
                        .read(settingsOperationsProvider.notifier)
                        .updateInteger(settingKey, value),
            );

            SettingsItemModel option(String key) => options[key]!;

            Widget link(String title, String route) => ListTile(
              title: Text(title),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, route),
            );

            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: AppPageList(
                  children: [
                    AppGlassGroup(
                      header: Text(l10n.settingsCodes),
                      children: [
                        for (final key in [
                          showCaptchaOnTapKey,
                          copyCaptchaOnTapKey,
                          showAccountNameKey,
                          advanceHotpOnCopyKey,
                        ])
                          SettingsSwitchTile(
                            option: option(key),
                            enabled: !busy,
                          ),
                        choice(hideCodeAfterKey),
                        choice(codeGroupingKey),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AppGlassGroup(
                      header: Text(l10n.settingsAppearance),
                      children: [
                        SettingsSwitchTile(
                          option: option(dynamicColorKey),
                          enabled: !busy,
                        ),
                        SettingsSwitchTile(
                          option: option(systemCodeFontKey),
                          enabled: !busy,
                        ),
                        for (final key in [
                          themeModeKey,
                          accentColorKey,
                          languageKey,
                          accountViewKey,
                        ])
                          choice(key),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AppGlassGroup(
                      header: Text(l10n.settingsData),
                      children: [
                        link(l10n.backupHubTitle, AppRoutes.backupHub),
                        link(l10n.categories, AppRoutes.categories),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AppGlassGroup(
                      header: Text(l10n.settingsSecurity),
                      children: [
                        link(l10n.passwordTitle, AppRoutes.password),
                        if (screenSupported)
                          SettingsSwitchTile(
                            option: option(screenProtectionKey),
                            enabled: !busy,
                          )
                        else
                          ListTile(
                            title: Text(l10n.screenProtectionUnsupported),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AppGlassGroup(
                      header: Text(l10n.settingsHelp),
                      children: [
                        link(l10n.userGuide, AppRoutes.userGuide),
                        link(l10n.migrationGuides, AppRoutes.migrationGuides),
                        link(l10n.aboutApp, AppRoutes.about),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class PasswordScreen extends HookConsumerWidget {
  const PasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final enabled = ref.watch(passwordEnabledProvider);
    final operation = ref.watch(passwordOperationsProvider);
    final integerSettings = ref.watch(integerSettingsProvider);
    ref.listen(settingsOperationsProvider, (previous, next) {
      if (next.hasError && context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.saveFailed)));
      }
    });
    final current = useTextEditingController();
    final next = useTextEditingController();
    final confirmation = useTextEditingController();
    final hidden = useState(true);
    useListenable(current);
    useListenable(next);
    useListenable(confirmation);

    Future<void> change(bool remove) async {
      if (remove) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AppDialog(
            title: Text(l10n.passwordRemove),
            content: Text(l10n.passwordRemoveWarning),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n.passwordRemove),
              ),
            ],
          ),
        );
        if (confirmed != true || !context.mounted) return;
      }
      final success = await ref
          .read(passwordOperationsProvider.notifier)
          .change(
            currentPassword: enabled.value == true ? current.text : null,
            newPassword: remove ? null : next.text,
          );
      if (!context.mounted) return;
      final error = ref.read(passwordOperationsProvider).error;
      final cleanupFailed = error is KeyChangeCleanupFailed;
      if (success || cleanupFailed) {
        current.clear();
        next.clear();
        confirmation.clear();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? l10n.passwordSaved
                : cleanupFailed
                ? l10n.passwordCleanupFailed
                : l10n.passwordFailed,
          ),
        ),
      );
    }

    return AppScaffold(
      appBar: CustomAppBar(title: l10n.passwordTitle),
      body: enabled.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l10n.passwordFailed)),
        data: (hasPassword) => Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                AppGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(l10n.passwordIntro),
                      const SizedBox(height: 16),
                      if (hasPassword) ...[
                        integerSettings.when(
                          loading: () => const CircularProgressIndicator(),
                          error: (_, _) => Text(l10n.settingsLoadError),
                          data: (values) => AppChoiceTile<int>(
                            key: const ValueKey(autoLockKey),
                            value: values[autoLockKey] ?? 0,
                            label: l10n.autoLockTitle,
                            options: {
                              0: l10n.never,
                              -1: l10n.autoLockImmediately,
                              for (final seconds in autoLockOptions.skip(2))
                                seconds: l10n.seconds(seconds),
                            },
                            onChanged: (value) {
                              ref
                                  .read(settingsOperationsProvider.notifier)
                                  .updateInteger(autoLockKey, value);
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (hasPassword) ...[
                        TextField(
                          controller: current,
                          obscureText: hidden.value,
                          maxLength: 1024,
                          decoration: InputDecoration(
                            labelText: l10n.passwordCurrent,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      TextField(
                        controller: next,
                        obscureText: hidden.value,
                        maxLength: 1024,
                        decoration: InputDecoration(
                          labelText: l10n.passwordNew,
                          suffixIcon: IconButton(
                            tooltip: hidden.value
                                ? l10n.revealPassword
                                : l10n.hidePassword,
                            onPressed: () => hidden.value = !hidden.value,
                            icon: Icon(
                              hidden.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: confirmation,
                        obscureText: hidden.value,
                        maxLength: 1024,
                        decoration: InputDecoration(
                          labelText: l10n.passwordConfirm,
                          errorText:
                              confirmation.text.isNotEmpty &&
                                  confirmation.text != next.text
                              ? l10n.backupPasswordMismatch
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed:
                            operation.isLoading ||
                                (hasPassword && current.text.isEmpty) ||
                                next.text.isEmpty ||
                                next.text != confirmation.text
                            ? null
                            : () => change(false),
                        child: Text(
                          hasPassword ? l10n.passwordChange : l10n.passwordSet,
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasPassword) ...[
                  const SizedBox(height: 16),
                  AppGlassCard(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                      ),
                      onPressed: operation.isLoading || current.text.isEmpty
                          ? null
                          : () => change(true),
                      child: Text(l10n.passwordRemove),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AutomaticBackupScreen extends HookConsumerWidget {
  const AutomaticBackupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final status = ref.watch(automaticBackupProvider);
    final password = useTextEditingController();
    final confirmation = useTextEditingController();
    final obscure = useState(true);
    useListenable(password);
    useListenable(confirmation);
    final busy =
        status == AutomaticBackupStatus.loading ||
        status == AutomaticBackupStatus.saving;
    final supported = status != AutomaticBackupStatus.unsupported;
    final message = switch (status) {
      AutomaticBackupStatus.loading => l10n.autoBackupSaving,
      AutomaticBackupStatus.unsupported => l10n.autoBackupUnsupported,
      AutomaticBackupStatus.disabled => l10n.autoBackupDisabled,
      AutomaticBackupStatus.ready => l10n.autoBackupReady,
      AutomaticBackupStatus.saving => l10n.autoBackupSaving,
      AutomaticBackupStatus.saved => l10n.autoBackupSaved,
      AutomaticBackupStatus.configurationFailed => l10n.autoBackupConfigFailed,
      AutomaticBackupStatus.failed => l10n.autoBackupFailed,
    };
    return AppScaffold(
      appBar: CustomAppBar(title: l10n.automaticBackup),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              AppGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      supported
                          ? l10n.autoBackupIntro
                          : l10n.autoBackupUnsupported,
                    ),
                    const SizedBox(height: 16),
                    Text(message, semanticsLabel: message),
                    if (supported) ...[
                      const SizedBox(height: 16),
                      Text(l10n.autoBackupLocalOnly),
                      const SizedBox(height: 16),
                      TextField(
                        controller: password,
                        obscureText: obscure.value,
                        decoration: InputDecoration(
                          labelText: l10n.backupPasswordRequired,
                          suffixIcon: IconButton(
                            tooltip: obscure.value
                                ? l10n.revealPassword
                                : l10n.hidePassword,
                            onPressed: () => obscure.value = !obscure.value,
                            icon: Icon(
                              obscure.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: confirmation,
                        obscureText: obscure.value,
                        decoration: InputDecoration(
                          labelText: l10n.backupPasswordConfirm,
                          errorText:
                              confirmation.text.isNotEmpty &&
                                  confirmation.text != password.text
                              ? l10n.backupPasswordMismatch
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed:
                            busy ||
                                password.text.isEmpty ||
                                password.text.length > 1024 ||
                                password.text != confirmation.text
                            ? null
                            : () async {
                                final success = await ref
                                    .read(automaticBackupProvider.notifier)
                                    .configure(password.text);
                                if (success) {
                                  password.clear();
                                  confirmation.clear();
                                }
                              },
                        child: Text(l10n.autoBackupConfigure),
                      ),
                      TextButton(
                        onPressed:
                            busy ||
                                status == AutomaticBackupStatus.disabled ||
                                status ==
                                    AutomaticBackupStatus.configurationFailed
                            ? null
                            : () => ref
                                  .read(automaticBackupProvider.notifier)
                                  .runNow(),
                        child: Text(l10n.autoBackupRetry),
                      ),
                    ],
                  ],
                ),
              ),
              if (supported) ...[
                const SizedBox(height: 16),
                AppGlassCard(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                    onPressed: busy || status == AutomaticBackupStatus.disabled
                        ? null
                        : () => ref
                              .read(automaticBackupProvider.notifier)
                              .disable(),
                    child: Text(l10n.autoBackupDisable),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 带开关的设置列表项组件。
class SettingsSwitchTile extends StatelessWidget {
  /// 创建一个设置开关列表项。
  /// [option] 设置项模型。
  const SettingsSwitchTile({
    required this.option,
    this.enabled = true,
    super.key,
  });

  /// 设置项模型
  final SettingsItemModel option;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return AppSwitchTile(
      label: option.label,
      value: option.value,
      onChanged: enabled ? (_) => option.onTap() : null,
    );
  }
}
