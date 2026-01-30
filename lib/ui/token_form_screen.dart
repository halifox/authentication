import 'package:auth/db/auth_entries_ext.dart';
import 'package:auth/db/database.dart';
import 'package:auth/l10n/generated/app_localizations.dart';
import 'package:auth/providers/token_form_controller.dart';
import 'package:auth/router/app_router.dart';
import 'package:auth/ui/action_result_sheet.dart';
import 'package:auth/ui/custom_app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 令牌编辑/表单页面，用于手动输入或编辑 2FA 账号的详细配置信息。
class TokenFormScreen extends HookConsumerWidget {
  const TokenFormScreen({super.key, this.initialEntry});

  final AuthEntry? initialEntry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = initialEntry;
    final l10n = AppLocalizations.of(context)!;

    // Controllers
    final issuerController = useTextEditingController(text: args?.issuer ?? '');
    final accountController = useTextEditingController(text: args?.account ?? '');
    final secretController = useTextEditingController(text: args?.secret ?? '');
    final pinController = useTextEditingController(text: args?.pin ?? '');
    final digitsController = useTextEditingController(text: (args?.digits ?? 6).toString());
    final periodController = useTextEditingController(text: (args?.period ?? 30).toString());
    final counterController = useTextEditingController(text: (args?.counter ?? 0).toString());

    // State
    final type = useState(args?.type ?? 'totp');
    final algorithm = useState(args?.algorithm ?? 'sha1');
    final icon = useState(args?.icon ?? 'assets/icons/passkey.svg');
    final obscureText = useState(true);

    final typeLabels = useMemoized(() => {
      'totp': l10n.totp,
      'hotp': l10n.hotp,
      'motp': l10n.motp,
    }, [l10n]);

    final algorithmLabels = useMemoized(() => {
      'sha1': l10n.sha1,
      'sha256': l10n.sha256,
      'sha512': l10n.sha512,
    }, [l10n]);

