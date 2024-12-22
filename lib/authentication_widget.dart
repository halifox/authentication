import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:get/get.dart';
import 'package:purity_auth/auth.dart';
import 'package:purity_auth/auth_repository.dart';
import 'package:purity_auth/otp.dart';

/// 认证项小部件
class AuthenticationWidget extends StatefulWidget {
  final AuthConfiguration authConfiguration; // 认证对象

  const AuthenticationWidget({super.key, required this.authConfiguration});

  @override
  State<AuthenticationWidget> createState() => _AuthenticationWidgetState();
}

/// 认证项的状态类
class _AuthenticationWidgetState extends State<AuthenticationWidget> with SingleTickerProviderStateMixin {
  late final configuration = widget.authConfiguration;
  late final AnimationController animationController; // 动画控制器
  final RxString authCode = RxString("--------"); // 存储认证代码
  final RxDouble countdownValue = RxDouble(0.0); // 倒计时进度
  Timer? updateTimer; // 更新定时器

  @override
  void initState() {
    super.initState();
    // 根据认证类型初始化计时器和动画
    if ([AuthType.totp, AuthType.motp].contains(configuration.type)) {
      animationController = AnimationController(duration: Duration(seconds: configuration.intervalSeconds), vsync: this)
        ..addListener(() {
          countdownValue.value = animationController.value; // 更新倒计时进度
        });
      updateTimer = Timer(Duration(seconds: OTP.remainingSeconds(intervalSeconds: configuration.intervalSeconds)), startUpdateTimer);
      refreshCodeAndCountdown(); // 刷新代码和倒计时
    } else {
      authCode.value = configuration.generateCodeString(); // 计算代码
    }
  }

  /// 启动定时器以定期刷新代码和倒计时
  void startUpdateTimer() {
    updateTimer = Timer.periodic(Duration(seconds: configuration.intervalSeconds), (_) => refreshCodeAndCountdown());
    refreshCodeAndCountdown(); // 刷新代码和倒计时
  }

  /// 刷新认证代码和倒计时进度
  void refreshCodeAndCountdown() {
    authCode.value = configuration.generateCodeString(); // 计算新的认证代码
    var remainingTime = OTP.remainingSeconds(intervalSeconds: configuration.intervalSeconds); // 剩余时间
    var remaining = remainingTime * 1.0 / configuration.intervalSeconds;
    animationController.forward(from: 1.0 - remaining); // 开始动画
  }

  void onEdit() {
    Get.toNamed("/AuthFromPage", arguments: configuration);
  }

  void onDelete() {
    Get.find<AuthRepository>().delete(configuration);
  }

  @override
  void dispose() {
    updateTimer?.cancel(); // 取消定时器
    animationController.dispose(); // 释放动画控制器
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SwipeActionCell(
      key: ObjectKey(configuration), // 唯一标识
      trailingActions: [
        buildSwipeAction("删除", onDelete),
        buildSwipeAction("编辑", onEdit),
      ],
      child: buildAuthCard(), // 构建认证卡片
    );
  }

  /// 构建滑动操作按钮
  SwipeAction buildSwipeAction(String label, VoidCallback onTap) {
    return SwipeAction(
      widthSpace: 140 + 12,
      onTap: (handler) async => onTap(), // 执行操作
      color: Colors.transparent,
      content: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(label), // 按钮标签
        ),
      ),
    );
  }

  /// 构建认证卡片
  Widget buildAuthCard() {
    return InkWell(
      onTap: () {
        Clipboard.setData(ClipboardData(text: authCode.value));
        Get.closeAllSnackbars();
        Get.snackbar("代码已复制", "代码已复制", duration: Duration(milliseconds: 1200));
      },
      child: Container(
        padding: EdgeInsets.all(16),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: Get.theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(24)),
        child: Column(
          children: [
            buildTopRow(), // 顶部行
            Spacer(),
            buildCodeRow(), // 代码行
          ],
        ),
      ),
    );
  }

  /// 构建顶部行，包括图标和认证信息
  Widget buildTopRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        buildIconContainer(), // 图标容器
        SizedBox(width: 16),
        buildAuthDetails(), // 认证信息
        SizedBox(width: 16),
        buildActionButton(), // 动作按钮
      ],
    );
  }

  /// 构建图标容器
  Widget buildIconContainer() {
    return Container(
      height: 48,
      width: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: Get.theme.colorScheme.primary, borderRadius: BorderRadius.circular(12)),
      child: Icon(Icons.account_balance_sharp, size: 24, color: Get.theme.colorScheme.onPrimary),
    );
  }

  /// 构建认证详细信息
  Widget buildAuthDetails() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(configuration.issuer,
              maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(height: 0, fontSize: 18, color: Get.theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text(configuration.account, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(height: 0, fontSize: 13, color: Get.theme.colorScheme.onPrimaryContainer.withAlpha(200))),
        ],
      ),
    );
  }

  /// 构建动作按钮
  Widget buildActionButton() {
    return Container(
      height: 48,
      width: 48,
      alignment: Alignment.center,
      child: switch (configuration.type) {
        AuthType.totp => buildTotpProgress(),
        AuthType.hotp => buildHotpNextButton(),
        AuthType.motp => buildTotpProgress(),
      },
    );
  }

  Widget buildTotpProgress() {
    return Obx(
      () => CircularProgressIndicator(value: 1.0 - countdownValue.value, strokeCap: StrokeCap.round, strokeWidth: 5.5),
    );
  }

  Widget buildHotpNextButton() {
    return IconButton(
      onPressed: () {
        configuration.counter++;
        Get.find<AuthRepository>().update(configuration); // 更新认证
      },
      icon: Icon(Icons.refresh),
    );
  }

  /// 构建代码行
  Widget buildCodeRow() {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: authCode.value.characters.map((char) => buildCodeItem(char)).toList(), // 显示每个代码项
      ),
    );
  }

  /// 构建单个代码项
  Widget buildCodeItem(String char) {
    return Container(
      height: 42,
      width: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: Get.theme.colorScheme.tertiary, borderRadius: BorderRadius.circular(14)),
      child: Text(char, style: TextStyle(height: 0, fontSize: 32, color: Get.theme.colorScheme.onTertiary, fontWeight: FontWeight.bold, fontFamily: 'GothamRnd')), // 代码字符
    );
  }
}
