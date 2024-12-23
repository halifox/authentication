import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:purity_auth/auth.dart';
import 'package:purity_auth/auth_repository.dart';
import 'package:purity_auth/authentication_widget.dart';
import 'package:purity_auth/top_bar.dart';
import 'package:purity_auth/window_size_controller.dart';

class AuthHomePage extends StatefulWidget {
  const AuthHomePage({super.key});

  @override
  State<AuthHomePage> createState() => _AuthHomePageState();
}

class _AuthHomePageState extends State<AuthHomePage> with WidgetsBindingObserver, WindowSizeStateMixin {
  List<AuthenticationConfig> configs = <AuthenticationConfig>[];

  void toAuthAddPage(BuildContext context) {
    Navigator.pushNamed(context, '/AuthAddPage');
  }

  listener(List<AuthenticationConfig> configs) {
    setState(() {
      this.configs = configs;
    });
  }

  @override
  void initState() {
    configs = GetIt.I<AuthRepository>().snapshot;
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
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: contentWidth,
            child: Column(
              children: <Widget>[
                TopBar(
                  context,
                  'Purity Auth',
                  leftIcon: Icons.settings,
                  leftOnPressed: null,
                  rightIcon: Icons.add,
                  rightOnPressed: toAuthAddPage,
                ),
                Expanded(
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: maxCrossAxisExtent,
                      mainAxisExtent: 140,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                    ),
                    itemCount: configs.length,
                    itemBuilder: (BuildContext context, int index) {
                      final AuthenticationConfig config = configs[index];
                      return AuthenticationWidget(key: ObjectKey(config), config: config);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void setSystemUIOverlayStyle(BuildContext context) {
    if (!kIsWeb && Platform.isAndroid) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: Theme.of(context).colorScheme.surface,
        systemNavigationBarDividerColor: Theme.of(context).colorScheme.surface,
        systemNavigationBarIconBrightness: Theme.of(context).colorScheme.brightness,
        // systemNavigationBarContrastEnforced: false,
        statusBarColor: Colors.transparent,
        statusBarBrightness: Theme.of(context).colorScheme.brightness,
        statusBarIconBrightness: (Theme.of(context).colorScheme.brightness == Brightness.dark) ? Brightness.light : Brightness.dark, //MIUI的这个行为有异常
        // systemStatusBarContrastEnforced: false,
      ));
    }
  }
}
