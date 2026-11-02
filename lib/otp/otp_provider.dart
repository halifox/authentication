import 'package:authentication/actions/account_actions.dart';
import 'package:authentication/actions/qr_actions.dart';
import 'package:authentication/otp/account.dart';
import 'package:authentication/storage/database_provider.dart';
import 'package:authentication/storage/database.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final authEntryListProvider = StreamProvider.autoDispose<List<OtpAccount>>(
  (ref) => ref.watch(appDatabaseProvider).authConfigsStream,
);

class AccountOperations extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<TokenFormResult> save({
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
    if (state.isLoading)
      throw StateError('An account operation is already running.');
    final db = ref.read(appDatabaseProvider);
    state = const AsyncLoading();
    try {
      final result = await saveAccount(
        db,
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
      state = const AsyncData(null);
      return result;
    } catch (error, stack) {
      state = AsyncError(error, stack);
      rethrow;
    }
  }

  Future<void> reorder(List<int> ids) async {
    if (state.isLoading)
      throw StateError('An account operation is already running.');
    state = const AsyncLoading();
    try {
      await ref.read(appDatabaseProvider).reorderAccounts(ids);
      state = const AsyncData(null);
    } catch (error, stack) {
      state = AsyncError(error, stack);
      rethrow;
    }
  }

  Future<QrProcessResult> scan(String uri, {bool forceUpdate = false}) async {
    if (state.isLoading)
      throw StateError('An account operation is already running.');
    final db = ref.read(appDatabaseProvider);
    state = const AsyncLoading();
    try {
      final result = await processQrCode(db, uri, forceUpdate: forceUpdate);
      state = const AsyncData(null);
      return result;
    } catch (error, stack) {
      state = AsyncError(error, stack);
      rethrow;
    }
  }
}

final accountOperationsProvider =
    NotifierProvider<AccountOperations, AsyncValue<void>>(
      AccountOperations.new,
    );
