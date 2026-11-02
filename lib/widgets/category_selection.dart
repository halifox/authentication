import 'package:authentication/l10n/generated/app_localizations.dart';
import 'package:authentication/otp/category.dart';
import 'package:authentication/otp/category_provider.dart';
import 'package:authentication/otp/otp_provider.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

Future<Set<int>?> _choose(
  BuildContext context,
  String title,
  Map<int, String> options,
  Set<int> initial,
) {
  final selected = {...initial};
  final l10n = AppLocalizations.of(context)!;
  return showDialog<Set<int>>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(title),
        content: options.isEmpty
            ? Text(l10n.categorySelectionEmpty)
            : SizedBox(
                width: 360,
                height: 300,
                child: ListView(
                  children: [
                    for (final option in options.entries)
                      CheckboxListTile(
                        value: selected.contains(option.key),
                        title: Text(option.value),
                        onChanged: (checked) => setState(() {
                          if (checked == true) {
                            selected.add(option.key);
                          } else {
                            selected.remove(option.key);
                          }
                        }),
                      ),
                  ],
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, selected),
            child: Text(l10n.ok),
          ),
        ],
      ),
    ),
  );
}

Future<void> assignAccountCategories(
  BuildContext context,
  WidgetRef ref,
  int accountId,
) async {
  final l10n = AppLocalizations.of(context)!;
  try {
    final categories = await ref.read(categoriesProvider.future);
    final memberships = await ref.read(categoryMembershipsProvider.future);
    if (!context.mounted) return;
    final initial = memberships[accountId] ?? <int>{};
    final selected = await _choose(context, l10n.assignCategories, {
      for (final category in categories) category.id: category.name,
    }, initial);
    if (selected == null || !context.mounted) return;
    await ref
        .read(categoryOperationsProvider.notifier)
        .assignAccount(accountId, selected, initial);
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.categoryOperationFailed)));
    }
  }
}

Future<void> assignCategoryAccounts(
  BuildContext context,
  WidgetRef ref,
  AccountCategory category,
) async {
  final l10n = AppLocalizations.of(context)!;
  try {
    final accounts = await ref.read(authEntryListProvider.future);
    final memberships = await ref.read(categoryMembershipsProvider.future);
    if (!context.mounted) return;
    final initial = {
      for (final entry in memberships.entries)
        if (entry.value.contains(category.id)) entry.key,
    };
    final selected = await _choose(context, l10n.assignAccounts, {
      for (final account in accounts)
        account.id: '${account.issuer} · ${account.account}',
    }, initial);
    if (selected == null || !context.mounted) return;
    await ref
        .read(categoryOperationsProvider.notifier)
        .assignCategory(category.id, selected, initial);
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.categoryOperationFailed)));
    }
  }
}
