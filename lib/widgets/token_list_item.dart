import 'dart:async';

import 'package:authentication/l10n/generated/app_localizations.dart';
import 'package:authentication/otp/account.dart';
import 'package:authentication/otp/otp.dart';
import 'package:authentication/otp/token_item_provider.dart';
import 'package:authentication/router/app_router.dart';
import 'package:authentication/settings/settings.dart';
import 'package:authentication/settings/settings_provider.dart';
import 'package:authentication/widgets/account_icon.dart';
import 'package:authentication/widgets/action_result_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';

/// 令牌列表项组件，支持侧滑删除和编辑操作。
class TokenListItem extends ConsumerWidget {
  /// 创建一个令牌列表项。
  /// [config] 身份验证条目配置数据。
  const TokenListItem({super.key, required this.config, this.compact = false});

  /// 身份验证配置
  final OtpAccount config;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return SwipeActionCell(
      key: ValueKey('swipe_${config.id}'),
      trailingActions: [
        _buildAction(context, l10n.delete, () => _onDelete(context, ref)),
        _buildAction(context, l10n.edit, () => _onEdit(context)),
        _buildAction(
          context,
          l10n.resetCopyCount,
          () => _onReset(context, ref),
        ),
      ],
      child: _TokenCard(config: config, compact: compact),
    );
  }

  SwipeAction _buildAction(
    BuildContext context,
    String label,
    VoidCallback onTap,
  ) {
    return SwipeAction(
      widthSpace: 96,
      onTap: (handler) async => onTap(),
      color: Colors.transparent,
      content: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(label, textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }

  void _onEdit(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.form, arguments: config);
  }

  Future<void> _onReset(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showCupertinoModalPopup<bool>(
      context: context,
      builder: (_) => ActionResultSheet(
        state: 0,
        title: l10n.warning,
        message: l10n.resetCopyCountWarning,
        falseButtonVisible: true,
      ),
    );
    if (result == true && context.mounted) {
      try {
        await ref.read(tokenItemProvider(config.id).notifier).resetCopyCount();
      } catch (_) {
        if (context.mounted)
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(l10n.saveFailed)));
      }
    }
  }

  Future<void> _onDelete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final bool? result = await showCupertinoModalPopup<bool>(
      context: context,
      builder: (ctx) => ActionResultSheet(
        state: 0,
        title: l10n.warning,
        message: l10n.deleteWarning,
        falseButtonVisible: true,
      ),
    );
    if (result ?? false) {
      await ref.read(tokenItemProvider(config.id).notifier).deleteToken();
    }
  }
}

class _TokenCard extends ConsumerWidget {
  const _TokenCard({required this.config, required this.compact});

  final OtpAccount config;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isShowOnTap = ref.watch(isShowCaptchaOnTapProvider);
    final isCopyOnTap = ref.watch(isCopyCaptchaOnTapProvider);
    final advanceHotp =
        ref.watch(settingsProvider).value?[advanceHotpOnCopyKey] ?? false;
    final hideAfter =
        ref.watch(integerSettingsProvider).value?[hideCodeAfterKey] ?? 5;
    final itemState = ref.watch(tokenItemProvider(config.id));
    final controller = ref.read(tokenItemProvider(config.id).notifier);

    final isVisible = !isShowOnTap || itemState.isRevealed;

    return GestureDetector(
      onTap: () {
        if (isShowOnTap) controller.toggleReveal(hideAfter);
        if (isCopyOnTap && !itemState.isUpdating) {
          _handleCopy(context, controller, advanceHotp);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            _TokenHeader(config: config),
            const Spacer(),
            _TokenCodeRow(
              config: config,
              isVisible: isVisible,
              compact: compact,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCopy(
    BuildContext context,
    TokenItem controller,
    bool advanceHotp,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    String message;
    try {
      final recorded = await controller.copyCode(advanceHotp: advanceHotp);
      message = recorded ? l10n.codeCopied : l10n.copyRecordFailed;
    } catch (_) {
      message = l10n.copyFailed;
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }
}

class _TokenHeader extends ConsumerWidget {
  const _TokenHeader({required this.config});

  final OtpAccount config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        _TokenIcon(iconPath: config.icon),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                config.issuer,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              Text(
                l10n.copyCount(config.copyCount),
                style: theme.textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (ref.watch(showAccountNameProvider))
                Text(
                  config.account,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer.withValues(
                      alpha: 0.8,
                    ),
                  ),
                ),
            ],
          ),
        ),
        _TokenAction(config: config),
      ],
    );
  }
}