    return Scaffold(
      appBar: CustomAppBar(
        title: l10n.enterProvidedKey,
        rightIcon: Icons.save,
        rightOnPressed: (_) async {
          await _handleSave(
            context: context,
            ref: ref,
            id: args?.id,
            type: type.value,
            issuer: issuerController.text,
            account: accountController.text,
            secret: secretController.text,
            algorithm: algorithm.value,
            digits: int.tryParse(digitsController.text) ?? 6,
            period: int.tryParse(periodController.text) ?? 30,
            counter: int.tryParse(counterController.text) ?? 0,
            pin: pinController.text,
            icon: icon.value,
          );
        },
      ),
      body: SizedBox.expand(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Column(
              spacing: 16,
              children: [
                _buildDropdown<String>(l10n.type, type.value, typeLabels, (value) => type.value = value),
                _buildTextField(
                  label: l10n.issuer,
                  controller: issuerController,
                  suffixIcon: _buildIcon(context, icon.value, (newIcon) => icon.value = newIcon),
                ),
                _buildTextField(label: l10n.account, controller: accountController),
                _buildPasswordTextField(secretController, l10n.secret, obscureText),
                switch (type.value.toLowerCase()) {
                  'totp' || 'hotp' => _buildDropdown<String>(l10n.algorithm, algorithm.value, algorithmLabels, (value) => algorithm.value = value),
                  'motp' => _buildTextField(label: l10n.pin, controller: pinController),
                  String() => const SizedBox.shrink(),
                },
                Row(
                  spacing: 16,
                  children: <Widget>[
                    Expanded(child: _buildDigitsOnlyTextField(digitsController, l10n.digits)),
                    Expanded(
                      child: switch (type.value.toLowerCase()) {
                        'totp' || 'motp' => _buildDigitsOnlyTextField(periodController, l10n.period),
                        'hotp' => _buildDigitsOnlyTextField(counterController, l10n.counter),
                        String() => const SizedBox.shrink(),
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDigitsOnlyTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14.0))),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
    );
  }

  Widget _buildTextField({required String label, TextEditingController? controller, Widget? suffixIcon}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14.0))),
        suffixIcon: suffixIcon,
      ),
    );
  }

  Widget _buildPasswordTextField(TextEditingController controller, String label, ValueNotifier<bool> obscureText) => TextField(
    controller: controller,
    obscureText: obscureText.value,
    decoration: InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14.0))),
      suffixIcon: IconButton(
        icon: Icon(obscureText.value ? Icons.visibility_off : Icons.visibility),
        onPressed: () => obscureText.value = !obscureText.value,
      ),
    ),
  );

  Widget _buildDropdown<T>(String label, T initialValue, Map<T, String> options, void Function(T) onChanged) => DropdownMenuFormField<T>(
    width: double.infinity,
    label: Text(label),
    initialSelection: initialValue,
    dropdownMenuEntries: options.entries.map((MapEntry<T, String> entry) => DropdownMenuEntry(value: entry.key, label: entry.value)).toList(),
    inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14.0)))),
    onSelected: (value) {
      if (value != null) {
        onChanged(value);
      }
    },
  );

  Widget _buildIcon(BuildContext context, String icon, void Function(String) onChange) => Padding(
    padding: const EdgeInsets.all(6.0),
    child: GestureDetector(
      onTap: () async {
        final iconPath = await context.pushNamed(AppRoutes.iconsName);
        if (iconPath != null) {
          onChange(iconPath as String);
        }
      },
      child: Container(
        height: 44,
        width: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(10)),
        child: SvgPicture.asset(icon, width: 28, height: 28, colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.onPrimary, BlendMode.srcIn)),
      ),
    ),
  );

      

  Future<void> _handleSave({
    required BuildContext context,
    required WidgetRef ref,
    required int? id,
    required String type,
    required String issuer,
    required String account,
    required String secret,
    required String algorithm,
    required int digits,
    required int period,
    required int counter,
    required String pin,
    required String icon,
    bool forceUpdate = false,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = ref.read(tokenFormControllerProvider.notifier);

    try {
      final result = await controller.onSave(
        id: id,
        type: type,
        issuer: issuer,
        account: account,
        secret: secret,
        algorithm: algorithm,
        digits: digits,
        period: period,
        counter: counter,
        pin: pin,
        icon: icon,
        forceUpdate: forceUpdate,
      );

      if (!context.mounted) return;

      if (result is TokenFormSuccess) {
        if (context.mounted) {
          context.go(AppRoutes.home);
          await showCupertinoModalPopup(
            context: context,
            builder: (ctx) => ActionResultSheet(
              state: 1,
              title: l10n.tip,
              message: id == null ? l10n.addSuccess : l10n.updateSuccess,
            ),
          );
        }
      } else if (result is TokenFormConflict) {
        if (context.mounted) {
          final confirm = await showCupertinoModalPopup<bool>(
            context: context,
            builder: (ctx) => ActionResultSheet(
              state: 0,
              title: l10n.warning,
              message: l10n.tokenExists(result.pending.issuer.value, result.pending.account.value),
              falseButtonVisible: true,
            ),
          );

          if (confirm == true && context.mounted) {
            await _handleSave(
              context: context,
              ref: ref,
              id: id,
              type: type,
              issuer: issuer,
              account: account,
              secret: secret,
              algorithm: algorithm,
              digits: digits,
              period: period,
              counter: counter,
              pin: pin,
              icon: icon,
              forceUpdate: true,
            );
          }
        }
      } else if (result is TokenFormError) {
        if (context.mounted) {
          await showCupertinoModalPopup(
            context: context,
            builder: (ctx) => ActionResultSheet(
              state: 0,
              title: l10n.saveFailed,
              message: result.code.getLocalizedMessage(context),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        await showCupertinoModalPopup(
          context: context,
          builder: (ctx) => ActionResultSheet(state: 0, title: l10n.saveFailed, message: e.toString()),
        );
      }
    }
  }
}

  