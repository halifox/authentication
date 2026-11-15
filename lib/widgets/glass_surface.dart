import 'package:authentication/widgets/glass_quality.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// A theme-aware glass surface that also works without shader initialization.
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

  /// Use the shader-free renderer for repeated surfaces in scrolling lists.
  final bool repeated;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return GlassCard(
      useOwnLayer: true,
      quality: repeated ? GlassQuality.minimal : appGlassQuality,
      shape: const LiquidRoundedSuperellipse(borderRadius: 24),
      settings: LiquidGlassSettings(
        glassColor: colors.primaryContainer.withValues(alpha: .8),
      ),
      padding: padding,
      margin: margin,
      child: DefaultTextStyle.merge(
        style: TextStyle(color: colors.onPrimaryContainer),
        child: child,
      ),
    );
  }
}

/// A grouped glass surface with automatic dividers between its rows.
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
    return GlassGroupedSection(
      header: header == null
          ? null
          : DefaultTextStyle.merge(
              style: Theme.of(context).textTheme.labelMedium!
                  .copyWith(color: colors.onSurfaceVariant),
              child: Semantics(header: true, child: header!),
            ),
      footer: footer == null
          ? null
          : DefaultTextStyle.merge(
              style: Theme.of(context).textTheme.bodySmall!
                  .copyWith(color: colors.onSurfaceVariant),
              child: footer!,
            ),
      margin: margin ?? EdgeInsets.zero,
      useOwnLayer: true,
      quality: appGlassQuality,
      shape: const LiquidRoundedSuperellipse(borderRadius: 24),
      settings: LiquidGlassSettings(
        glassColor: colors.primaryContainer.withValues(alpha: .8),
      ),
      children: children,
    );
  }
}
