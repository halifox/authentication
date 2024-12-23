import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:get_it/get_it.dart';
import 'package:purity_auth/auth.dart';
import 'package:purity_auth/auth_repository.dart';
import 'package:purity_auth/otp.dart';

/// 认证项小部件
class AuthenticationWidget extends StatefulWidget {
  final AuthenticationConfig config; // 认证对象

  const AuthenticationWidget({super.key, required this.config});

  @override
  State<AuthenticationWidget> createState() => _AuthenticationWidgetState();
}

/// 认证项的状态类
class _AuthenticationWidgetState extends State<AuthenticationWidget> {
  late final configuration = widget.config;
  String authCode = "--------";

  Timer? timer;

  @override
  void initState() {
    super.initState();
    if ([Type.totp, Type.motp].contains(configuration.type)) {
      startOtpTimer();
    } else {
      updateAuthCode();
    }
  }

  startOtpTimer() {
    var remainingMilliseconds = OTP.remainingMilliseconds(intervalMilliseconds: configuration.intervalSeconds * 1000);
    timer = Timer(Duration(milliseconds: remainingMilliseconds), startOtpTimer);
    updateAuthCode();
  }

  updateAuthCode() {
    setState(() {
      authCode = configuration.generateCodeString();
    });
  }

  void onEdit() {
    Navigator.pushNamed(context, "/AuthFromPage", arguments: configuration);
  }

  void onDelete() {
    GetIt.I<AuthRepository>().delete(configuration);
  }

  @override
  void dispose() {
    timer?.cancel();
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
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(label), // 按钮标签
        ),
      ),
    );
  }

  /// 构建认证卡片
  Widget buildAuthCard() {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: authCode));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('代码已复制'), duration: Duration(milliseconds: 1200)));
      },
      child: Container(
        padding: EdgeInsets.all(16),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(24)),
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
    // var assetName = 'icons/${configuration.issuer.toLowerCase()}.svg';
    var assetName = 'icons/apple.svg';
    return Container(
      height: 48,
      width: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(12)),
      // child: Icon(Icons.account_balance_sharp, size: 24, color: Theme.of(context).colorScheme.onPrimary),
      child: SvgPicture.asset(
        assetName,
        width: 28,
        height: 28,
        colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.onPrimary, BlendMode.srcIn),
        placeholderBuilder: (context) {
          return Icon(Icons.account_balance, size: 24, color: Theme.of(context).colorScheme.onPrimary);
        },
      ),
    );
  }

  /// 构建认证详细信息
  Widget buildAuthDetails() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(configuration.issuer, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(height: 0, fontSize: 18, color: Theme.of(context).colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text(configuration.account, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(height: 0, fontSize: 13, color: Theme.of(context).colorScheme.onPrimaryContainer.withAlpha(200))),
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
        Type.totp => CoreCircularProgressIndicator(configuration.intervalSeconds * 1000),
        Type.hotp => buildHotpNextButton(),
        Type.motp => CoreCircularProgressIndicator(configuration.intervalSeconds * 1000),
      },
    );
  }

  Widget buildHotpNextButton() {
    return IconButton(
      onPressed: () {
        configuration.counter++;
        GetIt.I<AuthRepository>().update(configuration); // 更新认证
      },
      icon: Icon(Icons.refresh),
    );
  }

  /// 构建代码行
  Widget buildCodeRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: authCode.characters.map((char) => buildCodeItem(char)).toList(), // 显示每个代码项
    );
  }

  /// 构建单个代码项
  Widget buildCodeItem(String char) {
    return Container(
      height: 42,
      width: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.tertiary, borderRadius: BorderRadius.circular(14)),
      child: Text(char, style: TextStyle(height: 0, fontSize: 32, color: Theme.of(context).colorScheme.onTertiary, fontWeight: FontWeight.bold, fontFamily: 'GothamRnd')), // 代码字符
    );
  }
}

class CoreCircularProgressIndicator extends StatefulWidget {
  CoreCircularProgressIndicator(this.intervalMilliseconds, {super.key});

  final int intervalMilliseconds;

  @override
  State<CoreCircularProgressIndicator> createState() => _CoreCircularProgressIndicatorState();
}

class _CoreCircularProgressIndicatorState extends State<CoreCircularProgressIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> animation;

  @override
  void initState() {
    super.initState();
    int remainingMilliseconds = OTP.remainingMilliseconds(intervalMilliseconds: widget.intervalMilliseconds);
    controller = AnimationController(duration: Duration(milliseconds: widget.intervalMilliseconds), vsync: this);
    animation = Tween<double>(begin: 1.0, end: 0.0).animate(controller);
    controller.value = 1 - remainingMilliseconds / widget.intervalMilliseconds;
    controller.repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CircularProgressIndicator(value: animation.value, strokeCap: StrokeCap.round, strokeWidth: 5.5);
      },
    );
  }
}
