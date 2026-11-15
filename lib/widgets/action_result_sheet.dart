import 'package:authentication/l10n/generated/app_localizations.dart';
import 'package:authentication/widgets/glass_inputs.dart';
import 'package:authentication/widgets/glass_quality.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// 操作结果底面菜单，用于向用户展示成功或失败的反馈。
class ActionResultSheet extends StatelessWidget {
  /// 创建一个操作结果底面菜单。
  /// [state] 表示结果状态：0 为错误，1 为成功。
  /// [title] 标题文字。
  /// [message] 详细描述信息。
  /// [falseButtonVisible] 是否显示取消/否定按钮。
  const ActionResultSheet({
    this.state = 0,
    this.title = '',
    this.message = '',
    this.falseButtonVisible = false,
    super.key,
  });

  /// 结果状态 (0: 错误, 1: 成功)
  final int state;

  /// 标题
  final String title;

  /// 消息内容
  final String message;

  /// 是否显示取消按钮
  final bool falseButtonVisible;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: DefaultTextStyle(
          style: theme.textTheme.bodyLarge!.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          child: GlassSheet(
            quality: appGlassQuality,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  state == 1 ? Icons.check_circle : Icons.error,
                  size: 64,
                  color: state == 1
                      ? theme.colorScheme.primary
                      : theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Semantics(
                  header: true,
                  child: Text(
                    title,
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                AppButton(
                  onPressed: () => Navigator.pop(context, true),
                  prominent: false,
                  child: Text(l10n.ok),
                ),
                if (falseButtonVisible)
                  AppButton(
                    onPressed: () => Navigator.pop(context, false),
                    prominent: false,
                    child: Text(l10n.cancel),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
