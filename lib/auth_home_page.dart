import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:purity_auth/auth.dart';
import 'package:purity_auth/authentication_widget.dart';
import 'package:purity_auth/auth_repository.dart';
import 'package:purity_auth/top_bar.dart';
import 'package:purity_auth/window_size_controller.dart';

class AuthHomePage extends StatelessWidget {
  AuthHomePage({super.key});

  final windowSizeController = Get.put(WindowSizeController());
  final authRepository = Get.find<AuthRepository>();

  void toAuthAddPage() {
    Get.toNamed("/AuthAddPage");
  }

  @override
  Widget build(BuildContext context) {
    setSystemUIOverlayStyle();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Obx(
            () => SizedBox(
              width: windowSizeController.contentWidth.value,
              child: Column(
                children: [
                  TopBar(
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
                      itemCount: authRepository.authSnapshot.length,
                      itemBuilder: (context, index) {
                        AuthConfiguration configuration = authRepository.authSnapshot[index];
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

  void setSystemUIOverlayStyle() {
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
