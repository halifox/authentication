import 'package:base32/base32.dart';
import 'package:purity_auth/otp.dart';

enum Scheme {
  otpauth,
}

/// 认证类型枚举，用于定义不同的认证方式。
///
/// 此枚举用于表示支持的认证类型：
/// - [totp] 基于时间的一次性密码 (Time-based One-Time Password)
/// - [hotp] 基于计数器的一次性密码 (HMAC-based One-Time Password)
/// - [motp] 基于移动设备的一次性密码 (Mobile-based One-Time Password)

enum Type {
  totp,
  hotp,
  motp,
}

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
/// [intervalSeconds] 密码生成周期，适用于 TOTP，默认为 30 秒。
/// [counter] 计数器，适用于 HOTP，默认为 0。
/// [pin] 用户设置的 PIN，默认为空字符串。
/// [isBase32Encoded] 指示是否使用 Base32 编码，适用于 Google 实现，默认为 true。

class AuthenticationConfig {
  Scheme scheme;
  Type type;
  String issuer;
  String account;
  String secret;
  Algorithm algorithm;
  int digits;
  int intervalSeconds;
  int counter;
  String pin;

  bool isBase32Encoded;

  // 内部生成的密钥，通常由系统自动处理
  String? key;

  AuthenticationConfig({
    this.scheme = Scheme.otpauth,
    this.type = Type.totp,
    this.account = '',
    this.secret = '',
    this.issuer = '',
    this.algorithm = Algorithm.SHA1,
    this.digits = 6,
    this.intervalSeconds = 30,
    this.counter = 0,
    this.pin = '',
    this.isBase32Encoded = true,
    bool isVerify = false,
  }) {
    if (isVerify) {
      verify();
    }
  }

  verify() {
    if (issuer.isEmpty) {
      throw ArgumentError("发行方不得为空或空白。");
    }
    if (type == Type.totp) {
      if (digits < 6 || digits > 10) {
        throw ArgumentError("对于 TOTP，位数必须介于 6 到 10 之间");
      }
      if (intervalSeconds <= 0) {
        throw ArgumentError("时间间隔必须 > 0");
      }
    }

    if (type == Type.hotp) {
      if (digits < 6 || digits > 8) {
        throw ArgumentError("对于 HOTP，位数必须介于 6 到 8 之间");
      }
      if (counter < 0) {
        throw ArgumentError("计数必须必须 >= 0");
      }
    }

    if (type == Type.motp) {
      if (digits < 6 || digits > 10) {
        throw ArgumentError("对于 Mobile-OTP，位数必须介于 6 到 10 之间");
      }
      if (pin.isEmpty) {
        throw ArgumentError("对于 Mobile-OTP，必须设置 pin 字段。");
      }
    }

    if (isBase32Encoded && !AuthenticationConfig.verifyBase32(secret)) {
      throw ArgumentError('对于 HOTP 和 TOTP，验证器密钥必须是不带空格的大写 base-32 字符串。它还可以包含“=”作为填充字符。');
    }
  }

  static Map<String, dynamic> toJson(AuthenticationConfig config) {
    return <String, dynamic>{
      'scheme': config.scheme.index,
      'type': config.type.index,
      'account': config.account,
      'secret': config.secret,
      'issuer': config.issuer,
      'algorithm': config.algorithm.index,
      'digits': config.digits,
      'intervalSeconds': config.intervalSeconds,
      'counter': config.counter,
      'pin': config.pin,
      'isBase32Encoded': config.isBase32Encoded,
    };
  }

  factory AuthenticationConfig.fromJson(Map<String, dynamic> map) {
    return AuthenticationConfig(
      scheme: Scheme.values.elementAt(map['scheme'] as int),
      type: Type.values.elementAt(map['type'] as int),
      account: map['account'] as String,
      secret: map['secret'] as String,
      issuer: map['issuer'] as String,
      algorithm: Algorithm.values.elementAt(map['algorithm'] as int),
      digits: map['digits'] as int,
      intervalSeconds: map['intervalSeconds'] as int,
      counter: map['counter'] as int,
      pin: map['pin'] as String,
      isBase32Encoded: map['isBase32Encoded'] as bool,
    );
  }

  /// 计算并生成当前的 OTP 密码
  ///
  /// 返回生成的 OTP 密码字符串。
  String generateCodeString() {
    switch (type) {
      case Type.totp:
        return OTP.generateTOTPCodeString(secret: secret, digits: digits, intervalSeconds: intervalSeconds, algorithm: algorithm, isBase32: isBase32Encoded);
      case Type.hotp:
        return OTP.generateHOTPCodeString(secret: secret, counter: counter, digits: digits, algorithm: algorithm, isBase32: isBase32Encoded);
      case Type.motp:
        return OTP.generateMOTPCodeString(secret: secret, pin: pin, intervalSeconds: intervalSeconds, digits: digits);
    }
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
  /// 该方法解析 OTP URI，并提取出相关参数以创建一个 [AuthenticationConfig] 实例。
  ///
  /// [uriString] 要解析的 URI 字符串，格式应符合 OTP URI 标准，例如 `otpauth://totp/example:alice@domain.com?secret=YOURSECRET&issuer=Example&algorithm=SHA1&digits=6&period=30`。
  ///
  /// 返回解析后的 [AuthenticationConfig] 实例，包含了所有相关的认证配置参数。
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
  static AuthenticationConfig parse(String uriString) {
    final Uri uri = Uri.parse(uriString);

    final String scheme = uri.scheme;
    final String type = uri.host;
    final String label = Uri.decodeFull(uri.path.substring(1));
    final String? issuer = uri.queryParameters['issuer'];
    final String? account = uri.queryParameters['account'];
    final String? algorithm = uri.queryParameters['algorithm'];
    final String? secret = uri.queryParameters['secret'];
    final String digits = uri.queryParameters['digits'] ?? '6';
    final String period = uri.queryParameters['period'] ?? '30';
    final String counter = uri.queryParameters['counter'] ?? '0';

    return AuthenticationConfig(
      scheme: parseScheme(scheme),
      type: parseType(type),
      account: parseAccount(label, issuer),
      secret: parseSecret(secret),
      issuer: parseIssuer(label, issuer),
      algorithm: parseAlgorithm(algorithm),
      digits: int.parse(digits),
      intervalSeconds: int.parse(period),
      counter: int.parse(counter),
    );
  }

  static Scheme parseScheme(String? scheme) {
    switch (scheme?.toUpperCase()) {
      case 'OTPAUTH':
        return Scheme.otpauth;
      default:
        throw ArgumentError('Invalid scheme: $scheme');
    }
  }

  static Type parseType(String? type) {
    switch (type?.toUpperCase()) {
      case 'TOTP':
        return Type.totp;
      case 'HOTP':
        return Type.hotp;
      default:
        throw ArgumentError('Invalid type: $type');
    }
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

  static Algorithm parseAlgorithm(String? algorithm) {
    switch (algorithm?.toUpperCase()) {
      case null:
        return Algorithm.SHA1;
      case 'SHA1':
        return Algorithm.SHA1;
      case 'SHA256':
        return Algorithm.SHA256;
      case 'SHA512':
        return Algorithm.SHA512;
      default:
        throw ArgumentError('Invalid algorithm: $algorithm');
    }
  }

  static String parseSecret(String? secret) {
    if (secret == null || !verifyBase32(secret)) {
      throw ArgumentError('Invalid secret');
    }
    return secret;
  }
}
