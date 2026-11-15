import 'package:authentication/storage/database_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final recentSearchesProvider = StreamProvider<List<String>>(
  (ref) => ref.watch(appDatabaseProvider).watchRecentSearches(),
);

final searchHistoryOperationsProvider =
    NotifierProvider<SearchHistoryOperations, AsyncValue<void>>(
      SearchHistoryOperations.new,
    );

class SearchHistoryOperations extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> _run(Future<void> Function() action) async {
    if (state.isLoading) return false;
    state = const AsyncLoading();
    final result = await AsyncValue.guard(action);
    if (!ref.mounted) return false;
    state = result;
    return !state.hasError;
  }

  Future<bool> remember(String query) =>
      _run(() => ref.read(appDatabaseProvider).rememberSearch(query));

  Future<bool> remove(String query) =>
      _run(() => ref.read(appDatabaseProvider).removeRecentSearch(query));

  Future<bool> clear() =>
      _run(() => ref.read(appDatabaseProvider).clearRecentSearches());
}
