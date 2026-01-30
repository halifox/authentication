import 'package:flutter/material.dart';

import 'package:auth/l10n/generated/app_localizations.dart';
import 'package:auth/ui/custom_app_bar.dart';
import 'package:go_router/go_router.dart';

/// 操作结果底面菜单，用于向用户展示成功或失败的反馈。
class ActionResultSheet extends StatelessWidget {
  /// 创建一个操作结果底面菜单。
  /// [state] 表示结果状态：0 为错误，1 为成功。
  /// [title] 标题文字。
  /// [message] 详细描述信息。
  /// [falseButtonVisible] 是否显示取消/否定按钮。
  const ActionResultSheet({this.state = 0, this.title = '', this.message = '', this.falseButtonVisible = false, super.key});

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
    return Scaffold(
      appBar: const CustomAppBar(title: ''),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              switch (state) {
                0 => const Icon(Icons.error, size: 80, color: Colors.red),
                1 => const Icon(Icons.check_circle, size: 80, color: Colors.green),
                int() => throw UnimplementedError(),
              },
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(message, style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
              const Spacer(flex: 2),
              FilledButton.tonal(
                onPressed: () {
                  context.pop(true);
                },
                child: Container(
                  width: double.infinity,
                  height: 56,
                  alignment: Alignment.center,
                  child: Text(AppLocalizations.of(context)!.ok, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 8),
              Visibility(
                visible: falseButtonVisible,
                child: OutlinedButton(
                  onPressed: () {
                    context.pop(false);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    alignment: Alignment.center,
                    child: Text(AppLocalizations.of(context)!.cancel, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              Visibility(visible: falseButtonVisible, child: const SizedBox(height: 8)),
            ],
          ),
        ),
      ),
    );
  }
}
