import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:auth/auth.dart';
import 'package:auth/auth_repository.dart';
import 'package:auth/authentication_widget.dart';
import 'package:auth/top_bar.dart';
import 'package:auth/window_size_controller.dart';

class AuthHomePage extends StatefulWidget {
  const AuthHomePage({super.key});

  @override
  State<AuthHomePage> createState() => _AuthHomePageState();
}

class _AuthHomePageState extends State<AuthHomePage> with WidgetsBindingObserver, WindowSizeStateMixin {
  void toAuthAddPage(BuildContext context) {
    Navigator.pushNamed(context, '/AuthAddPage');
  }

  void toSettingsPage(BuildContext context) {
    Navigator.pushNamed(context, '/AuthSettingsPage');
  }

  listener(List<AuthenticationConfig> configs) {
    setState(() {});
  }

  @override
  void initState() {
    GetIt.I<AuthRepository>().addListener(listener);
    super.initState();
  }

  @override
  void dispose() {
    GetIt.I<AuthRepository>().removeListener(listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    setSystemUIOverlayStyle(context);
    return Scaffold(
      appBar: TopBar(context, 'Purity Auth', leftIcon: Icons.settings, leftOnPressed: toSettingsPage, rightIcon: Icons.add, rightOnPressed: toAuthAddPage),
      body: GridView.builder(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 700, mainAxisSpacing: 16, crossAxisSpacing: 16, mainAxisExtent: 140),
        itemCount: GetIt.I<AuthRepository>().snapshot.length,
        itemBuilder: (BuildContext context, int index) {
          final AuthenticationConfig config = GetIt.I<AuthRepository>().snapshot[index];
          return AuthenticationWidget(key: ObjectKey(config.key), config: config);
        },
      ),
    );
  }

  void setSystemUIOverlayStyle(BuildContext context) {
    if (!kIsWeb && Platform.isAndroid) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          systemNavigationBarColor: Theme.of(context).colorScheme.surface,
          systemNavigationBarDividerColor: Theme.of(context).colorScheme.surface,
          systemNavigationBarIconBrightness: Theme.of(context).colorScheme.brightness,
          // systemNavigationBarContrastEnforced: false,
          statusBarColor: Colors.transparent,
          statusBarBrightness: Theme.of(context).colorScheme.brightness,
          statusBarIconBrightness: (Theme.of(context).colorScheme.brightness == Brightness.dark) ? Brightness.light : Brightness.dark, //MIUI的这个行为有异常
          // systemStatusBarContrastEnforced: false,
        ),
      );
    }
  }
}
