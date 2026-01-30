import 'package:auth/db/auth_entries_ext.dart';
import 'package:auth/db/database.dart';
import 'package:auth/l10n/generated/app_localizations.dart';
import 'package:auth/providers/token_item_provider.dart';
import 'package:auth/providers/preferences_provider.dart';
import 'package:auth/ui/action_result_sheet.dart';
import 'package:auth/utils/otp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';

/// 令牌列表项组件，支持侧滑删除和编辑操作。
class TokenListItem extends ConsumerWidget {
  /// 创建一个令牌列表项。
  /// [config] 身份验证条目配置数据。
  const TokenListItem({super.key, required this.config});

  /// 身份验证配置
  final AuthEntry config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return SwipeActionCell(
      key: ValueKey('swipe_${config.id}'),
      trailingActions: [_buildAction(context, l10n.delete, () => _onDelete(context, ref)), _buildAction(context, l10n.edit, () => _onEdit(ref))],
      child: _TokenCard(config: config),
    );
  }

  SwipeAction _buildAction(BuildContext context, String label, VoidCallback onTap) {
    return SwipeAction(
      widthSpace: 152,
      onTap: (handler) async => onTap(),
      color: Colors.transparent,
      content: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(24)),
          child: Text(label),
        ),
      ),
    );
  }

  void _onEdit(WidgetRef ref) {
    ref.read(tokenItemProvider(config.id).notifier).editToken(config);
  }

  Future<void> _onDelete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final bool? result = await showCupertinoModalPopup<bool>(
      context: context,
      builder: (ctx) => ActionResultSheet(state: 0, title: l10n.warning, message: l10n.deleteWarning, falseButtonVisible: true),
    );
    if (result ?? false) {
      await ref.read(tokenItemProvider(config.id).notifier).deleteToken();
    }
  }
}

class _TokenCard extends ConsumerWidget {
  const _TokenCard({required this.config});

  final AuthEntry config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isShowOnTap = ref.watch(isShowCaptchaOnTapProvider);
    final isCopyOnTap = ref.watch(isCopyCaptchaOnTapProvider);
    final itemState = ref.watch(tokenItemProvider(config.id));
    final controller = ref.read(tokenItemProvider(config.id).notifier);

    final isVisible = !isShowOnTap || itemState.isRevealed;

    return GestureDetector(
      onTap: () {
        if (isShowOnTap) controller.toggleReveal();
        if (isCopyOnTap) _handleCopy(context, controller, config.generateCodeString());
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(24)),
        child: Column(
          children: [
            _TokenHeader(config: config),
            const Spacer(),
            _TokenCodeRow(config: config, isVisible: isVisible),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCopy(BuildContext context, TokenItem controller, String code) async {
    await controller.copyCode(code);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.codeCopied), duration: const Duration(milliseconds: 1200)));
  }
}

class _TokenHeader extends StatelessWidget {
  const _TokenHeader({required this.config});

  final AuthEntry config;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer),
              ),
              Text(
                config.account,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8)),
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
      decoration: BoxDecoration(color: theme.colorScheme.primary, borderRadius: BorderRadius.circular(12)),
      child: SvgPicture.asset(iconPath, width: 28, height: 28, colorFilter: ColorFilter.mode(theme.colorScheme.onPrimary, BlendMode.srcIn)),
    );
  }
}

class _TokenAction extends ConsumerWidget {
  const _TokenAction({required this.config});

  final AuthEntry config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (config.type == 'hotp') {
      final itemState = ref.watch(tokenItemProvider(config.id));
      return IconButton(onPressed: itemState.isUpdating ? null : () => ref.read(tokenItemProvider(config.id).notifier).incrementHotp(config), icon: const Icon(Icons.refresh));
    }
    return _OtpTimer(period: config.period);
  }
}

class _TokenCodeRow extends StatelessWidget {
  const _TokenCodeRow({required this.config, required this.isVisible});

  final AuthEntry config;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    return _OtpDisplay(config: config, isVisible: isVisible);
  }
}

class _OtpDisplay extends ConsumerWidget {
  const _OtpDisplay({required this.config, required this.isVisible});

  final AuthEntry config;
  final bool isVisible;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final code = config.generateCodeString();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: code.characters.map((String char) => _DigitBox(char: char, isVisible: isVisible)).toList(),
    );
  }
}

class _DigitBox extends StatelessWidget {
  const _DigitBox({required this.char, required this.isVisible});

  final String char;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 42,
      width: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: theme.colorScheme.tertiary, borderRadius: BorderRadius.circular(14)),
      child: Text(
        isVisible ? char : '-',
        style: TextStyle(
          fontSize: 38,
          color: theme.colorScheme.onTertiary,
          fontWeight: FontWeight.w900,
          fontFamily: 'VarelaRound',
          height: 1.0, // 强制行高与字号一致
        ),
        textHeightBehavior: const TextHeightBehavior(applyHeightToFirstAscent: false, applyHeightToLastDescent: false),
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
      key: ValueKey(DateTime.now().millisecondsSinceEpoch ~/ intervalMs), // 每当一个周期结束时重启动画
      tween: Tween(begin: 1.0, end: 0.0),
      duration: Duration(milliseconds: OTP.remainingMilliseconds(intervalMilliseconds: intervalMs)),
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
