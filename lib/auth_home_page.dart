import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:purity_auth/auth.dart';
import 'package:purity_auth/auth_repository.dart';
import 'package:purity_auth/authentication_widget.dart';
import 'package:purity_auth/top_bar.dart';
import 'package:purity_auth/window_size_controller.dart';

class AuthHomePage extends StatelessWidget {
  AuthHomePage({super.key});

  final windowSizeController = Get.put(WindowSizeController());

  void toAuthAddPage(BuildContext context) {
    Navigator.pushNamed(context, "/AuthAddPage");
  }

  @override
  Widget build(BuildContext context) {
    setSystemUIOverlayStyle(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Obx(
            () => SizedBox(
              width: windowSizeController.contentWidth.value,
              child: Column(
                children: [
                  TopBar(
                    context,
                    "Purity Auth",
                    leftIcon: Icons.settings,
                    leftOnPressed: null,
                    rightIcon: Icons.add,
                    rightOnPressed: toAuthAddPage,
                  ),
                  Expanded(
                    child: GridView.builder(
                      physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: windowSizeController.maxCrossAxisExtent,
                        mainAxisExtent: 140,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                      ),
                      itemCount: GetIt.I<AuthRepository>().authSnapshot.length,
                      itemBuilder: (context, index) {
                        AuthConfiguration configuration = GetIt.I<AuthRepository>().authSnapshot[index];
                        return AuthenticationWidget(key: ObjectKey(configuration), authConfiguration: configuration);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void setSystemUIOverlayStyle(context) {
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
