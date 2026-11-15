import 'package:authentication/widgets/glass_quality.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

Future<T?> showAppChoiceSheet<T>({
  required BuildContext context,
  required String title,
  required Map<T, String> options,
  T? value,
}) async {
  T? selection;
  await showGlassActionSheet<void>(
    context: context,
    title: title,
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
          onPressed: () => selection = option.key,
        ),
    ],
  );
  // Complete the sheet route before an action can open another dialog or page.
  return selection;
}

/// An opaque content surface beneath the glass navigation and control layer.
class AppGlassCard extends StatelessWidget {
  const AppGlassCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.repeated = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  /// Retained for account-list callers; all content surfaces are shader-free.
  final bool repeated;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Material(
        color: colors.surfaceContainerLow,
        shape: const RoundedSuperellipseBorder(
          borderRadius: BorderRadius.all(Radius.circular(26)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: padding,
          child: DefaultTextStyle.merge(
            style: TextStyle(color: colors.onSurface),
            child: child,
          ),
        ),
      ),
    );
  }
}

class AppSwitchTile extends StatelessWidget {
  const AppSwitchTile({
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
    super.key,
  });

  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Widget? subtitle;

  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    toggled: value,
    enabled: onChanged != null,
    onTap: onChanged == null ? null : () => onChanged!(!value),
    child: ExcludeSemantics(
      child: ExcludeFocus(
        excluding: onChanged == null,
        child: IgnorePointer(
          ignoring: onChanged == null,
          child: Opacity(
            opacity: onChanged == null ? .5 : 1,
            child: GlassListTile(
              title: Text(label),
              subtitle: subtitle,
              titleStyle: Theme.of(context).textTheme.bodyLarge,
              onTap: () => onChanged?.call(!value),
              trailing: GlassSwitch(
                value: value,
                onChanged: (next) => onChanged?.call(next),
                activeColor: Theme.of(context).colorScheme.primary,
                quality: appGlassQuality,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class AppChoiceTile<T> extends StatelessWidget {
  const AppChoiceTile({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    super.key,
  });

  final String label;
  final T value;
  final Map<T, String> options;
  final ValueChanged<T>? onChanged;

  @override
  Widget build(BuildContext context) => GlassListTile(
    title: Text(label),
    titleStyle: Theme.of(context).textTheme.bodyLarge,
    subtitle: Text(options[value] ?? ''),
    subtitleStyle: Theme.of(context).textTheme.bodyMedium
        ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
    trailing: const Icon(Icons.unfold_more, size: 20),
    onTap: onChanged == null
        ? null
        : () async {
            final selection = await showAppChoiceSheet<T>(
              context: context,
              title: label,
              value: value,
              options: options,
            );
            if (context.mounted && selection != null) {
              onChanged?.call(selection);
            }
          },
  );
}

/// A keyboard-aware glass dialog shared by confirmations and small forms.
class AppDialog extends StatelessWidget {
  const AppDialog({
    this.title,
    this.content,
    this.actions = const [],
    super.key,
  });

  final Widget? title;
  final Widget? content;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: GlassContainer(
          useOwnLayer: true,
          quality: appGlassQuality,
          shape: const LiquidRoundedSuperellipse(borderRadius: 28),
          settings: LiquidGlassSettings(
            glassColor: colors.surfaceContainerHigh.withValues(alpha: .9),
          ),
          padding: const EdgeInsets.all(24),
          child: Material(
            type: MaterialType.transparency,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (title != null) ...[
                  DefaultTextStyle.merge(
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
                    child: Semantics(namesRoute: true, child: title!),
                  ),
                  const SizedBox(height: 16),
                ],
                if (content != null)
                  Flexible(child: SingleChildScrollView(child: content!)),
                if (actions.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  OverflowBar(
                    alignment: MainAxisAlignment.end,
                    overflowAlignment: OverflowBarAlignment.end,
                    spacing: 8,
                    overflowSpacing: 8,
                    children: actions,
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

/// Inset grouped content. Controls can lift above this non-refracting surface.
class AppGlassGroup extends StatelessWidget {
  const AppGlassGroup({
    required this.children,
    super.key,
    this.header,
    this.footer,
    this.margin,
  });

  final List<Widget> children;
  final Widget? header;
  final Widget? footer;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (header != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: DefaultTextStyle.merge(
                style: Theme.of(context).textTheme.labelMedium!
                    .copyWith(color: colors.onSurfaceVariant),
                child: Semantics(header: true, child: header!),
              ),
            ),
          AppGlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var index = 0; index < children.length; index++) ...[
                  if (index > 0)
                    Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: colors.outlineVariant.withValues(alpha: .45),
                    ),
                  children[index],
                ],
              ],
            ),
          ),
          if (footer != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: DefaultTextStyle.merge(
                style: Theme.of(context).textTheme.bodySmall!
                    .copyWith(color: colors.onSurfaceVariant),
                child: footer!,
              ),
            ),
        ],
      ),
    );
  }
}
