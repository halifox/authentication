import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:base32/base32.dart' as base32;
import 'package:crypto/crypto.dart' as crypto;
import 'package:hashlib/hashlib.dart' as hashlib;

/// Form:https://github.com/daegalus/dart-otp/blob/master/lib/otp.dart
/// Form:https://github.com/elliotwutingfeng/motp/blob/main/lib/src/motp_base.dart

/// RFC4226/RFC6238 One-Time Password Library
class OTP {
  /// 用于为 HOTP 的 SHA256 和 SHA512 使用启用 TOTP 样式的密钥填充。默认为假。
  static bool useTOTPPaddingForHOTP = false;

  /// 生成基于时间的一次性密码代码
  ///
  /// 以毫秒为单位获取当前时间，转换为秒并按间隔除以在间隔的每次迭代中获取代码。间隔 1 与将时间传递到 HOTPCode 函数中相同。
  ///
  /// 用于更改提供的代码长度（默认 6）、间隔（默认 30）和哈希算法（默认 SHA256）的可选参数。这些设置默认为 RFC 标准，但可以更改。如果字符串不是 Base32 机密，则抛出 FormatException。
  static int generateTOTPCode({required String secret, int? unixMilliseconds, int digits = 6, int intervalSeconds = 30, Algorithm algorithm = Algorithm.SHA256, bool isBase32 = false}) {
    unixMilliseconds ??= DateTime.now().millisecondsSinceEpoch;
    if (intervalSeconds < 1) {
      throw ArgumentError('intervalSeconds must be positive.');
    }
    if (digits < 1 || digits > 32) {
      throw ArgumentError('digits must be in the range 1-32.');
    }
    if (unixMilliseconds < 0) {
      throw ArgumentError('unixMilliseconds must be non-negative.');
    }
    unixMilliseconds = (((unixMilliseconds ~/ 1000).round()) ~/ intervalSeconds).floor();
    return _generateCode(secret, unixMilliseconds, digits, getHashFunction(algorithm), getByteLength(algorithm), isBase32: isBase32);
  }

  /// 生成基于时间的一次性密码代码并以 0 填充的字符串形式返回。
  ///
  /// 以毫秒为单位获取当前时间，转换为秒并按间隔除以在间隔的每次迭代中获取代码。间隔 1 与将时间传递到 HOTPCode 函数中相同。
  ///
  /// 用于更改提供的代码长度（默认 6）、间隔（默认 30）和哈希算法（默认 SHA256）的可选参数。这些设置默认为 RFC 标准，但可以更改。如果字符串不是 Base32 机密，则抛出 FormatException。
  static String generateTOTPCodeString({required String secret, int? unixMilliseconds, int digits = 6, int intervalSeconds = 30, Algorithm algorithm = Algorithm.SHA256, bool isBase32 = false}) {
    return '${generateTOTPCode(secret: secret, unixMilliseconds: unixMilliseconds, digits: digits, intervalSeconds: intervalSeconds, algorithm: algorithm, isBase32: isBase32)}'.padLeft(digits, '0');
  }

  /// 根据您提供并递增的计数器生成一次性密码代码。
  ///
  /// This function does not increment for you.
  /// 用于更改提供的代码长度（默认 6）和散列算法（默认 SHA1）的可选参数 这些设置默认为 RFC 标准，但可以更改。如果字符串不是 Base32 机密，则抛出 FormatException。
  static int generateHOTPCode({required String secret, required int counter, int digits = 6, Algorithm algorithm = Algorithm.SHA1, bool isBase32 = false}) {
    return _generateCode(secret, counter, digits, getHashFunction(algorithm), getByteLength(algorithm), isHOTP: true, isBase32: isBase32);
  }

  /// 根据您提供的计数器生成一次性密码代码并递增，以 0 填充的字符串形式返回。
  ///
  /// This function does not increment for you.
  /// 用于更改提供的代码长度（默认 6）和散列算法（默认 SHA1）的可选参数 这些设置默认为 RFC 标准，但可以更改。如果字符串不是 Base32 机密，则抛出 FormatException。
  static String generateHOTPCodeString({required String secret, required int counter, int digits = 6, Algorithm algorithm = Algorithm.SHA1, bool isBase32 = false}) {
    return '${generateHOTPCode(secret: secret, counter: counter, digits: digits, algorithm: algorithm, isBase32: isBase32)}'.padLeft(digits, '0');
  }

  static String generateMOTPCodeString({required String secret, required String pin, int intervalSeconds = 10, int digits = 6, int? unixMilliseconds}) {
    unixMilliseconds ??= DateTime.now().millisecondsSinceEpoch;
    if (intervalSeconds < 1) {
      throw ArgumentError('intervalSeconds must be positive.');
    }
    if (digits < 1 || digits > 32) {
      throw ArgumentError('digits must be in the range 1-32.');
    }
    if (unixMilliseconds < 0) {
      throw ArgumentError('unixMilliseconds must be non-negative.');
    }
    return hashlib.md5sum('${((unixMilliseconds ~/ 1000).round()) ~/ intervalSeconds}$secret$pin', null, true).substring(0, digits);
  }

