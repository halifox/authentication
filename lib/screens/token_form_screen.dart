import 'package:authentication/actions/account_actions.dart';
import 'package:authentication/l10n/generated/app_localizations.dart';
import 'package:authentication/otp/account.dart';
import 'package:authentication/otp/category_provider.dart';
import 'package:authentication/otp/otp_provider.dart';
import 'package:authentication/router/app_router.dart';
import 'package:authentication/screens/auth_error_localization.dart';
import 'package:authentication/screens/icon_selection_provider.dart';
import 'package:authentication/widgets/account_qr.dart';
import 'package:authentication/widgets/action_result_sheet.dart';
import 'package:authentication/widgets/category_selection.dart';
import 'package:authentication/widgets/custom_app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 令牌编辑/表单页面，用于手动输入或编辑 2FA 账号的详细配置信息。
class TokenFormScreen extends HookConsumerWidget {
  const TokenFormScreen({super.key, this.initialEntry});

  final OtpAccount? initialEntry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(categoriesProvider);
    ref.watch(categoryMembershipsProvider);
    final args = initialEntry;
    final busy = ref.watch(accountOperationsProvider).isLoading;
    final l10n = AppLocalizations.of(context)!;

    // Controllers
    final issuerController = useTextEditingController(text: args?.issuer ?? '');
    useListenable(issuerController);
    final accountController = useTextEditingController(
      text: args?.account ?? '',
    );
    final secretController = useTextEditingController(text: args?.secret ?? '');
    final pinController = useTextEditingController(text: args?.pin ?? '');
    final digitsController = useTextEditingController(
      text: (args?.digits ?? 6).toString(),
    );
    final periodController = useTextEditingController(
      text: (args?.period ?? 30).toString(),
    );
    final counterController = useTextEditingController(
      text: (args?.counter ?? 0).toString(),
    );

    // State
    final type = useState(args?.type ?? 'totp');
    final algorithm = useState(args?.algorithm ?? 'sha1');
    final icon = useState<String?>(args?.icon);
    final icons = ref.watch(allIconsProvider);
    final chosenIcon =
        icon.value ??
        matchBuiltInIcon(issuerController.text, icons.value ?? const []) ??
        'assets/icons/passkey.svg';
    final obscureText = useState(true);

    final typeLabels = useMemoized(
      () => {
        'totp': l10n.totp,
        'hotp': l10n.hotp,
        'motp': l10n.motp,
        'steam': 'Steam',
        'yandex': 'Yandex',
      },
      [l10n],
    );

    final algorithmLabels = useMemoized(
      () => {'sha1': l10n.sha1, 'sha256': l10n.sha256, 'sha512': l10n.sha512},
      [l10n],
    );

