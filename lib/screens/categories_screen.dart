import 'package:authentication/l10n/generated/app_localizations.dart';
import 'package:authentication/otp/category.dart';
import 'package:authentication/otp/category_provider.dart';
import 'package:authentication/otp/otp_provider.dart';
import 'package:authentication/widgets/app_scaffold.dart';
import 'package:authentication/widgets/category_selection.dart';
import 'package:authentication/widgets/custom_app_bar.dart';
import 'package:authentication/widgets/glass_inputs.dart';
import 'package:authentication/widgets/glass_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final categories = ref.watch(categoriesProvider);
    ref.watch(categoryMembershipsProvider);
    ref.watch(authEntryListProvider);
    final busy = ref.watch(categoryOperationsProvider).isLoading;
    Future<void> execute(Future<void> Function() action) async {
      try {
        await action();
      } catch (_) {
        if (context.mounted) {
          showAppToast(context, l10n.categoryOperationFailed);
        }
      }
    }

    Future<void> edit([AccountCategory? category]) async {
      final result = await showDialog<String>(
        context: context,
        builder: (_) => _CategoryNameDialog(category: category),
      );
      if (result == null || !context.mounted) return;
      await execute(
        () => category == null
            ? ref.read(categoryOperationsProvider.notifier).create(result)
            : ref
                  .read(categoryOperationsProvider.notifier)
                  .rename(category.id, result),
      );
    }

    return AppScaffold(
      largeTitle: true,
      appBar: CustomAppBar(
        title: l10n.categories,
        rightIcon: Icons.add,
        rightTooltip: l10n.add,
        rightOnPressed: busy ? null : (_) => edit(),
      ),
      body: AppPageScrollView(
        slivers: [
          categories.when(
            loading: () => const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: GlassProgressIndicator.circular()),
            ),
            error: (_, _) => SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text(l10n.categoryLoadFailed)),
            ),
            data: (items) {
              if (items.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text(l10n.categoryEmpty)),
                );
              }
              return SliverReorderableList(
                itemCount: items.length,
                onReorderItem: (oldIndex, newIndex) async {
                  if (busy) return;
                  final ids = items.map((item) => item.id).toList();
                  ids.insert(newIndex, ids.removeAt(oldIndex));
                  await execute(
                    () => ref
                        .read(categoryOperationsProvider.notifier)
                        .reorder(ids),
                  );
                },
                itemBuilder: (context, index) {
                  final category = items[index];
                  return Padding(
                    key: ValueKey(category.id),
                    padding: const EdgeInsets.only(bottom: 16),
                    child: AppGlassCard(
                      padding: EdgeInsets.zero,
                      child: GlassListTile(
                        leading: const Icon(Icons.folder_outlined),
                        title: Text(
                          category.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: category.isDefault
                            ? Text(l10n.categoryDefault)
                            : null,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppMenuButton<int>(
                              icon: Icons.more_horiz,
                              tooltip: l10n.categoryActions,
                              onSelected: busy
                                  ? null
                                  : (action) async {
                                      if (action == 0) {
                                        await edit(category);
                                      } else if (action == 1) {
                                        await execute(
                                          () => ref
                                              .read(
                                                categoryOperationsProvider
                                                    .notifier,
                                              )
                                              .setDefault(
                                                category.isDefault
                                                    ? null
                                                    : category.id,
                                              ),
                                        );
                                      } else if (action == 3) {
                                        await assignCategoryAccounts(
                                          context,
                                          ref,
                                          category,
                                        );
                                      } else {
                                        final confirmed = await showDialog<bool>(
                                          context: context,
                                          builder: (dialogContext) => AppDialog(
                                            title: l10n.categoryDelete,
                                            content: Text(
                                              l10n.categoryDeleteWarning,
                                            ),
                                            actions: [
                                              GlassDialogAction(
                                                onPressed: () => Navigator.pop(
                                                  dialogContext,
                                                  false,
                                                ),
                                                label: l10n.cancel,
                                              ),
                                              GlassDialogAction(
                                                onPressed: () => Navigator.pop(
                                                  dialogContext,
                                                  true,
                                                ),
                                                label: l10n.ok,
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirmed == true &&
                                            context.mounted) {
                                          await execute(
                                            () => ref
                                                .read(
                                                  categoryOperationsProvider
                                                      .notifier,
                                                )
                                                .delete(category.id),
                                          );
                                        }
                                      }
                                    },
                              options: {
                                0: l10n.categoryRename,
                                1: category.isDefault
                                    ? l10n.categoryClearDefault
                                    : l10n.categorySetDefault,
                                2: l10n.categoryDelete,
                                3: l10n.assignAccounts,
                              },
                            ),
                            ReorderableDragStartListener(
                              index: index,
                              enabled: !busy,
                              child: Tooltip(
                                message: l10n.dragToReorder,
                                child: const SizedBox(
                                  width: 48,
                                  height: 64,
                                  child: Icon(Icons.drag_handle),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CategoryNameDialog extends HookWidget {
  const _CategoryNameDialog({this.category});

  final AccountCategory? category;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = useTextEditingController(text: category?.name ?? '');
    return AppDialog(
      title: category == null ? l10n.categoryCreate : l10n.categoryRename,
      content: AppTextField(
        controller: controller,
        autofocus: true,
        maxLength: 100,
        label: l10n.categoryName,
      ),
      actions: [
        GlassDialogAction(
          onPressed: () => Navigator.pop(context),
          label: l10n.cancel,
        ),
        GlassDialogAction(
          onPressed: () => Navigator.pop(context, controller.text),
          label: l10n.ok,
        ),
      ],
    );
  }
}
