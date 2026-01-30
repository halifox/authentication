import 'package:auth/l10n/generated/app_localizations.dart';
import 'package:auth/providers/preferences_provider.dart';
import 'package:auth/ui/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 设置项的数据模型。
class SettingsItemModel {
  /// 创建一个设置项模型。
  /// [label] 设置项名称。
  /// [value] 当前布尔值状态。
  /// [onTap] 切换状态时的回调。
  const SettingsItemModel({required this.label, required this.value, required this.onTap});

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
    final isShowCaptchaOnTap = ref.watch(isShowCaptchaOnTapProvider);
    final isCopyCaptchaOnTap = ref.watch(isCopyCaptchaOnTapProvider);
    final List<SettingsItemModel> options = [
      SettingsItemModel(label: AppLocalizations.of(context)!.showCaptchaOnTap, value: isShowCaptchaOnTap, onTap: () => ref.read(isShowCaptchaOnTapProvider.notifier).update(!isShowCaptchaOnTap)),
      SettingsItemModel(label: AppLocalizations.of(context)!.copyCaptchaOnTap, value: isCopyCaptchaOnTap, onTap: () => ref.read(isCopyCaptchaOnTapProvider.notifier).update(!isCopyCaptchaOnTap)),
    ];

    return Scaffold(
      appBar: CustomAppBar(title: AppLocalizations.of(context)!.settings),
      body: GridView.builder(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 700, mainAxisSpacing: 16, crossAxisSpacing: 16, mainAxisExtent: 90),
        itemCount: options.length,
        itemBuilder: (BuildContext context, int index) {
          final option = options[index];
          return SettingsSwitchTile(option: option);
        },
      ),
    );
  }
}

/// 带开关的设置列表项组件。
class SettingsSwitchTile extends StatelessWidget {
  /// 创建一个设置开关列表项。
  /// [option] 设置项模型。
  const SettingsSwitchTile({required this.option, super.key});

  /// 设置项模型
  final SettingsItemModel option;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: const BorderRadius.all(Radius.circular(24))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              option.label,
              maxLines: 1,
              style: TextStyle(height: 0, fontSize: 18, color: Theme.of(context).colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: option.onTap,
            child: Container(
              height: 48,
              width: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: option.value ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.inversePrimary,
                borderRadius: const BorderRadius.all(Radius.circular(12)),
              ),
              child: Icon(option.value ? Icons.done : Icons.close, size: 36, color: Theme.of(context).colorScheme.onPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
