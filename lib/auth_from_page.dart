import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:purity_auth/auth.dart';
import 'package:purity_auth/auth_add_page.dart';
import 'package:purity_auth/auth_repository.dart';
import 'package:purity_auth/otp.dart';
import 'package:purity_auth/top_bar.dart';
import 'package:purity_auth/window_size_controller.dart';

class AuthFromPage extends StatefulWidget {
  AuthFromPage({super.key});

  @override
  State<AuthFromPage> createState() => _AuthFromPageState();
}

class _AuthFromPageState extends State<AuthFromPage> with WidgetsBindingObserver, WindowSizeStateMixin {
  late final AuthenticationConfig config = ModalRoute.of(context)?.settings.arguments as AuthenticationConfig? ?? AuthenticationConfig();

  late final TextEditingController issuerController = TextEditingController(text: config.issuer);

  late final TextEditingController accountController = TextEditingController(text: config.account);

  late final TextEditingController secretController = TextEditingController(text: config.secret);

  late final TextEditingController pinController = TextEditingController(text: config.pin);

  late final TextEditingController digitsController = TextEditingController(text: config.digits.toString());

  late final TextEditingController periodController = TextEditingController(text: config.intervalSeconds.toString());

  late final TextEditingController counterController = TextEditingController(text: config.counter.toString());

  void onSave(BuildContext context) async {
    try {
      config
        ..account = accountController.text
        ..issuer = issuerController.text
        ..secret = secretController.text
        ..pin = pinController.text
        ..digits = int.parse(digitsController.text)
        ..intervalSeconds = int.parse(periodController.text)
        ..counter = int.parse(counterController.text);
      await GetIt.I<AuthRepository>().upsert(config);
      Navigator.popUntil(context, (route) => route.settings.name == "/");
      showAlertDialog(context, "结果", "添加成功");
    } on ArgumentError catch (e) {
      showAlertDialog(context, "参数错误", e.message);
    } on FormatException catch (e) {
      showAlertDialog(context, "格式错误", e.message);
    } catch (e) {
      showAlertDialog(context, "未知错误", e.toString());
      rethrow;
    }
  }

  Widget buildTextField(TextEditingController controller, String label, {TextInputType? inputType, List<TextInputFormatter>? inputFormatters}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderSide: BorderSide(),
            borderRadius: BorderRadius.all(Radius.circular(14.0)),
            gapPadding: 8.0,
          ),
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
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderSide: BorderSide(),
            borderRadius: BorderRadius.all(Radius.circular(14.0)),
            gapPadding: 8.0,
          ),
        ),
        value: initialValue,
        onChanged: onChanged,
        items: options.entries.map((entry) => DropdownMenuItem<T>(value: entry.key, child: Text(entry.value))).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: contentWidth,
            child: Column(
              children: [
                TopBar(
                  context,
                  "输入提供的密钥",
                  rightIcon: Icons.save,
                  rightOnPressed: (context) => onSave.call(context),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    child: Column(
                      children: [
                        buildDropdown<Type>("类型", config.type, typeLabels, (value) {
                          setState(() {
                            config.type = value!;
                          });
                        }),
                        buildTextField(issuerController, "发行方"),
                        buildTextField(accountController, "用户名"),
                        buildTextField(secretController, "密钥"),
                        if (config.type == Type.totp || config.type == Type.hotp) buildDropdown<Algorithm>("算法", config.algorithm, algorithmLabels, (value) => config.algorithm = value!),
                        if (config.type == Type.motp) buildTextField(pinController, "PIN码"),
                        if (config.type == Type.totp || config.type == Type.hotp || config.type == Type.motp)
                          Row(
                            children: [
                              Expanded(child: buildTextField(digitsController, "位数", inputType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly])),
                              if (config.type == Type.totp || config.type == Type.motp) Expanded(child: buildTextField(periodController, "时间间隔(秒)", inputType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly])),
                              if (config.type == Type.hotp) Expanded(child: buildTextField(counterController, "计数器", inputType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly])),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  final Map<Type, String> typeLabels = {
    Type.totp: "基于时间 (TOTP)",
    Type.hotp: "基于计数器 (HOTP)",
    Type.motp: "Mobile-OTP (mOTP)",
  };

  final Map<Algorithm, String> algorithmLabels = {
    Algorithm.SHA1: "SHA1",
    Algorithm.SHA256: "SHA256",
    Algorithm.SHA512: "SHA512",
  };
}
