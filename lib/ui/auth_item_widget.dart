import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:sembast/sembast.dart';

import '../l10n/app_localizations.dart';
import '../repository/auth.dart';
import '../repository/otp.dart';
import '../repository/repository.dart';
import 'result_screen.dart';
import 'route.dart';

/// 认证项小部件
class AuthItemWidget extends StatefulWidget {
  const AuthItemWidget({super.key, required this.config});

  final AuthConfig config;

  @override
  State<AuthItemWidget> createState() => _AuthItemWidgetState();
}

/// 认证项的状态类
class _AuthItemWidgetState extends State<AuthItemWidget> {
  late AuthConfig config = widget.config;
  String code = '--------';
  bool biometricUnlock = false;
  bool isShowCaptchaOnTap = false;
  bool isCopyCaptchaOnTap = false;
  bool isShow = false;
  var optTimer;
  var tapTimer;
  var settingsSubscription;
  var authSubscription;

  @override
  void initState() {
    settingsSubscription = settingsStore.query().onSnapshots(db).listen((data) async {
      final settings = await settingsStore.record('settings').getSnapshot(db);
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

  void startOtpTimer() {
    final remainingMilliseconds = OTP.remainingMilliseconds(intervalMilliseconds: config.period * 1000);
    optTimer = Timer(Duration(milliseconds: remainingMilliseconds), startOtpTimer);
    setState(() => code = config.generateCodeString());
  }

  void onEdit() {
    Navigator.pushNamed(context, '/from', arguments: config.clone());
  }

  Future<void> onDelete() async {
    final bool? result = await showCupertinoModalPopup(
      context: context,
      builder: (ctx) => ResultScreen(
        state: 0,
        title: AppLocalizations.of(context)!.warning,
        message: AppLocalizations.of(context)!.deleteWarning,
        falseButtonVisible: true,
      ),
    );
    if (result == null) {
      return;
    }
    if (result) {
      authStore.record(config.key).delete(db);
      return;
    }
  }

  void onTap() {
    if (isShowCaptchaOnTap) {
      setState(() {
        isShow = !isShow;
      });
      tapTimer?.cancel();
      tapTimer = Timer(const Duration(seconds: 10), () {
        setState(() {
          isShow = false;
        });
      });
    }
    if (isCopyCaptchaOnTap) {
      Clipboard.setData(ClipboardData(text: code));
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.codeCopied), duration: const Duration(milliseconds: 1200)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SwipeActionCell(
      key: ObjectKey(config), // 唯一标识
      trailingActions: <SwipeAction>[
        buildSwipeAction(AppLocalizations.of(context)!.delete, onDelete),
        buildSwipeAction(AppLocalizations.of(context)!.edit, onEdit),
      ],
      child: buildAuthCard(), // 构建认证卡片
    );
  }

  /// 构建滑动操作按钮
  SwipeAction buildSwipeAction(String label, VoidCallback onTap) => SwipeAction(
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

  /// 构建认证卡片
  Widget buildAuthCard() => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: <Widget>[
          buildTopRow(), // 顶部行
          const Spacer(),
          buildCodeRow(), // 代码行
        ],
      ),
    ),
  );

  /// 构建顶部行，包括图标和认证信息
  Widget buildTopRow() => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      buildIconContainer(), // 图标容器
      const SizedBox(width: 16),
      buildAuthDetails(), // 认证信息
      const SizedBox(width: 16),
      buildActionButton(), // 动作按钮
    ],
  );

  /// 构建图标容器
  Widget buildIconContainer() => Container(
    height: 48,
    width: 48,
    alignment: Alignment.center,
    decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(12)),
    child: SvgPicture.asset(
      config.icon,
      width: 28,
      height: 28,
      colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.onPrimary, BlendMode.srcIn),
    ),
  );

  /// 构建认证详细信息
  Widget buildAuthDetails() => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          config.issuer,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            height: 0,
            fontSize: 18,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          config.account,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            height: 0,
            fontSize: 13,
            color: Theme.of(context).colorScheme.onPrimaryContainer.withAlpha(200),
          ),
        ),
      ],
    ),
  );

  /// 构建动作按钮
  Widget buildActionButton() => Container(
    height: 48,
    width: 48,
    alignment: Alignment.center,
    child: switch (config.type) {
      'totp' => CoreCircularProgressIndicator(config.period * 1000),
      'hotp' => buildHotpNextButton(),
      'motp' => CoreCircularProgressIndicator(config.period * 1000),
      String() => throw UnimplementedError(),
    },
  );

  static Map<String, bool> hotpPressedCache = <String, bool>{};

  Widget buildHotpNextButton() {
    final bool pressed = hotpPressedCache[config.key] ?? false;
    return IconButton(
      onPressed: pressed
          ? null
          : () {
              hotpPressedCache[config.key] = true;
              config.counter++;
              authStore.record(config.key).update(db, config.toJson());
            },
      icon: const Icon(Icons.refresh),
    );
  }

  /// 构建代码行
  Widget buildCodeRow() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: code.characters.map(buildCodeItem).toList(), // 显示每个代码项
  );

  /// 构建单个代码项
  Widget buildCodeItem(String char) => Container(
    height: 42,
    width: 40,
    alignment: Alignment.center,
    decoration: BoxDecoration(color: Theme.of(context).colorScheme.tertiary, borderRadius: BorderRadius.circular(14)),
    child: Text(
      isShow ? char : '-',
      style: TextStyle(
        height: 0,
        fontSize: 32,
        color: Theme.of(context).colorScheme.onTertiary,
        fontWeight: FontWeight.bold,
        fontFamily: 'GothamRnd',
      ),
    ), // 代码字符
  );
}

class CoreCircularProgressIndicator extends StatefulWidget {
  const CoreCircularProgressIndicator(this.intervalMilliseconds, {super.key});

  final int intervalMilliseconds;

  @override
  State<CoreCircularProgressIndicator> createState() => _CoreCircularProgressIndicatorState();
}

class _CoreCircularProgressIndicatorState extends State<CoreCircularProgressIndicator>
    with SingleTickerProviderStateMixin {
  late int remainingMilliseconds = OTP.remainingMilliseconds(intervalMilliseconds: widget.intervalMilliseconds);
  late AnimationController controller =
      AnimationController(
          duration: Duration(milliseconds: widget.intervalMilliseconds),
          vsync: this,
        )
        ..value = 1 - remainingMilliseconds / widget.intervalMilliseconds
        ..repeat();
  late Animation<double> animation = Tween<double>(begin: 1.0, end: 0.0).animate(controller);

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
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: animation,
    builder: (BuildContext context, Widget? child) =>
        CircularProgressIndicator(value: animation.value, strokeCap: StrokeCap.round, strokeWidth: 5.5),
  );
}
