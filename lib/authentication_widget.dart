import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:get_it/get_it.dart';
import 'package:purity_auth/auth.dart';
import 'package:purity_auth/auth_repository.dart';
import 'package:purity_auth/dialog.dart';
import 'package:purity_auth/otp.dart';
import 'package:purity_auth/prefs.dart';
import 'package:signals_flutter/signals_core.dart';

/// 认证项小部件
class AuthenticationWidget extends StatefulWidget {
  final AuthenticationConfig config; // 认证对象

  const AuthenticationWidget({super.key, required this.config});

  @override
  State<AuthenticationWidget> createState() => _AuthenticationWidgetState();
}

/// 认证项的状态类
class _AuthenticationWidgetState extends State<AuthenticationWidget> {
  Prefs prefs = GetIt.I<Prefs>();

  late final AuthenticationConfig configuration = widget.config;
  late String authCode = '--------';
  late bool isShow = !prefs.isShowCaptchaOnTap.value;

  Timer? timer;
  Timer? showCaptchaOnTapTimer;

  @override
  void initState() {
    super.initState();
    effect(() {
      setState(() {
        isShow = !prefs.isShowCaptchaOnTap.value;
      });
      showCaptchaOnTapTimer?.cancel();
    });

    if (<Type>[Type.totp, Type.motp].contains(configuration.type)) {
      startOtpTimer();
    } else {
      updateAuthCode();
    }
  }

  startOtpTimer() {
    final int remainingMilliseconds = OTP.remainingMilliseconds(intervalMilliseconds: configuration.intervalSeconds * 1000);
    timer = Timer(Duration(milliseconds: remainingMilliseconds), startOtpTimer);
    updateAuthCode();
  }

  updateAuthCode() {
    setState(() {
      authCode = configuration.generateCodeString();
    });
  }

  void onEdit() {
    Navigator.pushNamed(context, '/AuthFromPage', arguments: configuration);
  }

  void onDelete() {
    showGeneralDialog(
      context: context,
      pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
        return AlertDialog(
          title: Text("警告"),
          content: Text("您即将删除当前的两步验证器。\n此操作将使您无法使用该验证器进行身份验证。\n请确保您已准备好其他身份验证方式以保障账户安全。"),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                GetIt.I<AuthRepository>().delete(configuration.key!);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text('删除'),
            ),
          ],
        );
      },
    );
  }

  void onTap() {
    if (prefs.isShowCaptchaOnTap.value) {
      setState(() {
        isShow = !isShow;
      });
      showCaptchaOnTapTimer?.cancel();
      showCaptchaOnTapTimer = Timer(const Duration(seconds: 10), () {
        if (mounted) {
          setState(() {
            isShow = false;
          });
        }
      });
    }
    if (prefs.isCopyCaptchaOnTap.value) {
      Clipboard.setData(ClipboardData(text: authCode));
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('代码已复制'), duration: Duration(milliseconds: 1200)));
    }
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
      trailingActions: <SwipeAction>[
        buildSwipeAction('删除', onDelete),
        buildSwipeAction('编辑', onEdit),
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
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(24)),
        child: Column(
          children: <Widget>[
            buildTopRow(), // 顶部行
            const Spacer(),
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
      children: <Widget>[
        buildIconContainer(), // 图标容器
        const SizedBox(width: 16),
        buildAuthDetails(), // 认证信息
        const SizedBox(width: 16),
        buildActionButton(), // 动作按钮
      ],
    );
  }

  /// 构建图标容器
  Widget buildIconContainer() {
    return GestureDetector(
      onTap: () {
        showDevDialog(context);
      },
      child: Container(
        height: 48,
        width: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(12)),
        child: SvgPicture.asset(
          configuration.icon ?? 'icons/${configuration.issuer.toLowerCase()}.svg',
          width: 28,
          height: 28,
          colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.onPrimary, BlendMode.srcIn),
          placeholderBuilder: (BuildContext context) {
            return Icon(Icons.account_balance, size: 24, color: Theme.of(context).colorScheme.onPrimary);
          },
        ),
      ),
    );
  }

  /// 构建认证详细信息
  Widget buildAuthDetails() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(configuration.issuer, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(height: 0, fontSize: 18, color: Theme.of(context).colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
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
      icon: const Icon(Icons.refresh),
    );
  }

  /// 构建代码行
  Widget buildCodeRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: authCode.characters.map((String char) => buildCodeItem(char)).toList(), // 显示每个代码项
    );
  }

  /// 构建单个代码项
  Widget buildCodeItem(String char) {
    return Container(
      height: 42,
      width: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.tertiary, borderRadius: BorderRadius.circular(14)),
      child: Text(isShow ? char : '-', style: TextStyle(height: 0, fontSize: 32, color: Theme.of(context).colorScheme.onTertiary, fontWeight: FontWeight.bold, fontFamily: 'GothamRnd')), // 代码字符
    );
  }
}

class CoreCircularProgressIndicator extends StatefulWidget {
  const CoreCircularProgressIndicator(this.intervalMilliseconds, {super.key});

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
    final int remainingMilliseconds = OTP.remainingMilliseconds(intervalMilliseconds: widget.intervalMilliseconds);
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
      builder: (BuildContext context, Widget? child) {
        return CircularProgressIndicator(value: animation.value, strokeCap: StrokeCap.round, strokeWidth: 5.5);
      },
    );
  }
}
