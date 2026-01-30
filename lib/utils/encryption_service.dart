import 'package:encrypt/encrypt.dart';

/// 提供简单的数据加密和解密服务。
/// 注意：在生产环境中，Key 应该由 flutter_secure_storage 或设备的安全芯片生成/存储。
/// 为了演示架构，这里使用固定 Key 或简单的派生 Key。
class EncryptionService {
  // 这里的 Key 仅作演示。实际应用应从安全存储读取或由用户密码派生。
  static final _key = Key.fromUtf8('PurityAuthSecretKey32CharsLong!'); 
  static final _iv = IV.fromLength(16);
  static final _encrypter = Encrypter(AES(_key));

  /// 加密字符串
  static String encrypt(String plainText) {
    if (plainText.isEmpty) return '';
    try {
      return _encrypter.encrypt(plainText, iv: _iv).base64;
    } catch (e) {
      // 如果加密失败，为了防止数据丢失或崩溃，这里需要谨慎处理
      // 实际项目中应记录日志
      return plainText; 
    }
  }

  /// 解密字符串
  static String decrypt(String encryptedText) {
    if (encryptedText.isEmpty) return '';
    try {
      return _encrypter.decrypt64(encryptedText, iv: _iv);
    } catch (e) {
      // 如果解密失败（可能是因为数据未加密，或者是旧数据），返回原文
      return encryptedText;
    }
  }
}
