import 'package:auth/repository.dart';
import 'package:auth/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:sembast/sembast.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  var options = [
    // ['biometricUnlock', '生物识别解锁'],
    ['isShowCaptchaOnTap', '轻触显示验证码'],
    ['isCopyCaptchaOnTap', '轻触复制验证码'],
  ];

  @override
  Widget build(context) {
    return Scaffold(
      appBar: TopBar(context, '设置'),
      body: GridView.builder(
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: EdgeInsets.symmetric(horizontal: 16),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 700, mainAxisSpacing: 16, crossAxisSpacing: 16, mainAxisExtent: 90),
        itemCount: options.length,
        itemBuilder: (context, index) {
          var item = options[index];
          return HorizontalBarSelectionButton(item[0], item[1]);
        },
      ),
    );
  }
}

class HorizontalBarSelectionButton extends StatefulWidget {
  const HorizontalBarSelectionButton(this.dbKey, this.label, {super.key});

  final dbKey;
  final label;

  @override
  State<HorizontalBarSelectionButton> createState() => _HorizontalBarSelectionButtonState();
}

class _HorizontalBarSelectionButtonState extends State<HorizontalBarSelectionButton> {
  var enable = false;

  initData() async {
    var settings = await settingsStore.record('settings').getSnapshot(db);
    if (settings == null) {
      return;
    }
    setState(() {
      enable = settings[widget.dbKey] as bool;
    });
  }

  @override
  void initState() {
    initData();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.all(Radius.circular(24))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(width: 12),
          Expanded(child: Text(widget.label, maxLines: 1, style: TextStyle(height: 0, fontSize: 18, color: Theme.of(context).colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold))),
          SizedBox(width: 16),
          GestureDetector(
            onTap: () {
              setState(() {
                enable = !enable;
              });
              settingsStore.record('settings').update(db, {widget.dbKey: enable});
            },
            child: Container(
              height: 48,
              width: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: enable ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.inversePrimary, borderRadius: BorderRadius.all(Radius.circular(12))),
              child: Icon(enable ? Icons.done : Icons.close, size: 36, color: Theme.of(context).colorScheme.onPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
