import 'dart:typed_data';

import 'package:authentication/storage/database_provider.dart';
import 'package:authentication/storage/icon_pack.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:hooks_riverpod/hooks_riverpod.dart';

final iconPacksProvider = StreamProvider.autoDispose<List<IconPack>>(
  (ref) => ref.watch(appDatabaseProvider).watchIconPacks(),
);

class IconPackOperations extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<T> _run<T>(Future<T> Function() action) async {
    if (state.isLoading) throw StateError('Icon pack operation in progress.');
    state = const AsyncLoading();
    try {
      return await action();
    } finally {
      state = const AsyncData(null);
    }
  }

  Future<IconPack> parse(Uint8List bytes) =>
      _run(() => compute(parseIconPack, bytes));

  Future<void> save(IconPack pack) =>
      _run(() => ref.read(appDatabaseProvider).saveIconPack(pack));

  Future<void> delete(String name) =>
      _run(() => ref.read(appDatabaseProvider).deleteIconPack(name));
}

final iconPackOperationsProvider =
    NotifierProvider<IconPackOperations, AsyncValue<void>>(
      IconPackOperations.new,
    );
