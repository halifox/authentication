import 'package:flutter/material.dart';

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
