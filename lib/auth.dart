import 'package:base32/base32.dart';
import 'package:purity_auth/otp.dart';

// 枚举定义认证类型
enum Type {
  totp, // 基于时间的一次性密码 (Time-based One-Time Password)
  hotp, // 基于计数器的一次性密码 (HMAC-based One-Time Password)
  motp,
}

enum Scheme {
  otpauth,
}

/// 创建一个 Auth 实例
///
/// [type] 认证类型，默认为 TOTP。
/// [account] 标识符，通常是账户或应用的名称，不能为空。
/// [secret] 密钥，用于生成一次性密码的基础密钥，不能为空。
/// [issuer] 发行方，通常是认证服务提供商或应用的名称，不能为空。
/// [algorithm] 哈希算法，默认为 SHA1。
/// [digits] 生成的密码位数，默认为 6。
/// [intervalSeconds] 周期，适用于 TOTP，默认为 30。
/// [counter] 计数器，适用于 HOTP，默认为 0。
/// [pin] PIN，默认为空字符串。
/// [isBase32Encoded] 指示是否为 Google 的实现，默认为 true。
class AuthConfiguration {
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

  //internal
  String? dbKey;

  AuthConfiguration({
    this.scheme = Scheme.otpauth,
    this.type = Type.totp,
    this.account = "",
    this.secret = "",
    this.issuer = "",
    this.algorithm = Algorithm.SHA1,
    this.digits = 6,
    this.intervalSeconds = 30,
    this.counter = 0,
    this.pin = "",
    this.isBase32Encoded = true,
  });

  /// 将 Auth 实例转换为 JSON 格式
  ///
  /// [configuration] 要转换的 Auth 实例。
  /// 返回一个包含 Auth 实例属性的 Map。
  static Map<String, dynamic> toJson(AuthConfiguration configuration) {
    return {
      'scheme': configuration.scheme.index,
      'type': configuration.type.index,
      'account': configuration.account,
      'secret': configuration.secret,
      'issuer': configuration.issuer,
      'algorithm': configuration.algorithm.index,
      'digits': configuration.digits,
      'intervalSeconds': configuration.intervalSeconds,
      'counter': configuration.counter,
      'pin': configuration.pin,
      'isBase32Encoded': configuration.isBase32Encoded,
    };
  }

  /// 从 JSON 格式中创建一个 Auth 实例
  ///
  /// [map] 包含 Auth 属性的 Map。
  /// 返回一个新的 Auth 实例。
  factory AuthConfiguration.fromJson(Map<String, dynamic> map) {
    return AuthConfiguration(
      scheme: Scheme.values.elementAt(map['scheme']),
      type: Type.values.elementAt(map['type']),
      account: map['account'] as String,
      secret: map['secret'] as String,
      issuer: map['issuer'] as String,
      algorithm: Algorithm.values.elementAt(map['algorithm']),
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

  /// 检查输入字符串是否为有效的 Base32 编码。
  ///
  /// [input] 要检查的字符串，可以为 null。
  /// 返回一个布尔值，表示是否有效的 Base32 编码。
  static bool verifyBase32(String? input) {
    try {
      if (input == null || input.isEmpty) {
        throw ArgumentError("Invalid secret");
      }
      base32.decode(input);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 解析 URI 字符串。
  ///
  /// [uriString] 要解析的 URI 字符串。
  /// 返回创建的 Auth 实例。
  // otpauth://: URI 协议，表示这是一个用于 OTP 的 URI。
  //
  // TYPE: OTP 类型，有两种：
  //
  //     totp：基于时间的一次性密码。
  //     hotp：基于计数器的一次性密码。
  //
  // LABEL: 标记用户的账户信息，通常表示为 Issuer:AccountName，比如 example:alice@domain.com。: 之前的部分为发行者，之后为用户名。
  //        如果 LABEL 中没有 :，那么它通常只包含账户名，而不指定发行者（Issuer）。在这种情况下，LABEL 会简单地表示用户名，而发行者可以通过其他方式指定，通常是在 PARAMETERS 中通过 issuer 参数来指定。
  //
  // PARAMETERS: 一系列参数，用于定义 OTP 的生成规则：
  //     secret：必需参数，生成 OTP 的密钥，通常是 base32 编码的字符串。
  //     algorithm：可选参数，指定哈希算法，默认是 SHA1，可以是 SHA256 或 SHA512。
  //     digits：可选参数，表示 OTP 的位数，通常为 6 或 8，默认是 6。
  //     period：可选参数，用于 totp 类型，表示 OTP 的有效时间段，默认是 30 秒。
  //     counter：用于 hotp 类型的计数器，指定当前的计数值。

  static AuthConfiguration parse(String uriString) {
    Uri uri = Uri.parse(uriString);

    String? scheme = uri.scheme;
    String? type = uri.host;
    String? label = Uri.decodeFull(uri.path.substring(1));
    String? issuer = uri.queryParameters['issuer'];
    String? account = uri.queryParameters['account'];
    String? algorithm = uri.queryParameters['algorithm'];
    String? secret = uri.queryParameters['secret'];
    String digits = uri.queryParameters['digits'] ?? "6";
    String period = uri.queryParameters['period'] ?? "30";
    String counter = uri.queryParameters['counter'] ?? "0";

    return AuthConfiguration(
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
      case "OTPAUTH":
        return Scheme.otpauth;
      default:
        throw ArgumentError("Invalid scheme: $scheme");
    }
  }

  static Type parseType(String? type) {
    switch (type?.toUpperCase()) {
      case "TOTP":
        return Type.totp;
      case "HOTP":
        return Type.hotp;
      default:
        throw ArgumentError("Invalid type: $type");
    }
  }

  static String parseIssuer(String label, String? issuer) {
    if (label.contains(':')) {
      return issuer ?? label.split(':')[0];
    } else {
      return issuer ?? "未提供发行者";
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
      case "SHA1":
        return Algorithm.SHA1;
      case "SHA256":
        return Algorithm.SHA256;
      case "SHA512":
        return Algorithm.SHA512;
      default:
        throw ArgumentError("Invalid algorithm: $algorithm");
    }
  }

  static String parseSecret(String? secret) {
    if (secret == null || !verifyBase32(secret)) {
      throw ArgumentError("Invalid secret");
    }
    return secret;
  }
}