class _TokenIcon extends StatelessWidget {
  const _TokenIcon({required this.iconPath});

  final String iconPath;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 48,
      width: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: AccountIcon(icon: iconPath),
    );
  }
}

class _TokenAction extends ConsumerWidget {
  const _TokenAction({required this.config});

  final OtpAccount config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (config.type == 'hotp') {
      final itemState = ref.watch(tokenItemProvider(config.id));
      return IconButton(
        onPressed: itemState.isUpdating
            ? null
            : () => ref
                  .read(tokenItemProvider(config.id).notifier)
                  .incrementHotp(config),
        icon: const Icon(Icons.refresh),
      );
    }
    return _OtpTimer(period: config.period);
  }
}

class _TokenCodeRow extends StatelessWidget {
  const _TokenCodeRow({
    required this.config,
    required this.isVisible,
    required this.compact,
  });

  final OtpAccount config;
  final bool isVisible;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) => _OtpDisplay(
        config: config,
        isVisible: isVisible,
        compact: compact,
        systemFont:
            ref.watch(settingsProvider).value?[systemCodeFontKey] ?? false,
        grouping:
            ref.watch(integerSettingsProvider).value?[codeGroupingKey] ?? 0,
      ),
    );
  }
}

class _OtpDisplay extends StatefulWidget {
  const _OtpDisplay({
    required this.config,
    required this.isVisible,
    required this.grouping,
    required this.compact,
    required this.systemFont,
  });

  final OtpAccount config;
  final bool isVisible;
  final int grouping;
  final bool compact;
  final bool systemFont;

  @override
  State<_OtpDisplay> createState() => _OtpDisplayState();
}

class _OtpDisplayState extends State<_OtpDisplay> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && widget.config.type.toLowerCase() != 'hotp') {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final code = widget.config.generateCodeString();

    final chars = code.characters.toList();
    final breaks = codeGroupBreaks(chars.length, widget.grouping).toSet();
    return Semantics(
      label: widget.isVisible ? code : AppLocalizations.of(context)!.codeHidden,
      child: ExcludeSemantics(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 0; i < chars.length; i++) ...[
              if (breaks.contains(i))
                SizedBox(key: ValueKey('group_$i'), width: 8),
              Flexible(
                child: _DigitBox(
                  char: chars[i],
                  isVisible: widget.isVisible,
                  compact: widget.compact,
                  systemFont: widget.systemFont,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DigitBox extends StatelessWidget {
  const _DigitBox({
    required this.char,
    required this.isVisible,
    required this.compact,
    required this.systemFont,
  });

  final String char;
  final bool isVisible;
  final bool compact;
  final bool systemFont;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: compact ? 32 : 42,
      width: compact ? 30 : 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: FittedBox(
        child: Text(
          isVisible ? char : '-',
          style: TextStyle(
            fontSize: compact ? 28 : 38,
            color: theme.colorScheme.onTertiary,
            fontWeight: FontWeight.w900,
            fontFamily: systemFont ? null : 'VarelaRound',
            height: 1.0, // 强制行高与字号一致
          ),
          textHeightBehavior: const TextHeightBehavior(
            applyHeightToFirstAscent: false,
            applyHeightToLastDescent: false,
          ),
        ),
      ),
    );
  }
}

class _OtpTimer extends StatelessWidget {
  const _OtpTimer({required this.period});

  final int period;

  @override
  Widget build(BuildContext context) {
    final intervalMs = period * 1000;

    return TweenAnimationBuilder<double>(
      key: ValueKey(
        DateTime.now().millisecondsSinceEpoch ~/ intervalMs,
      ), // 每当一个周期结束时重启动画
      tween: Tween(begin: 1.0, end: 0.0),
      duration: Duration(
        milliseconds: OTP.remainingMilliseconds(
          intervalMilliseconds: intervalMs,
        ),
      ),
      onEnd: () {
        // 强制重建以获取新的剩余时间
        (context as Element).markNeedsBuild();
      },
      builder: (context, value, child) {
        return CircularProgressIndicator(
          value: value,
          strokeCap: StrokeCap.round,
          strokeWidth: 5.5,
        );
      },
    );
  }
}
