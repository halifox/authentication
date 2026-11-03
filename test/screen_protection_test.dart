import 'dart:async';

import 'package:authentication/app.dart';
import 'package:authentication/settings/settings.dart';
import 'package:authentication/settings/settings_provider.dart';
import 'package:authentication/storage/database.dart';
import 'package:authentication/storage/database_provider.dart';
import 'package:authentication/storage/encryption.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:screen_security/screen_security_platform_interface.dart';

class _ScreenSecurityPlatform extends ScreenSecurityPlatform {
  final calls = <String>[];
  @override
  Future<void> enableScreenSecurity() async => calls.add('enable');
  @override
  Future<void> disableScreenSecurity() async => calls.add('disable');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('plugin calls are ordered even when settings change rapidly', () async {
    final original = ScreenSecurityPlatform.instance;
    final fake = _ScreenSecurityPlatform();
    ScreenSecurityPlatform.instance = fake;
    addTearDown(() => ScreenSecurityPlatform.instance = original);
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final apply = container.read(screenProtectionApplyProvider);
    await Future.wait([apply(true), apply(false), apply(true)]);
    expect(fake.calls, ['enable', 'disable', 'enable']);
  });
  testWidgets(
    'content is concealed until protection succeeds and retries failures',
    (tester) async {
      FlutterSecureStorage.setMockInitialValues({});
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      db.encryption = await EncryptionService.initialize(db);
      final completion = Completer<void>();
      var calls = 0;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            screenProtectionSupportedProvider.overrideWithValue(true),
            screenProtectionApplyProvider.overrideWithValue((_) {
              calls++;
              return calls == 1 ? completion.future : Future.value();
            }),
          ],
          child: const AuthApp(),
        ),
      );
      await tester.pump();
      await tester.pump();
      expect(find.byType(IgnorePointer), findsWidgets);
      completion.completeError(StateError('private error'));
      await tester.pump();
      await tester.pump();
      expect(
        find.textContaining('Could not apply screen capture protection'),
        findsOneWidget,
      );
      expect(find.textContaining('private error'), findsNothing);
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(find.text('Authentication'), findsOneWidget);
      expect(calls, 2);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(calls, 3);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 10));
    },
  );

  test('changing the setting applies the new protection state', () async {
    FlutterSecureStorage.setMockInitialValues({});
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final calls = <bool>[];
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        screenProtectionSupportedProvider.overrideWithValue(true),
        screenProtectionApplyProvider.overrideWithValue((enabled) async {
          calls.add(enabled);
        }),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(screenProtectionProvider, (_, _) {});
    addTearDown(subscription.close);
    await container.read(screenProtectionProvider.future);
    expect(calls, [true]);
    await db.setSetting(screenProtectionKey, false);
    for (var i = 0; i < 50 && calls.length < 2; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    expect(calls, [true, false]);
  });
}
