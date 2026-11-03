import 'package:authentication/l10n/generated/app_localizations.dart';
import 'package:authentication/router/app_router.dart';
import 'package:authentication/settings/settings.dart';
import 'package:authentication/settings/settings_provider.dart';
import 'package:authentication/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final integerSettings = ref.watch(integerSettingsProvider);
    final busy = ref.watch(settingsOperationsProvider).isLoading;
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
    final backupReminders = settings.value?[backupRemindersKey] ?? true;
    final systemCodeFont = settings.value?[systemCodeFontKey] ?? false;
    final List<SettingsItemModel> options = [
      SettingsItemModel(
        label: AppLocalizations.of(context)!.showCaptchaOnTap,
        value: isShowCaptchaOnTap,
        onTap: () => ref
            .read(settingsOperationsProvider.notifier)
            .update(showCaptchaOnTapKey, !isShowCaptchaOnTap),
      ),
      SettingsItemModel(
        label: AppLocalizations.of(context)!.copyCaptchaOnTap,
        value: isCopyCaptchaOnTap,
        onTap: () => ref
            .read(settingsOperationsProvider.notifier)
            .update(copyCaptchaOnTapKey, !isCopyCaptchaOnTap),
      ),
      SettingsItemModel(
        label: l10n.showAccountName,
        value: showAccountName,
        onTap: () => ref
            .read(settingsOperationsProvider.notifier)
            .update(showAccountNameKey, !showAccountName),
      ),
      SettingsItemModel(
        label: l10n.advanceHotpOnCopy,
        value: advanceHotp,
        onTap: () => ref
            .read(settingsOperationsProvider.notifier)
            .update(advanceHotpOnCopyKey, !advanceHotp),
      ),
      SettingsItemModel(
        label: l10n.dynamicColor,
        value: dynamicColor,
        onTap: () => ref
            .read(settingsOperationsProvider.notifier)
            .update(dynamicColorKey, !dynamicColor),
      ),
      SettingsItemModel(
        label: l10n.backupReminders,
        value: backupReminders,
        onTap: () => ref
            .read(settingsOperationsProvider.notifier)
            .update(backupRemindersKey, !backupReminders),
      ),
      SettingsItemModel(
        label: l10n.systemCodeFont,
        value: systemCodeFont,
        onTap: () => ref
            .read(settingsOperationsProvider.notifier)
            .update(systemCodeFontKey, !systemCodeFont),
      ),
    ];

    return Scaffold(
      appBar: CustomAppBar(title: AppLocalizations.of(context)!.settings),
      body: settings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l10n.settingsLoadError)),
        data: (_) => integerSettings.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Center(child: Text(l10n.settingsLoadError)),
          data: (values) => GridView.builder(
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
            itemCount: options.length + 9,
            itemBuilder: (BuildContext context, int index) {
              if (index == options.length + 8) {
                return Material(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(24),
                  child: ListTile(
                    title: Text(l10n.aboutApp),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.pushNamed(context, AppRoutes.about),
                  ),
                );
              }
              if (index == options.length + 7) {
                return Material(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(24),
                  child: ListTile(
                    title: Text(l10n.userGuide),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.userGuide),
                  ),
                );
              }
              if (index == options.length + 6) {
                return Material(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(24),
                  child: ListTile(
                    title: Text(l10n.categories),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.categories),
                  ),
                );
              }
              if (index >= options.length) {
                final selection = index - options.length;
                final settingKey = switch (selection) {
                  0 => hideCodeAfterKey,
                  1 => codeGroupingKey,
                  2 => themeModeKey,
                  3 => accentColorKey,
                  4 => languageKey,
                  _ => accountViewKey,
                };
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Tooltip(
                    message: selection == 3 ? l10n.accentPriority : '',
                    child: DropdownButtonFormField<int>(
                      key: ValueKey(settingKey),
                      isExpanded: true,
                      initialValue: values[settingKey],
                      decoration: InputDecoration(
                        labelText: switch (selection) {
                          0 => l10n.hideCodeAfter,
                          1 => l10n.codeGrouping,
                          2 => l10n.themeChoice,
                          3 => l10n.accentChoice,
                          4 => l10n.languageChoice,
                          _ => l10n.accountView,
                        },
                      ),
                      items: switch (selection) {
                        0 => [
                          DropdownMenuItem(value: 0, child: Text(l10n.never)),
                          for (final seconds in hideCodeDelayOptions.skip(1))
                            DropdownMenuItem(
                              value: seconds,
                              child: Text(l10n.seconds(seconds)),
                            ),
                        ],
                        1 => [
                          DropdownMenuItem(
                            value: 0,
                            child: Text(l10n.groupNone),
                          ),
                          for (final n in [2, 3, 4])
                            DropdownMenuItem(
                              value: n,
                              child: Text(l10n.groupEvery(n)),
                            ),
                          DropdownMenuItem(
                            value: 5,
                            child: Text(l10n.groupHalves),
                          ),
                          DropdownMenuItem(
                            value: 6,
                            child: Text(l10n.groupThirds),
                          ),
                        ],
                        2 => [
                          DropdownMenuItem(
                            value: 0,
                            child: Text(l10n.themeSystem),
                          ),
                          DropdownMenuItem(
                            value: 1,
                            child: Text(l10n.themeLight),
                          ),
                          DropdownMenuItem(
                            value: 2,
                            child: Text(l10n.themeDark),
                          ),
                          DropdownMenuItem(
                            value: 3,
                            child: Text(l10n.themeBlack),
                          ),
                          DropdownMenuItem(
                            value: 4,
                            child: Text(l10n.themeSystemBlack),
                          ),
                        ],
                        3 => [
                          DropdownMenuItem(
                            value: 0,
                            child: Text(l10n.accentDefault),
                          ),
                          DropdownMenuItem(
                            value: 1,
                            child: Text(l10n.accentRed),
                          ),
                          DropdownMenuItem(
                            value: 2,
                            child: Text(l10n.accentOrange),
                          ),
                          DropdownMenuItem(
                            value: 3,
                            child: Text(l10n.accentGreen),
                          ),
                          DropdownMenuItem(
                            value: 4,
                            child: Text(l10n.accentTeal),
                          ),
                          DropdownMenuItem(
                            value: 5,
                            child: Text(l10n.accentBlue),
                          ),
                          DropdownMenuItem(
                            value: 6,
                            child: Text(l10n.accentIndigo),
                          ),
                          DropdownMenuItem(
                            value: 7,
                            child: Text(l10n.accentPink),
                          ),
                        ],
                        4 => [
                          DropdownMenuItem(
                            value: 0,
                            child: Text(l10n.languageSystem),
                          ),
                          for (var i = 0; i < languageNames.length; i++)
                            DropdownMenuItem(
                              value: i + 1,
                              child: Text(languageNames[i]),
                            ),
                        ],
                        _ => [
                          DropdownMenuItem(
                            value: 0,
                            child: Text(l10n.viewDefault),
                          ),
                          DropdownMenuItem(
                            value: 1,
                            child: Text(l10n.viewCompact),
                          ),
                          DropdownMenuItem(
                            value: 2,
                            child: Text(l10n.viewTiles),
                          ),
                        ],
                      },
                      onChanged: busy
                          ? null
                          : (value) {
                              if (value != null) {
                                ref
                                    .read(settingsOperationsProvider.notifier)
                                    .updateInteger(settingKey, value);
                              }
                            },
                    ),
                  ),
                );
              }
              final option = options[index];
              return SettingsSwitchTile(option: option, enabled: !busy);
            },
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
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: const BorderRadius.all(Radius.circular(24)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              option.label,
              maxLines: 1,
              style: TextStyle(
                height: 0,
                fontSize: 18,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: enabled ? option.onTap : null,
            child: Container(
              height: 48,
              width: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: option.value
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.inversePrimary,
                borderRadius: const BorderRadius.all(Radius.circular(12)),
              ),
              child: Icon(
                option.value ? Icons.done : Icons.close,
                size: 36,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