  static int _generateCode(String secret, int time, int length, crypto.Hash mac, int secretbytes, {bool isHOTP = false, bool isBase32 = false}) {
    length = (length > 0) ? length : 6;

    Uint8List secretList = Uint8List.fromList(utf8.encode(secret));
    if (isBase32) {
      secretList = base32.base32.decode(secret.toUpperCase());
    }

    if (!isBase32 && (!isHOTP || useTOTPPaddingForHOTP)) {
      secretList = _padSecret(secretList, secretbytes);
    } else if (isHOTP && !isBase32) {
      _showHOTPWarning(mac);
    }

    final Uint8List timebytes = _int2bytes(time);

    final crypto.Hmac hmac = crypto.Hmac(mac, secretList);
    final List<int> digest = hmac.convert(timebytes).bytes;

    final int offset = digest[digest.length - 1] & 0x0f;

    final int binary = ((digest[offset] & 0x7f) << 24) | ((digest[offset + 1] & 0xff) << 16) | ((digest[offset + 2] & 0xff) << 8) | (digest[offset + 3] & 0xff);

    return binary % pow(10, length) as int;
  }

  /// 主要用于测试目的，但这可以根据您的设置为您提供内部摘要。此函数无需掌握，因此您需要确切地知道要传入的内容。
  static String getInternalDigest(String secret, int counter, int length, crypto.Hash mac, {bool isGoogle = false}) {
    length = (length > 0) ? length : 6;

    Uint8List secretList = Uint8List.fromList(utf8.encode(secret));
    if (isGoogle) {
      secretList = base32.base32.decode(secret);
    }
    final Uint8List timebytes = _int2bytes(counter);

    final crypto.Hmac hmac = crypto.Hmac(mac, secretList);
    final List<int> digest = hmac.convert(timebytes).bytes;

    return _hexEncode(Uint8List.fromList(digest));
  }

  /// 允许您在恒定时间内比较 2 个代码，以减轻对安全代码的定时攻击。
  ///
  /// 该函数需要 2 个字符串格式的代码。
  static bool constantTimeVerification(final String code, final String othercode) {
    if (code.length != othercode.length) {
      return false;
    }

    bool result = true;
    for (int i = 0; i < code.length; i++) {
      // Keep result at the end otherwise Dart VM will shortcircuit on a result thats already false.
      result = (code[i] == othercode[i]) && result;
    }
    return result;
  }

  /// 生成 Base32 字符串格式的加密安全随机秘密。
  static String randomSecret() {
    final Random rand = Random.secure();
    final List<int> bytes = <int>[];

    for (int i = 0; i < 10; i++) {
      bytes.add(rand.nextInt(256));
    }

    return base32.base32.encode(Uint8List.fromList(bytes));
  }

  /// 当前时间步窗口中还剩多少时间（以毫秒为单位）
  static int remainingMilliseconds({int intervalMilliseconds = 30 * 1000, int? unixMilliseconds}) {
    unixMilliseconds ??= DateTime.now().millisecondsSinceEpoch;
    if (unixMilliseconds < 0) {
      throw ArgumentError('unixSeconds must be non-negative.');
    }
    return intervalMilliseconds - (unixMilliseconds % intervalMilliseconds);
  }

  static String _hexEncode(final Uint8List input) => <String>[for (int i = 0; i < input.length; i++) input[i].toRadixString(16).padLeft(2, '0')].join();

  static Uint8List _int2bytes(int long) {
    // we want to represent the input as a 8-bytes array
    final Uint8List byteArray = Uint8List(8);

    for (int index = byteArray.length - 1; index >= 0; index--) {
      final int byte = long & 0xff;
      byteArray[index] = byte;
      long = (long - byte) ~/ 256;
    }
    return byteArray;

    // Cleaner implementation but breaks in dart2js/flutter web
    // return Uint8List(8)..buffer.asByteData().setInt64(0, long);
  }

  static Uint8List _padSecret(Uint8List secret, int length) {
    if (secret.length >= length) return secret;
    if (secret.isEmpty) return secret;
    // ignore: prefer_collection_literals
    final List<int> newList = <int>[];
    for (int i = 0; i * secret.length < length; i++) {
      newList.addAll(secret);
    }

    return Uint8List.fromList(newList.sublist(0, length));
  }

  static void _showHOTPWarning(crypto.Hash mac) {
    if (mac == crypto.sha256 || mac == crypto.sha512) {
      print('将非 SHA1 哈希与 HOTP 一起使用不是 HOTP RFC 的一部分，并且可能会导致不同库实现之间的不兼容。该库尝试尽可能地与其他库匹配行为。');
    }
  }

  static const Map<Algorithm, crypto.Hash> HashFunctions = <Algorithm, crypto.Hash>{Algorithm.SHA256: crypto.sha256, Algorithm.SHA512: crypto.sha512, Algorithm.SHA1: crypto.sha1};

  static const Map<Algorithm, int> ByteLengths = <Algorithm, int>{Algorithm.SHA256: 32, Algorithm.SHA512: 64, Algorithm.SHA1: 20};

  ///获取指定算法的 Hash 函数
  static crypto.Hash getHashFunction(Algorithm algorithm) {
    return HashFunctions[algorithm]!;
  }

  /// 获取指定算法所需的字节长度
  static int getByteLength(Algorithm algorithm) {
    return ByteLengths[algorithm]!;
  }
}

/// 用于生成一次性密码代码的哈希算法
enum Algorithm { SHA1, SHA256, SHA512 }
