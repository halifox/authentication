import 'package:auth/otp.dart';
import 'package:base32/base32.dart';
import 'package:sembast/sembast.dart';

/// 认证类型枚举，用于定义不同的认证方式。
///
/// 此枚举用于表示支持的认证类型：
/// - [totp] 基于时间的一次性密码 (Time-based One-Time Password)
/// - [hotp] 基于计数器的一次性密码 (HMAC-based One-Time Password)
/// - [motp] 基于移动设备的一次性密码 (Mobile-based One-Time Password)

/// 认证配置类，用于创建认证实例并设置相关参数。
///
/// 此类用于配置并生成认证所需的各种参数，包括认证类型、密钥、哈希算法等。
///
/// [type] 认证类型，决定使用 TOTP 或 HOTP。默认为 TOTP。
/// [account] 账户标识符，通常是账户名或应用名称，不能为空。
/// [secret] 用于生成一次性密码的密钥，不能为空。
/// [issuer] 认证发行方，通常是认证服务提供商或应用的名称，不能为空。
/// [algorithm] 用于生成一次性密码的哈希算法，默认为 SHA1。
/// [digits] 生成一次性密码的位数，默认为 6 位。
/// [interval] 密码生成周期，适用于 TOTP，默认为 30 秒。
/// [counter] 计数器，适用于 HOTP，默认为 0。
/// [pin] 用户设置的 PIN，默认为空字符串。
/// [isBase32] 指示是否使用 Base32 编码，适用于 Google 实现，默认为 true。

class AuthConfig {
  String scheme;
  String type;
  String issuer;
  String account;
  String secret;
  String algorithm;
  int digits;
  int interval;
  int counter;
  String pin;
  bool isBase32;
  String icon;

  //neglect
  String key;

  AuthConfig({
    this.scheme = 'otpauth',
    this.type = 'totp',
    this.issuer = '',
    this.account = '',
    this.secret = '',
    this.algorithm = 'sha1',
    this.digits = 6,
    this.interval = 30,
    this.counter = 0,
    this.pin = '',
    this.isBase32 = true,
    this.icon = 'assets/icons/passkey.svg',
    this.key = '',
  });

  bool verify() {
    try {
      verifyThrow();
      return true;
    } catch (e) {
      return false;
    }
  }

