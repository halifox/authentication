import 'package:pureotp/db/database.dart';
import 'package:pureotp/providers/database_provider.dart';
import 'package:pureotp/repository/repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository_provider.g.dart';

/// 提供 [AuthRepository] 的单例实例，确保数据库访问。
@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return AuthRepository(db);
}

/// 流提供者，用于监听仓库中的认证条目列表。
@riverpod
Stream<List<AuthEntry>> authEntryList(Ref ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authConfigsStream;
}