    return Scaffold(
      appBar: CustomAppBar(
        title: l10n.enterProvidedKey,
        rightIcon: Icons.save,
        rightOnPressed: busy || (icon.value == null && icons.isLoading)
            ? null
            : (_) async {
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
                  icon: chosenIcon,
                  preserveExistingIcon: icon.value == null,
                );
              },
      ),
      body: SizedBox.expand(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Column(
              spacing: 16,
              children: [
                _buildDropdown<String>(l10n.type, type.value, typeLabels, (
                  value,
                ) {
                  type.value = value;
                  digitsController.text = switch (value) {
                    'steam' => '5',
                    'yandex' => '8',
                    _ => '6',
                  };
                  if (value == 'steam' || value == 'yandex') {
                    periodController.text = '30';
                  }
                }),
                _buildTextField(
                  label: l10n.issuer,
                  controller: issuerController,
                  suffixIcon: _buildIcon(
                    context,
                    chosenIcon,
                    (newIcon) => icon.value = newIcon,
                  ),
                ),
                _buildTextField(
                  label: l10n.account,
                  controller: accountController,
                ),
                _buildPasswordTextField(
                  secretController,
                  l10n.secret,
                  obscureText,
                ),
                switch (type.value.toLowerCase()) {
                  'totp' || 'hotp' => _buildDropdown<String>(
                    l10n.algorithm,
                    algorithm.value,
                    algorithmLabels,
                    (value) => algorithm.value = value,
                  ),
                  'motp' || 'yandex' => _buildTextField(
                    label: l10n.pin,
                    controller: pinController,
                  ),
                  String() => const SizedBox.shrink(),
                },
                if (args != null)
                  OutlinedButton.icon(
                    onPressed: busy
                        ? null
                        : () => assignAccountCategories(context, ref, args.id),
                    icon: const Icon(Icons.label_outline),
                    label: Text(l10n.assignCategories),
                  ),
                if (args != null)
                  OutlinedButton.icon(
                    onPressed: busy
                        ? null
                        : () => _showAccountQr(context, ref, args.id),
                    icon: const Icon(Icons.qr_code),
                    label: Text(l10n.showSavedAccountQr),
                  ),
                Row(
                  spacing: 16,
                  children: <Widget>[
                    Expanded(
                      child: _buildDigitsOnlyTextField(
                        digitsController,
                        l10n.digits,
                      ),
                    ),
                    Expanded(
                      child: switch (type.value.toLowerCase()) {
                        'totp' ||
                        'motp' ||
                        'steam' ||
                        'yandex' => _buildDigitsOnlyTextField(
                          periodController,
                          l10n.period,
                        ),
                        'hotp' => _buildDigitsOnlyTextField(
                          counterController,
                          l10n.counter,
                        ),
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

  Future<void> _showAccountQr(
    BuildContext context,
    WidgetRef ref,
    int id,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final account = await ref
          .read(accountOperationsProvider.notifier)
          .getAccount(id);
      if (!context.mounted) return;
      if (account == null) {
        await showDialog<void>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(l10n.warning),
            content: Text(l10n.qrAccountUnavailable),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.ok),
              ),
            ],
          ),
        );
        return;
      }
      if (account.type.toLowerCase() != 'totp' &&
          account.type.toLowerCase() != 'hotp') {
        await showDialog<void>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(l10n.warning),
            content: Text(l10n.qrUnsupportedAccount),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.ok),
              ),
            ],
          ),
        );
        return;
      }
      try {
        toStandardOtpQrUri(account);
      } on FormatException {
        await showDialog<void>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(l10n.warning),
            content: Text(l10n.qrUnsupportedParameters),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(l10n.ok),
              ),
            ],
          ),
        );
        return;
      }
      if (!context.mounted) return;
      final proceed = await showCupertinoModalPopup<bool>(
        context: context,
        builder: (_) => ActionResultSheet(
          state: 0,
          title: l10n.warning,
          message: l10n.qrSecretWarning,
          falseButtonVisible: true,
        ),
      );
      if (proceed != true || !context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.showSavedAccountQr),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.qrSecretWarning),
                const SizedBox(height: 16),
                SizedBox(
                  width: 320,
                  height: 320,
                  child: AccountQr(account: account),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.ok),
            ),
          ],
        ),
      );
    } catch (_) {
      if (context.mounted) {
        await showDialog<void>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(l10n.warning),
            content: Text(l10n.qrAccountUnavailable),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(l10n.ok),
              ),
            ],
          ),
        );
      }
    }
  }

  Widget _buildDigitsOnlyTextField(
    TextEditingController controller,
    String label,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14.0)),
        ),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    TextEditingController? controller,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14.0)),
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }

  Widget _buildPasswordTextField(
    TextEditingController controller,
    String label,
    ValueNotifier<bool> obscureText,
  ) => TextField(
    controller: controller,
    obscureText: obscureText.value,
    decoration: InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14.0)),
      ),
      suffixIcon: IconButton(
        icon: Icon(obscureText.value ? Icons.visibility_off : Icons.visibility),
        onPressed: () => obscureText.value = !obscureText.value,
      ),
    ),
  );

  Widget _buildDropdown<T>(
    String label,
    T initialValue,
    Map<T, String> options,
    void Function(T) onChanged,
  ) => DropdownMenuFormField<T>(
    width: double.infinity,
    label: Text(label),
    initialSelection: initialValue,
    dropdownMenuEntries: options.entries
        .map(
          (MapEntry<T, String> entry) =>
              DropdownMenuEntry(value: entry.key, label: entry.value),
        )
        .toList(),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14.0)),
      ),
    ),
    onSelected: (value) {
      if (value != null) {
        onChanged(value);
      }
    },
  );

  Widget _buildIcon(
    BuildContext context,
    String icon,
    void Function(String) onChange,
  ) => Padding(
    padding: const EdgeInsets.all(6.0),
    child: GestureDetector(
      onTap: () async {
        final iconPath = await Navigator.pushNamed<String>(
          context,
          AppRoutes.icons,
        );
        if (iconPath != null) {
          onChange(iconPath);
        }
      },
      child: Container(
        height: 44,
        width: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: SvgPicture.asset(
          icon,
          width: 28,
          height: 28,
          colorFilter: ColorFilter.mode(
            Theme.of(context).colorScheme.onPrimary,
            BlendMode.srcIn,
          ),
        ),
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
    required bool preserveExistingIcon,
    bool forceUpdate = false,
  }) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      final result = await ref
          .read(accountOperationsProvider.notifier)
          .save(
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
            preserveExistingIcon: preserveExistingIcon,
            forceUpdate: forceUpdate,
          );

      if (!context.mounted) return;

      if (result is TokenFormSuccess) {
        if (context.mounted) {
          await showCupertinoModalPopup(
            context: context,
            builder: (ctx) => ActionResultSheet(
              state: 1,
              title: l10n.tip,
              message: id == null ? l10n.addSuccess : l10n.updateSuccess,
            ),
          );
          if (context.mounted) {
            Navigator.popUntil(context, (route) => route.isFirst);
          }
        }
      } else if (result is TokenFormConflict) {
        if (context.mounted) {
          final confirm = await showCupertinoModalPopup<bool>(
            context: context,
            builder: (ctx) => ActionResultSheet(
              state: 0,
              title: l10n.warning,
              message: l10n.tokenExists(
                result.pending.issuer,
                result.pending.account,
              ),
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
              preserveExistingIcon: preserveExistingIcon,
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
          builder: (ctx) => ActionResultSheet(
            state: 0,
            title: l10n.saveFailed,
            message: e.toString(),
          ),
        );
      }
    }
  }
}
