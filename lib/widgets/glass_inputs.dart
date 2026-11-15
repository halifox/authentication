import 'package:authentication/l10n/generated/app_localizations.dart';
import 'package:authentication/widgets/glass_quality.dart';
import 'package:authentication/widgets/glass_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

void showAppToast(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 3),
}) {
  GlassToast.show(
    context,
    message: message,
    type: GlassToastType.neutral,
    quality: appGlassQuality,
    duration: duration,
  );
}

/// Shared labels and validation around the library's native input well.
class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.label,
    this.controller,
    this.focusNode,
    this.errorText,
    this.helperText,
    this.suffixIcon,
    this.onSuffixTap,
    this.suffixTooltip,
    this.enabled = true,
    this.obscureText = false,
    this.sensitive = false,
    this.autofocus = false,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.maxLength,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    super.key,
  });

  final String label;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? errorText;
  final String? helperText;
  final Widget? suffixIcon;
  final VoidCallback? onSuffixTap;
  final String? suffixTooltip;
  final bool enabled;
  final bool obscureText;
  final bool sensitive;
  final bool autofocus;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) => GlassFormField(
    label: label,
    errorText: errorText,
    helperText: helperText,
    child: Semantics(
      label: label,
      child: GlassTextField(
        controller: controller,
        focusNode: focusNode,
        enabled: enabled,
        autofocus: autofocus,
        obscureText: obscureText,
        keyboardType:
            keyboardType ??
            (sensitive ? TextInputType.visiblePassword : TextInputType.text),
        textInputAction: textInputAction,
        maxLength: maxLength,
        inputFormatters: inputFormatters,
        suffixIcon: onSuffixTap == null
            ? suffixIcon
            : GlassButton.custom(
                onTap: onSuffixTap!,
                enabled: enabled,
                width: 44,
                height: 44,
                style: GlassButtonStyle.transparent,
                quality: appGlassQuality,
                label:
                    suffixTooltip ??
                    (obscureText
                        ? AppLocalizations.of(context)!.revealPassword
                        : AppLocalizations.of(context)!.hidePassword),
                child: suffixIcon,
              ),
        surfaceStyle: GlassSurfaceStyle.solid,
        minHeight: 52,
        textStyle: Theme.of(context).textTheme.bodyLarge,
        onChanged: onChanged,
        onSubmitted:
            onSubmitted ??
            (_) {
              if (textInputAction == TextInputAction.next) {
                FocusScope.of(context).nextFocus();
              } else {
                FocusScope.of(context).unfocus();
              }
            },
      ),
    ),
  );
}

/// Floating actions use the library's button physics and disabled semantics.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.onPressed,
    required this.child,
    this.icon,
    this.prominent = true,
    this.destructive = false,
    super.key,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final Widget? icon;
  final bool prominent;
  final bool destructive;

  @override
  Widget build(BuildContext context) => GlassButton.custom(
    onTap: () => onPressed?.call(),
    enabled: onPressed != null,
    style: prominent
        ? GlassButtonStyle.prominent
        : GlassButtonStyle.transparent,
    quality: appGlassQuality,
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 50, minWidth: 50),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: DefaultTextStyle.merge(
          style: TextStyle(
            color: destructive
                ? Theme.of(context).colorScheme.error
                : prominent
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.primary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          child: icon == null
              ? child
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    icon!,
                    const SizedBox(width: 8),
                    Flexible(child: child),
                  ],
                ),
        ),
      ),
    ),
  );
}

class AppPickerField<T> extends StatelessWidget {
  const AppPickerField({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    super.key,
  });
  final String label;
  final T value;
  final Map<T, String> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => GlassFormField(
    label: label,
    child: GlassPicker(
      value: options[value],
      semanticLabel: label,
      surfaceStyle: GlassSurfaceStyle.solid,
      onTap: () async {
        final selection = await showAppChoiceSheet<T>(
          context: context,
          title: label,
          value: value,
          options: options,
        );
        if (context.mounted && selection != null) onChanged(selection);
      },
    ),
  );
}
