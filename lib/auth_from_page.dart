import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:purity_auth/auth.dart';
import 'package:purity_auth/auth_repository.dart';
import 'package:purity_auth/image_tools.dart';
import 'package:purity_auth/otp.dart';
import 'package:purity_auth/top_bar.dart';
import 'package:purity_auth/window_size_controller.dart';

class AuthFromPage extends StatelessWidget {
  AuthFromPage({super.key});

  final windowSizeController = Get.put(WindowSizeController());

  final Rx<AuthConfiguration> rxConfiguration = Rx(Get.arguments ?? AuthConfiguration());

  AuthConfiguration get configuration => rxConfiguration.value;
  late final TextEditingController issuerController = TextEditingController(text: configuration.issuer);
  late final TextEditingController accountController = TextEditingController(text: configuration.account);
  late final TextEditingController secretController = TextEditingController(text: configuration.secret);
  late final TextEditingController pinController = TextEditingController(text: configuration.pin);
  late final TextEditingController digitsController = TextEditingController(text: configuration.digits.toString());
  late final TextEditingController periodController = TextEditingController(text: configuration.intervalSeconds.toString());
  late final TextEditingController counterController = TextEditingController(text: configuration.counter.toString());

  Future<void> onSave() async {
    try {
      configuration
        ..account = accountController.text
        ..issuer = issuerController.text
        ..secret = secretController.text
        ..pin = pinController.text
        ..digits = int.parse(digitsController.text)
        ..intervalSeconds = int.parse(periodController.text)
        ..counter = int.parse(counterController.text);
      await Get.find<AuthRepository>().upsert(configuration);
      Get.until((route) => Get.currentRoute == "/");
      showAlert("结果", "添加成功");
    } on ArgumentError catch (e) {
      showAlert("参数错误", e.message);
    } on FormatException catch (e) {
      showAlert("格式错误", e.message);
    } catch (e) {
      showAlert("未知错误", e.toString());
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
          child: Obx(
            () => SizedBox(
              width: windowSizeController.contentWidth.value,
              child: Column(
                children: [
                  TopBar(
                    "输入提供的密钥",
                    rightIcon: Icons.save,
                    rightOnPressed: onSave,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                      child: Column(
                        children: [
                          buildDropdown<AuthType>("类型", configuration.type, typeLabels, (value) {
                            rxConfiguration.update((configuration) {
                              configuration?.type = value!;
                            });
                          }),
                          buildTextField(issuerController, "发行方"),
                          buildTextField(accountController, "用户名"),
                          buildTextField(secretController, "密钥"),
                          if (configuration.type == AuthType.totp || configuration.type == AuthType.hotp)
                            buildDropdown<Algorithm>("算法", configuration.algorithm, algorithmLabels, (value) => configuration.algorithm = value!),
                          if (configuration.type == AuthType.motp) buildTextField(pinController, "PIN码"),
                          if (configuration.type == AuthType.totp || configuration.type == AuthType.hotp || configuration.type == AuthType.motp)
                            Row(
                              children: [
                                Expanded(child: buildTextField(digitsController, "位数", inputType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly])),
                                if (configuration.type == AuthType.totp || configuration.type == AuthType.motp)
                                  Expanded(child: buildTextField(periodController, "时间间隔(秒)", inputType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly])),
                                if (configuration.type == AuthType.hotp)
                                  Expanded(child: buildTextField(counterController, "计数器", inputType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly])),
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
      ),
    );
  }

  final Map<AuthType, String> typeLabels = {
    AuthType.totp: "基于时间 (TOTP)",
    AuthType.hotp: "基于计数器 (HOTP)",
    AuthType.motp: "Mobile-OTP (mOTP)",
  };

  final Map<Algorithm, String> algorithmLabels = {
    Algorithm.SHA1: "SHA1",
    Algorithm.SHA256: "SHA256",
    Algorithm.SHA512: "SHA512",
  };
}
