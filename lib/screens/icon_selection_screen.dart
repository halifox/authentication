import 'package:authentication/actions/icon_pack_provider.dart';
import 'package:authentication/actions/icon_selection_provider.dart';
import 'package:authentication/backup/backup_provider.dart';
import 'package:authentication/l10n/generated/app_localizations.dart';
import 'package:authentication/storage/icon_data.dart';
import 'package:authentication/widgets/account_icon.dart';
import 'package:authentication/widgets/custom_app_bar.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class IconSelectionScreen extends ConsumerWidget {
  const IconSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final icons = ref.watch(filteredIconsProvider);
    final packs = ref.watch(iconPacksProvider);
    final query = ref.watch(iconSearchQueryProvider).trim().toLowerCase();
    final busy =
        ref.watch(iconPackOperationsProvider).isLoading ||
        ref.watch(backupOperationsProvider).isLoading;

    return Scaffold(
      appBar: CustomAppBar(title: l10n.selectIcon),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Wrap(
              spacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: busy ? null : () => _chooseImage(context, ref),
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: Text(l10n.chooseCustomIcon),
                ),
                OutlinedButton.icon(
                  onPressed: busy ? null : () => _importPack(context, ref),
                  icon: const Icon(Icons.file_upload_outlined),
                  label: Text(l10n.importIconPack),
                ),
              ],
            ),
          ),
          if (busy) const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              onChanged: (value) =>
                  ref.read(iconSearchQueryProvider.notifier).update(value),
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.always,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                ),
                prefixIcon: const Icon(Icons.search),
                hintText: l10n.search,
              ),
            ),
          ),
          Expanded(
            child: icons.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Center(child: Text(l10n.iconLoadError)),
              data: (builtIn) => packs.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => Center(child: Text(l10n.iconLoadError)),
                data: (items) => Scrollbar(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    slivers: [
                      for (final pack in items)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: ExpansionTile(
                              key: ValueKey('${pack.name}:$query'),
                              initiallyExpanded: query.isNotEmpty,
                              title: Text(pack.name),
                              subtitle: pack.description.isEmpty
                                  ? null
                                  : Text(pack.description),
                              trailing: IconButton(
                                tooltip: l10n.delete,
                                onPressed: busy
                                    ? null
                                    : () =>
                                          _deletePack(context, ref, pack.name),
                                icon: const Icon(Icons.delete_outline),
                              ),
                              children: [
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    for (final entry in pack.icons.entries)
                                      if (query.isEmpty ||
                                          entry.key.toLowerCase().contains(
                                            query,
                                          ))
                                        Tooltip(
                                          message: entry.key,
                                          child: InkWell(
                                            onTap: () => Navigator.pop(
                                              context,
                                              entry.value,
                                            ),
                                            child: SizedBox(
                                              width: 72,
                                              child: Column(
                                                children: [
                                                  AccountIcon(
                                                    icon: entry.value,
                                                    size: 48,
                                                  ),
                                                  Text(
                                                    entry.key,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverGrid.builder(
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 60,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                          itemCount: builtIn.length,
                          itemBuilder: (context, index) {
                            final path = 'assets/icons/${builtIn[index]}';
                            return InkWell(
                              onTap: () => Navigator.pop(context, path),
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: AccountIcon(icon: path),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _chooseImage(BuildContext context, WidgetRef ref) async {
    try {
      final bytes = await ref
          .read(backupOperationsProvider.notifier)
          .pickFile();
      if (bytes == null || !context.mounted) return;
      final icon = await compute(makeCustomIcon, bytes);
      if (context.mounted) Navigator.pop(context, icon);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.invalidCustomIcon),
          ),
        );
      }
    }
  }

  Future<void> _importPack(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final bytes = await ref
          .read(backupOperationsProvider.notifier)
          .pickFile();
      if (bytes == null || !context.mounted) return;
      final pack = await ref
          .read(iconPackOperationsProvider.notifier)
          .parse(bytes);
      if (!context.mounted) return;
      final proceed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.importIconPack),
          content: Text(
            l10n.iconPackImportConfirm(pack.name, pack.icons.length),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.ok),
            ),
          ],
        ),
      );
      if (proceed != true || !context.mounted) return;
      await ref.read(iconPackOperationsProvider.notifier).save(pack);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.iconPackImported)));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.iconPackError)));
      }
    }
  }

  Future<void> _deletePack(
    BuildContext context,
    WidgetRef ref,
    String name,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final proceed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.delete),
        content: Text(l10n.iconPackDeleteConfirm(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (proceed != true || !context.mounted) return;
    try {
      await ref.read(iconPackOperationsProvider.notifier).delete(name);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.iconPackError)));
      }
    }
  }
}
