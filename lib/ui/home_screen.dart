import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sembast/sembast.dart';

import '../l10n/app_localizations.dart';
import '../repository/auth.dart';
import '../repository/repository.dart';
import 'auth_item_widget.dart';
import 'route.dart' as route;
import 'settings_screen.dart';
import 'top_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List data = [];
  late StreamSubscription? subscription;

  @override
  void initState() {
    subscription = authStore.query().onSnapshots(db).listen((data) async {
      setState(() {
        this.data = data;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    unawaited(subscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    setSystemUIOverlayStyle(context);

    return Scaffold(
      appBar: TopBar(
        context,
        AppLocalizations.of(context)!.appTitle,
        leftIcon: Icons.settings,
        leftOnPressed: toSettingsPage,
        rightIcon: Icons.add,
        rightOnPressed: toAuthAddPage,
      ),
      body: GridView.builder(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 700,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          mainAxisExtent: 140,
        ),
        itemCount: data.length,
        itemBuilder: (context, index) {
          final config = AuthConfig.fromJson(data[index]);
          return AuthItemWidget(key: ValueKey(config.key), config: config);
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
          statusBarIconBrightness: (Theme.of(context).colorScheme.brightness == Brightness.dark)
              ? Brightness.light
              : Brightness.dark, //MIUI的这个行为有异常
          // systemStatusBarContrastEnforced: false,
        ),
      );
    }
  }

  void toAuthAddPage(BuildContext context) {
    Navigator.pushNamed(context, '/add');
  }

  void toSettingsPage(BuildContext context) {
    // Navigator.pushNamed(context, '/settings');

    Navigator.of(context).push(route.CupertinoPageRoute(builder: (c) => const SettingsScreen()));
  }
}
