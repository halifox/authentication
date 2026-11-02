import 'package:authentication/otp/category.dart';
import 'package:authentication/storage/database_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final categoriesProvider = StreamProvider.autoDispose<List<AccountCategory>>(
  (ref) => ref.watch(appDatabaseProvider).watchCategories(),
);

final categoryMembershipsProvider =
    StreamProvider.autoDispose<Map<int, Set<int>>>(
      (ref) => ref.watch(appDatabaseProvider).watchCategoryMemberships(),
    );

class CategoryOperations extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> run(Future<void> Function() action) async {
    if (state.isLoading) {
      throw StateError('A category operation is already running.');
    }
    state = const AsyncLoading();
    try {
      await action();
      state = const AsyncData(null);
    } catch (error, stack) {
      state = AsyncError(error, stack);
      rethrow;
    }
  }

  Future<void> create(String name) =>
      run(() => ref.read(appDatabaseProvider).createCategory(name));
  Future<void> rename(int id, String name) =>
      run(() => ref.read(appDatabaseProvider).renameCategory(id, name));
  Future<void> delete(int id) =>
      run(() => ref.read(appDatabaseProvider).deleteCategory(id));
  Future<void> setDefault(int? id) =>
      run(() => ref.read(appDatabaseProvider).setDefaultCategory(id));
  Future<void> assignAccount(
    int accountId,
    Set<int> categories,
    Set<int> expected,
  ) => run(
    () => ref
        .read(appDatabaseProvider)
        .setAccountCategories(accountId, categories, expected: expected),
  );
  Future<void> assignCategory(
    int categoryId,
    Set<int> accounts,
    Set<int> expected,
  ) => run(
    () => ref
        .read(appDatabaseProvider)
        .setCategoryAccounts(categoryId, accounts, expected: expected),
  );
  Future<void> reorder(List<int> ids) =>
      run(() => ref.read(appDatabaseProvider).reorderCategories(ids));
}

final categoryOperationsProvider =
    NotifierProvider<CategoryOperations, AsyncValue<void>>(
      CategoryOperations.new,
    );
