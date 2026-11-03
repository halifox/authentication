import 'package:authentication/app.dart';
import 'package:authentication/settings/settings.dart';
import 'package:authentication/storage/database.dart';
import 'package:authentication/storage/database_provider.dart';
import 'package:authentication/storage/encryption.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  AppDatabase? database;
  try {
    final db = AppDatabase();
    database = db;
    db.encryption = await EncryptionService.initialize(db);
    final preferences = await SharedPreferences.getInstance();
    await db.initializeSettings({
      for (final setting in defaultSettings.entries)
        setting.key: preferences.getBool(setting.key) ?? setting.value,
    });
    runApp(
      ProviderScope(
        overrides: [
          introductionPreferencesProvider.overrideWithValue(preferences),
          appDatabaseProvider.overrideWith((ref) {
            ref.onDispose(db.close);
            return db;
          }),
        ],
        child: const AuthApp(),
      ),
    );
  } catch (_) {
    await database?.close();
    runApp(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Unable to open the authenticator securely. Your data has not been deleted.',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
