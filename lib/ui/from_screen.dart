import 'package:auth/auth.dart';
import 'package:auth/dialog.dart';
import 'package:auth/repository.dart';
import 'package:auth/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sembast/sembast.dart';

class FromScreen extends StatefulWidget {
  const FromScreen({super.key});

  @override
  State<FromScreen> createState() => _FromScreenState();
}

class _FromScreenState extends State<FromScreen> {
  late final AuthConfig config = ModalRoute.of(context)?.settings.arguments as AuthConfig? ?? AuthConfig();

  late final TextEditingController issuerController = TextEditingController(text: config.issuer);

  late final TextEditingController accountController = TextEditingController(text: config.account);

  late final TextEditingController secretController = TextEditingController(text: config.secret);

  late final TextEditingController pinController = TextEditingController(text: config.pin);

  late final TextEditingController digitsController = TextEditingController(text: config.digits.toString());

  late final TextEditingController periodController = TextEditingController(text: config.interval.toString());

  late final TextEditingController counterController = TextEditingController(text: config.counter.toString());

  final typeLabels = {'totp': '基于时间 (TOTP)', 'hotp': '基于计数器 (HOTP)', 'motp': 'Mobile-OTP (mOTP)'};

  final algorithmLabels = {'sha1': 'SHA1', 'sha256': 'SHA256', 'sha512': 'SHA512'};

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void onSave(BuildContext context) async {
    try {
      config
        ..account = accountController.text
        ..issuer = issuerController.text
        ..secret = secretController.text
        ..pin = pinController.text
        ..digits = int.parse(digitsController.text)
        ..interval = int.parse(periodController.text)
        ..counter = int.parse(counterController.text);
      config.verify();
      if (config.key.isEmpty) {
        authStore.add(db, config.toJson());
      } else {
        authStore.record(config.key).update(db, config.toJson());
      }
      Navigator.popUntil(context, (route) => route.settings.name == '/');
      showAlertDialog(context, '结果', '更新成功');
    } on ArgumentError catch (e) {
      showAlertDialog(context, '参数错误', e.message as String?);
    } on FormatException catch (e) {
      showAlertDialog(context, '格式错误', e.message);
    } catch (e) {
      showAlertDialog(context, '未知错误', e.toString());
      rethrow;
    }
  }

  Widget buildTextField(TextEditingController controller, String label, {TextInputType? inputType, List<TextInputFormatter>? inputFormatters, suffixIcon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          border: const OutlineInputBorder(borderSide: BorderSide(), borderRadius: BorderRadius.all(Radius.circular(14.0)), gapPadding: 8.0),
          suffixIcon: suffixIcon,
        ),
        keyboardType: inputType,
        inputFormatters: inputFormatters,
      ),
    );
  }

  Widget buildDropdown<T>(String label, T initialValue, Map<T, String> options, void Function(T?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: DropdownButtonFormField<T>(
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(borderSide: BorderSide(), borderRadius: BorderRadius.all(Radius.circular(14.0)), gapPadding: 8.0)),
        value: initialValue,
        onChanged: onChanged,
        items: options.entries.map((MapEntry<T, String> entry) => DropdownMenuItem<T>(value: entry.key, child: Text(entry.value))).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(context, '输入提供的密钥', rightIcon: Icons.save, rightOnPressed: onSave),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          child: Column(
            children: [
              buildDropdown('类型', config.type, typeLabels, (value) {
                setState(() {
                  config.type = value!;
                });
              }),
              buildTextField(issuerController, '发行方', suffixIcon: DySvgWidget(issuerController, (icon) => config.icon = icon)),
              buildTextField(accountController, '用户名'),
              buildTextField(secretController, '密钥'),
              switch (config.type) {
                'totp' => buildDropdown('算法', config.algorithm, algorithmLabels, (value) => config.algorithm = value as String),
                'hotp' => buildDropdown('算法', config.algorithm, algorithmLabels, (value) => config.algorithm = value as String),
                'motp' => buildTextField(pinController, 'PIN码'),
                String() => throw UnimplementedError(),
              },

              Row(
                children: <Widget>[
                  Expanded(child: buildTextField(digitsController, '位数', inputType: TextInputType.number, inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly])),
                  Expanded(
                    child: switch (config.type) {
                      'totp' => buildTextField(periodController, '时间间隔(秒)', inputType: TextInputType.number, inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly]),
                      'hotp' => buildTextField(counterController, '计数器', inputType: TextInputType.number, inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly]),
                      'motp' => buildTextField(periodController, '时间间隔(秒)', inputType: TextInputType.number, inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly]),
                      String() => throw UnimplementedError(),
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DySvgWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onIconChange;

  const DySvgWidget(this.controller, this.onIconChange, {super.key});

  @override
  State<DySvgWidget> createState() => _DySvgWidgetState();
}

class _DySvgWidgetState extends State<DySvgWidget> {
  var icon = '';
  late var listener = () async {
    icon = 'icons/${widget.controller.text.toLowerCase()}.svg';
    if (!await assetExists(icon)) {
      icon = 'icons/passkey.svg';
    }
    widget.onIconChange.call(icon);
    setState(() {});
  };

  @override
  void initState() {
    listener.call();
    widget.controller.addListener(listener);
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.removeListener(listener);
    super.dispose();
  }

  Future<bool> assetExists(String assetPath) async {
    try {
      await rootBundle.load(assetPath);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 48,
        width: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(14)),
        child: SvgPicture.asset(icon, width: 28, height: 28, colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.onPrimary, BlendMode.srcIn)),
      ),
    );
  }
}
