import 'package:authentication/storage/database.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// The initialized database is supplied by application startup.
final appDatabaseProvider = Provider<AppDatabase>(
  (ref) => throw StateError('Database has not been initialized.'),
);
