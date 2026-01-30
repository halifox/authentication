import 'package:auth/db/database.dart';
import 'package:auth/domain/models/auth_validation.dart';
import 'package:auth/utils/otp.dart';
import 'package:drift/drift.dart';

class OtpService {
  /// 鲁棒地解析 URI 列表，支持多种换行符和空格清理。
  static List<String> splitUriList(String text) {
    return text
        .split(RegExp(r'[\n\r]+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  /// 解析单个 OTP URI 为数据库 Companion 对象。
  static AuthEntriesCompanion parseUri(String uriString) {
    final uri = Uri.parse(uriString);

    if (uri.scheme.toLowerCase() != 'otpauth') {
      throw AuthFailure(AuthErrorCode.invalidScheme);
    }

    final type = uri.host.toLowerCase();
    String label = '';
    if (uri.path.length > 1) {
      label = Uri.decodeFull(uri.path.substring(1));
    }

    final params = uri.queryParameters;
    final secret = params['secret'];
    if (secret == null || secret.isEmpty) {
      throw AuthFailure(AuthErrorCode.invalidSecretKey);
    }

    String issuer = params['issuer'] ?? '';
    if (issuer.isEmpty && label.contains(':')) {
      issuer = label.split(':').first.trim();
    }

    String account = params['account'] ?? '';
    if (account.isEmpty) {
      if (label.contains(':')) {
        account = label.split(':').skip(1).join(':').trim();
      } else {
        account = label.trim();
      }
    }

    return AuthEntriesCompanion.insert(
      scheme: uri.scheme,
      type: type,
      account: account,
      secret: secret,
      issuer: issuer,
      algorithm: params['algorithm'] ?? 'sha1',
      digits: int.tryParse(params['digits'] ?? '') ?? 6,
      period: int.tryParse(params['period'] ?? '') ?? 30,
      counter: int.tryParse(params['counter'] ?? '') ?? 0,
      pin: '',
      icon: 'assets/icons/passkey.svg',
      sortOrder: 0,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
  }
}