  verifyThrow() {
    scheme = switch (scheme.toLowerCase()) {
      'otpauth' => scheme,
      String() => throw ArgumentError(),
    };

    type = switch (type.toLowerCase()) {
      'totp' => type,
      'hotp' => type,
      'motp' => type,
      String() => throw ArgumentError(),
    };

    if (issuer.isEmpty) {
      throw ArgumentError();
    }

    if (account.isEmpty) {
      throw ArgumentError();
    }

    algorithm = switch (algorithm.toLowerCase()) {
      'sha1' => algorithm,
      'sha256' => algorithm,
      'sha512' => algorithm,
      String() => throw ArgumentError(),
    };

    switch (type.toLowerCase()) {
      case 'totp':
        if (digits < 6 || digits > 8) {
          throw ArgumentError();
        }
        if (interval <= 0) {
          throw ArgumentError();
        }
      case 'hotp':
        if (digits < 6 || digits > 8) {
          throw ArgumentError();
        }
        if (counter < 0) {
          throw ArgumentError();
        }

      case 'motp':
        if (digits == 6) {
          throw ArgumentError();
        }
        if (pin.isEmpty) {
          throw ArgumentError();
        }
    }
    if (isBase32 && !AuthConfig.verifyBase32(secret)) {
      throw ArgumentError();
    }
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'scheme': scheme,
      'type': type,
      'issuer': issuer,
      'account': account,
      'secret': secret,
      'algorithm': algorithm,
      'digits': digits,
      'interval': interval,
      'counter': counter,
      'pin': pin,
      'isBase32': isBase32,
      'icon': icon,
    };
  }

  factory AuthConfig.fromJson(RecordSnapshot<String, dynamic> map) {
    return AuthConfig(
      key: map.key,
      scheme: map['scheme'] as String,
      type: map['type'] as String,
      issuer: map['issuer'] as String,
      account: map['account'] as String,
      secret: map['secret'] as String,
      algorithm: map['algorithm'] as String,
      digits: map['digits'] as int,
      interval: map['interval'] as int,
      counter: map['counter'] as int,
      pin: map['pin'] as String,
      isBase32: map['isBase32'] as bool,
      icon: map['icon'] as String,
    );
  }

  /// 计算并生成当前的 OTP 密码
  ///
  /// 返回生成的 OTP 密码字符串。
  String generateCodeString() {
    return switch (type) {
      'totp' => OTP.generateTOTPCodeString(
        secret: secret,
        digits: digits,
        algorithm: parseAlgorithm(algorithm),
        intervalSeconds: interval,
        isBase32: isBase32,
      ),
      'hotp' => OTP.generateHOTPCodeString(
        secret: secret,
        digits: digits,
        algorithm: parseAlgorithm(algorithm),
        counter: counter,
        isBase32: isBase32,
      ),
      'motp' => OTP.generateMOTPCodeString(
        secret: secret,
        digits: digits,
        intervalSeconds: interval,
        pin: pin,
      ),
      String() => throw UnimplementedError(),
    };
  }

  /// 验证输入字符串是否为有效的 Base32 编码。
  ///
  /// 该方法会检查提供的字符串是否符合 Base32 编码规则。
  ///
  /// [input] 要检查的字符串，可以为 null 或空字符串。
  ///
  /// 返回一个布尔值：
  /// - 如果输入是有效的 Base32 编码，则返回 true。
  /// - 否则返回 false。
  static bool verifyBase32(String? input) {
    try {
      if (input == null || input.isEmpty) {
        throw ArgumentError('Invalid secret');
      }
      base32.decode(input);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 解析 URI 字符串并生成对应的认证配置实例。
  ///
  /// 该方法解析 OTP URI，并提取出相关参数以创建一个 [AuthConfig] 实例。
  ///
  /// [uriString] 要解析的 URI 字符串，格式应符合 OTP URI 标准，例如 `otpauth://totp/example:alice@domain.com?secret=YOURSECRET&issuer=Example&algorithm=SHA1&digits=6&period=30`。
  ///
  /// 返回解析后的 [AuthConfig] 实例，包含了所有相关的认证配置参数。
  ///
  /// URI 格式说明：
  /// - **协议**: URI 协议标识符，通常为 `otpauth`，表示 OTP 认证。
  /// - **类型 (TYPE)**: OTP 类型，通常为 `totp` 或 `hotp`。
  /// - **标签 (LABEL)**: 用户账户信息，格式为 `Issuer:AccountName`，例如 `example:alice@domain.com`，其中 `Issuer` 为认证服务提供商，`AccountName` 为账户名。
  ///     如果 LABEL 中没有 :，那么它通常只包含账户名，而不指定发行者（Issuer）。在这种情况下，LABEL 会简单地表示用户名，而发行者可以通过其他方式指定，通常是在 PARAMETERS 中通过 issuer 参数来指定。
  /// - **参数 (PARAMETERS)**: 一系列查询参数，用于定义 OTP 生成规则：
  ///     - `secret`: 生成 OTP 的密钥，必需参数，通常是 Base32 编码的字符串。
  ///     - `algorithm`: 可选参数，指定哈希算法，默认为 `SHA1`，可以是 `SHA256` 或 `SHA512`。
  ///     - `digits`: 可选参数，表示 OTP 位数，通常为 6 或 8，默认为 6。
  ///     - `period`: 可选参数，适用于 `totp`，表示 OTP 有效时间周期，默认为 30 秒。
  ///     - `counter`: 可选参数，适用于 `hotp`，指定当前计数器值。
  static AuthConfig parse(String uriString) {
    final uri = Uri.parse(uriString);
    final scheme = uri.scheme;
    final type = uri.host;
    final label = Uri.decodeFull(uri.path.substring(1));
    final issuer = uri.queryParameters['issuer'];
    final account = uri.queryParameters['account'];
    final algorithm = uri.queryParameters['algorithm'] ?? 'sha1';
    final secret = uri.queryParameters['secret']!;
    final digits = uri.queryParameters['digits'] ?? '6';
    final period = uri.queryParameters['period'] ?? '30';
    final counter = uri.queryParameters['counter'] ?? '0';

    return AuthConfig(
      scheme: scheme,
      type: type,
      account: parseAccount(label, account),
      secret: secret,
      issuer: parseIssuer(label, issuer),
      algorithm: algorithm,
      digits: int.parse(digits),
      interval: int.parse(period),
      counter: int.parse(counter),
    );
  }

  static String parseIssuer(String label, String? issuer) {
    if (label.contains(':')) {
      return issuer ?? label.split(':')[0];
    } else {
      return issuer ?? '未提供发行者';
    }
  }

  static String parseAccount(String label, String? issuer) {
    if (label.contains(':')) {
      return label.split(':')[1];
    } else {
      return label;
    }
  }

  static Algorithm parseAlgorithm(String algorithm) {
    return switch (algorithm.toLowerCase()) {
      'sha1' => Algorithm.SHA1,
      'sha256' => Algorithm.SHA256,
      'sha512' => Algorithm.SHA512,
      String() => throw UnimplementedError(),
    };
  }

  static String checkSecret(String? secret) {
    if (secret == null || !verifyBase32(secret)) {
      throw ArgumentError('Invalid secret');
    }
    return secret;
  }
}

class ErrorArgumentError extends ArgumentError {}

class WarnArgumentError extends ArgumentError {}
