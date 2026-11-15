import 'package:authentication/widgets/glass_quality.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

Future<T?> showAppChoiceSheet<T>({
  required BuildContext context,
  required String title,
  required Map<T, String> options,
  T? value,
}) async {
  return GlassSheet.show<T>(
    context: context,
    quality: appGlassQuality,
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
    builder: (sheetContext) => DefaultTextStyle(
      style: Theme.of(context).textTheme.bodyLarge!,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Semantics(
              header: true,
              child: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
          ),
          for (final option in options.entries)
            GlassListTile(
              title: Text(option.value),
              leading: Icon(
                Icons.check,
                color: value == option.key
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
              ),
              onTap: () => Navigator.pop(sheetContext, option.key),
            ),
          GlassListTile(
            title: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            onTap: () => Navigator.pop(sheetContext),
          ),
        ],
      ),
    ),
  );
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
    return GlassContainer.card(
      surfaceStyle: GlassSurfaceStyle.solid,
      color: colors.surfaceContainerLow,
      padding: padding,
      margin: margin,
      child: DefaultTextStyle.merge(
        style: TextStyle(color: colors.onSurface),
        child: child,
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
  final String? title;
  final Widget? content;
  final List<GlassDialogAction> actions;

  @override
  Widget build(BuildContext context) => actions.isNotEmpty
      ? DefaultTextStyle(
          style: Theme.of(context).textTheme.bodyLarge!,
          child: GlassDialog(
            title: title,
            content: content,
            actions: actions,
            quality: appGlassQuality,
            maxWidth: 440,
          ),
        )
      : SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: GlassContainer(
                  useOwnLayer: true,
                  quality: appGlassQuality,
                  padding: const EdgeInsets.all(24),
                  child: DefaultTextStyle(
                    style: Theme.of(context).textTheme.bodyLarge!,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (title != null) Text(title!),
                        if (content != null) content!,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
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
    return GlassGroupedSection(
      surfaceStyle: GlassSurfaceStyle.solid,
      margin: margin ?? EdgeInsets.zero,
      header: header,
      footer: footer,
      children: children,
    );
  }
}
