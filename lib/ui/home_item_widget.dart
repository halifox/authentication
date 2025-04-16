import 'dart:async';

import 'package:auth/auth.dart';
import 'package:auth/otp.dart';
import 'package:auth/repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:sembast/sembast.dart';

/// 认证项小部件
class HomeItemWidget extends StatefulWidget {
  final AuthConfig config;

  const HomeItemWidget({super.key, required this.config});

  @override
  State<HomeItemWidget> createState() => _HomeItemWidgetState();
}

/// 认证项的状态类
class _HomeItemWidgetState extends State<HomeItemWidget> {
  late var config = widget.config;
  var code = '--------';
  var biometricUnlock = false;
  var isShowCaptchaOnTap = false;
  var isCopyCaptchaOnTap = false;
  var isShow = false;
  var optTimer;
  var tapTimer;
  var settingsSubscription;
  var authSubscription;

  @override
  void initState() {
    settingsSubscription = settingsStore.query().onSnapshots(db).listen((data) async {
      var settings = await settingsStore.record('settings').getSnapshot(db);
      if (settings == null) {
        return;
      }
      biometricUnlock = settings['biometricUnlock'] as bool;
      isShowCaptchaOnTap = settings['isShowCaptchaOnTap'] as bool;
      isCopyCaptchaOnTap = settings['isCopyCaptchaOnTap'] as bool;
      setState(() {
        isShow = !isShowCaptchaOnTap;
      });
      tapTimer?.cancel();
    });

    authSubscription = authStore.record(config.key).onSnapshot(db).listen((data) {
      if (data == null) return;
      config = AuthConfig.fromJson(data);
      var _ = switch (config.type) {
        'totp' => startOtpTimer(),
        'motp' => startOtpTimer(),
        'hotp' => setState(() => code = config.generateCodeString()),
        String() => throw UnimplementedError(),
      };
    });
    super.initState();
  }

  @override
  void dispose() {
    unawaited(settingsSubscription?.cancel());
    unawaited(authSubscription?.cancel());
    optTimer?.cancel();
    tapTimer?.cancel();
    super.dispose();
  }

  startOtpTimer() {
    var remainingMilliseconds = OTP.remainingMilliseconds(intervalMilliseconds: config.interval * 1000);
    optTimer = Timer(Duration(milliseconds: remainingMilliseconds), startOtpTimer);
    setState(() => code = config.generateCodeString());
  }

  onEdit() {
    Navigator.pushNamed(context, '/from', arguments: config);
  }

  onDelete() {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) {
        return AlertDialog(
          title: Text("警告"),
          content: Text("您即将删除当前的两步验证器。\n此操作将使您无法使用该验证器进行身份验证。\n请确保您已准备好其他身份验证方式以保障账户安全。"),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                authStore.record(config.key).delete(db);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: Text('删除'),
            ),
          ],
        );
      },
    );
  }

  onTap() {
    if (isShowCaptchaOnTap) {
      setState(() {
        isShow = !isShow;
      });
      tapTimer?.cancel();
      tapTimer = Timer(Duration(seconds: 10), () {
        setState(() {
          isShow = false;
        });
      });
    }
    if (isCopyCaptchaOnTap) {
      Clipboard.setData(ClipboardData(text: code));
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('代码已复制'), duration: Duration(milliseconds: 1200)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SwipeActionCell(
      key: ObjectKey(config), // 唯一标识
      trailingActions: <SwipeAction>[buildSwipeAction('删除', onDelete), buildSwipeAction('编辑', onEdit)],
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
        padding: EdgeInsets.only(left: 12),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(24)),
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
        padding: EdgeInsets.all(16),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(24)),
        child: Column(
          children: <Widget>[
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
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(12)),
      child: SvgPicture.asset(config.icon, width: 28, height: 28, colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.onPrimary, BlendMode.srcIn)),
    );
  }

  /// 构建认证详细信息
  Widget buildAuthDetails() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            config.issuer,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(height: 0, fontSize: 18, color: Theme.of(context).colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(config.account, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(height: 0, fontSize: 13, color: Theme.of(context).colorScheme.onPrimaryContainer.withAlpha(200))),
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
      child: switch (config.type) {
        'totp' => CoreCircularProgressIndicator(config.interval * 1000),
        'hotp' => buildHotpNextButton(),
        'motp' => CoreCircularProgressIndicator(config.interval * 1000),
        String() => throw UnimplementedError(),
      },
    );
  }

  Widget buildHotpNextButton() {
    return IconButton(
      onPressed: () {
        config.counter++;
        authStore.record(config.key).update(db, config.toJson());
      },
      icon: Icon(Icons.refresh),
    );
  }

  /// 构建代码行
  Widget buildCodeRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: code.characters.map((String char) => buildCodeItem(char)).toList(), // 显示每个代码项
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
  late var remainingMilliseconds = OTP.remainingMilliseconds(intervalMilliseconds: widget.intervalMilliseconds);
  late var controller =
      AnimationController(duration: Duration(milliseconds: widget.intervalMilliseconds), vsync: this)
        ..value = 1 - remainingMilliseconds / widget.intervalMilliseconds
        ..repeat();
  late var animation = Tween<double>(begin: 1.0, end: 0.0).animate(controller);

  @override
  void initState() {
    super.initState();
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
