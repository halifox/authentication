import 'package:authentication/widgets/glass_quality.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// Shared navigation bar with balanced leading and trailing controls.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    required this.title,
    super.key,
    this.leftIcon = Icons.arrow_back,
    this.leftOnPressed = _defaultLeftOnPressed,
    this.rightIcon,
    this.rightOnPressed,
    this.leftTooltip,
    this.rightTooltip,
  });

  final String title;
  final IconData? leftIcon;
  final void Function(BuildContext context)? leftOnPressed;
  final IconData? rightIcon;
  final void Function(BuildContext context)? rightOnPressed;
  final String? leftTooltip;
  final String? rightTooltip;

  static void _defaultLeftOnPressed(BuildContext context) =>
      Navigator.pop(context);

  @override
  Widget build(BuildContext context) => GlassAppBar(
    toolbarHeight: 96,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    title: Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    ),
    leading: AppBarIconButton(
      icon: leftIcon,
      tooltip:
          leftTooltip ??
          (leftIcon == Icons.arrow_back
              ? MaterialLocalizations.of(context).backButtonTooltip
              : null),
      onPressed: leftOnPressed == null ? null : () => leftOnPressed!(context),
    ),
    actions: [
      AppBarIconButton(
        icon: rightIcon,
        tooltip: rightTooltip,
        onPressed: rightOnPressed == null
            ? null
            : () => rightOnPressed!(context),
      ),
    ],
  );

  @override
  Size get preferredSize => const Size.fromHeight(96);
}

class AppBarIconButton extends StatelessWidget {
  const AppBarIconButton({super.key, this.icon, this.onPressed, this.tooltip});
  final IconData? icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    if (icon == null) return const SizedBox(width: 64, height: 64);
    final colors = Theme.of(context).colorScheme;
    final button = GlassIconButton(
      icon: Icon(icon, color: colors.onPrimaryContainer),
      onPressed: onPressed,
      semanticLabel: tooltip,
      size: 64,
      iconSize: 30,
      shape: GlassIconButtonShape.roundedSquare,
      borderRadius: 24,
      useOwnLayer: true,
      quality: appGlassQuality,
      settings: LiquidGlassSettings(
        glassColor: colors.primaryContainer.withValues(alpha: .8),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}
