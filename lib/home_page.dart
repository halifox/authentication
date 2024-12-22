import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:purity_auth/auth.dart';
import 'package:purity_auth/auth_item_widget.dart';
import 'package:purity_auth/auth_repository.dart';
import 'package:purity_auth/top_bar.dart';

class HomePageController extends GetxController {
  @override
  void onReady() {
    if (!kIsWeb && Platform.isAndroid) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: Get.theme.colorScheme.surface,
        systemNavigationBarDividerColor: Get.theme.colorScheme.surface,
        systemNavigationBarIconBrightness: Get.theme.colorScheme.brightness,
        // systemNavigationBarContrastEnforced: false,
        statusBarColor: Colors.transparent,
        statusBarBrightness: Get.theme.colorScheme.brightness,
        statusBarIconBrightness: (Get.theme.colorScheme.brightness == Brightness.dark) ? Brightness.light : Brightness.dark, //MIUI的这个行为有异常
        // systemStatusBarContrastEnforced: false,
      ));
    }
  }
}

class HomePage extends StatelessWidget {
  final controller = Get.put(HomePageController());
  final authRepository = Get.find<AuthRepository>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TopBar(
              "2FA",
              leftIcon: Icons.settings,
              leftOnPressed: () {},
              rightIcon: Icons.add,
              rightOnPressed: () => Get.toNamed("/AuthAddPage"),
            ),
            Expanded(
              child: Obx(
                () {
                  return GridView.builder(
                    physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 750,
                      mainAxisExtent: 140,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                    ),
                    itemCount: authRepository.authSnapshot.length,
                    itemBuilder: (context, index) {
                      AuthConfiguration configuration = authRepository.authSnapshot[index];
                      return AuthItem(key: ObjectKey(configuration), authConfiguration: configuration);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
