import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:purity_auth/prefs.dart';
import 'package:purity_auth/top_bar.dart';
import 'package:purity_auth/window_size_controller.dart';
import 'package:signals_flutter/signals_flutter.dart';

class AuthSettingsPage extends StatefulWidget {
  const AuthSettingsPage({super.key});

  @override
  State<AuthSettingsPage> createState() => _AuthSettingsPageState();
}

class _AuthSettingsPageState extends State<AuthSettingsPage> with WidgetsBindingObserver, WindowSizeStateMixin {
  final Prefs prefs = GetIt.I<Prefs>();
  late final List<List<dynamic>> options = [
    [prefs.biometricUnlock, '生物识别解锁'],
    [prefs.isShowCaptchaOnTap, '轻触显示验证码'],
    [prefs.isCopyCaptchaOnTap, '轻触复制验证码'],
    [prefs.disableScreenshot, '禁止截图'],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: contentWidth,
            child: Column(
              children: <Widget>[
                TopBar(context, '设置'),
                Expanded(
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: maxCrossAxisExtent,
                      mainAxisExtent: 90,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                    ),
                    itemCount: options.length,
                    itemBuilder: (BuildContext context, int index) {
                      final List<dynamic> option = options[index];
                      return _Button(option[0] as Signal<bool>, option[1] as String, key: ObjectKey(option));
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
}

class _Button extends StatefulWidget {
  const _Button(
    this.enable,
    this.label, {
    super.key,
  });

  final Signal<bool> enable;
  final String label;

  @override
  State<_Button> createState() => _ButtonState();
}

class _ButtonState extends State<_Button> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: const BorderRadius.all(Radius.circular(24))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const SizedBox(width: 12),
          Expanded(
            child: Text(widget.label, maxLines: 1, style: TextStyle(height: 0, fontSize: 18, color: Theme.of(context).colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () {
              widget.enable.value = !widget.enable.value;
            },
            child: Watch.builder(
              builder: (context) {
                return Container(
                  height: 48,
                  width: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: widget.enable.value ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.inversePrimary,
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                  ),
                  child: Icon(widget.enable.value ? Icons.done : Icons.close, size: 36, color: Theme.of(context).colorScheme.onPrimary),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
