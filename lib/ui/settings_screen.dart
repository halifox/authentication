import 'package:flutter/material.dart';
import 'package:sembast/sembast.dart';

import '../l10n/app_localizations.dart';
import '../repository/repository.dart';
import 'top_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<List<String>> get options {
    return [
      // ['biometricUnlock', AppLocalizations.of(context)!.biometricUnlock],
      ['isShowCaptchaOnTap', AppLocalizations.of(context)!.showCaptchaOnTap],
      ['isCopyCaptchaOnTap', AppLocalizations.of(context)!.copyCaptchaOnTap],
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(context, AppLocalizations.of(context)!.settings),
      body: GridView.builder(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 700,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          mainAxisExtent: 90,
        ),
        itemCount: options.length,
        itemBuilder: (context, index) {
          final item = options[index];
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
  bool enable = false;

  Future<void> initData() async {
    final settings = await settingsStore.record('settings').getSnapshot(db);
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
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primaryContainer,
      borderRadius: const BorderRadius.all(Radius.circular(24)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            widget.label,
            maxLines: 1,
            style: TextStyle(
              height: 0,
              fontSize: 18,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 16),
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
            decoration: BoxDecoration(
              color: enable ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.inversePrimary,
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
            child: Icon(enable ? Icons.done : Icons.close, size: 36, color: Theme.of(context).colorScheme.onPrimary),
          ),
        ),
      ],
    ),
  );
}
