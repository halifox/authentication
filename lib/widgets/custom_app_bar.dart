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
  Widget build(BuildContext context) => buildBar(context);

  GlassAppBar buildBar(
    BuildContext context, {
    GlassLargeTitleController? titleController,
  }) => GlassAppBar(
    toolbarHeight: 56,
    largeTitleController: titleController,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    title: Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    ),
    leading: leftIcon == null
        ? null
        : AppBarIconButton(
            icon: leftIcon,
            tooltip:
                leftTooltip ??
                (leftIcon == Icons.arrow_back
                    ? MaterialLocalizations.of(context).backButtonTooltip
                    : null),
            onPressed: leftOnPressed == null
                ? null
                : () => leftOnPressed!(context),
          ),
    actions: [
      if (rightIcon != null)
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
  Size get preferredSize => const Size.fromHeight(56);
}

class AppBarIconButton extends StatelessWidget {
  const AppBarIconButton({super.key, this.icon, this.onPressed, this.tooltip});
  final IconData? icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    if (icon == null) return const SizedBox(width: 44, height: 44);
    final colors = Theme.of(context).colorScheme;
    final button = GlassIconButton(
      icon: Icon(icon, color: colors.onSurface),
      onPressed: onPressed,
      semanticLabel: tooltip,
      size: 44,
      iconSize: 22,
      shape: GlassIconButtonShape.circle,
      useOwnLayer: true,
      quality: appGlassQuality,
      settings: LiquidGlassSettings(
        glassColor: colors.surfaceContainer.withValues(alpha: .65),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}

/// A glass menu anchored to a floating navigation control.
class AppMenuButton<T> extends StatelessWidget {
  const AppMenuButton({
    required this.icon,
    required this.tooltip,
    required this.options,
    required this.onSelected,
    this.value,
    super.key,
  });

  final IconData icon;
  final String tooltip;
  final Map<T, String> options;
  final T? value;
  final ValueChanged<T>? onSelected;

  @override
  Widget build(BuildContext context) => AppBarIconButton(
    icon: icon,
    tooltip: tooltip,
    onPressed: onSelected == null
        ? null
        : () => showGlassActionSheet<void>(
            context: context,
            title: tooltip,
            quality: appGlassQuality,
            cancelLabel: MaterialLocalizations.of(context).cancelButtonLabel,
            actions: [
              for (final option in options.entries)
                GlassActionSheetAction(
                  label: option.value,
                  icon: Icon(
                    Icons.check,
                    color: value == option.key
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                  ),
                  onPressed: () => onSelected?.call(option.key),
                ),
            ],
          ),
  );
}
