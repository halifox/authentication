import 'package:authentication/l10n/generated/app_localizations.dart';
import 'package:authentication/screens/token_form_screen.dart';
import 'package:authentication/storage/database.dart';
import 'package:authentication/storage/database_provider.dart';
import 'package:authentication/storage/encryption.dart';
import 'package:authentication/widgets/glass_inputs.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets(
      'key form remains usable with keyboard and large text in $brightness',
      (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetViewInsets);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        FlutterSecureStorage.setMockInitialValues({});
        final db = AppDatabase(NativeDatabase.memory());
        db.encryption = await EncryptionService.initialize(db);
        addTearDown(() async {
          await tester.pumpWidget(const SizedBox());
          await db.close();
        });
        await tester.pumpWidget(
          ProviderScope(
            overrides: [appDatabaseProvider.overrideWithValue(db)],
            child: MaterialApp(
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.blue,
                  brightness: brightness,
                ),
              ),
              locale: const Locale('en'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const TokenFormScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final field = find.widgetWithText(AppTextField, 'Secret');
        await tester.ensureVisible(field);
        await tester.pumpAndSettle();
        await tester.enterText(field, 'JBSWY3DPEHPK3PXP');
        tester.view.viewInsets = const FakeViewPadding(bottom: 250);
        await tester.pumpAndSettle();
        final editable = find.descendant(
          of: field,
          matching: find.byType(EditableText),
        );
        expect(tester.widget<EditableText>(editable).obscureText, true);
        final reveal = find.descendant(
          of: field,
          matching: find.byType(GlassButton),
        );
        await tester.ensureVisible(reveal);
        await tester.pumpAndSettle();
        expect(tester.getSize(reveal).width, greaterThanOrEqualTo(44));
        await tester.tap(reveal);
        await tester.pumpAndSettle();
        expect(tester.widget<EditableText>(editable).obscureText, false);
        await tester.testTextInput.receiveAction(TextInputAction.next);
        await tester.pumpAndSettle();
        expect(FocusManager.instance.primaryFocus?.hasFocus, true);
        expect(tester.takeException(), isNull);
        expect(await db.getAllConfigs(), isEmpty);
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 10));
      },
    );
  }
}
