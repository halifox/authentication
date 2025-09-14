// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Purity Auth';

  @override
  String get add => '添加';

  @override
  String get scan => '扫描';

  @override
  String get settings => '设置';

  @override
  String get scanQRCode => '扫描二维码';

  @override
  String get secret => '密钥';

  @override
  String get algorithm => '算法';

  @override
  String get digits => '位数';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get edit => '编辑';

  @override
  String get ok => '确定';

  @override
  String get codeCopied => '代码已复制';

  @override
  String get tip => '提示';

  @override
  String get warning => '警告';

  @override
  String get importFailed => '导入失败';

  @override
  String get importSuccess => '导入成功';

  @override
  String get exportSuccess => '导出成功';

  @override
  String get addSuccess => '添加成功';

  @override
  String get updateSuccess => '更新成功';

  @override
  String get saveFailed => '保存失败';

  @override
  String get platformNotSupported => '该功能当前仅支持 Android 和 iOS 平台。';

  @override
  String get cannotGetClipboardData => '无法获取剪贴板数据';

  @override
  String importedCount(int count) {
    return '$count条数据已从剪贴板导入';
  }

  @override
  String exportedCount(int count) {
    return '$count条数据已导出到剪贴板';
  }

  @override
  String get unsupportedQRCode => '不支持此类型的二维码';

  @override
  String tokenExists(String issuer, String account) {
    return '令牌$issuer:$account已存在，是否覆盖？';
  }

  @override
  String get deleteWarning =>
      '您即将删除当前的两步验证器。\n此操作将使您无法使用该验证器进行身份验证。\n请确保您已准备好其他身份验证方式以保障账户安全。';

  @override
  String get uploadQRCode => '导入二维码';

  @override
  String get enterKey => '输入密钥';

  @override
  String get importFromClipboard => '从剪贴板导入';

  @override
  String get exportToClipboard => '导出到剪贴板';

  @override
  String get enterProvidedKey => '输入密钥';

  @override
  String get type => '类型';

  @override
  String get issuer => '发行方';

  @override
  String get account => '用户名';

  @override
  String get pin => 'PIN码';

  @override
  String get period => '时间间隔(秒)';

  @override
  String get counter => '计数器';

  @override
  String get totp => 'TOTP（基于时间）';

  @override
  String get hotp => 'HOTP（基于计数器）';

  @override
  String get motp => 'mOTP（Mobile-OTP）';

  @override
  String get showCaptchaOnTap => '轻触显示代码';

  @override
  String get copyCaptchaOnTap => '轻触复制代码';

  @override
  String get sha1 => 'SHA1';

  @override
  String get sha256 => 'SHA256';

  @override
  String get sha512 => 'SHA512';

  @override
  String get selectIcon => '选择图标';

  @override
  String get invalidSecret => '无效的密钥';

  @override
  String get dismiss => '关闭';

  @override
  String get invalidScheme => '非法的scheme';

  @override
  String get invalidType => '非法的类型';

  @override
  String get issuerCannotBeEmpty => '发行方不能为空';

  @override
  String get accountCannotBeEmpty => '用户名不能为空';

  @override
  String get invalidAlgorithm => '非法的算法';

  @override
  String get invalidDigits => '非法的位数';

  @override
  String get invalidPeriod => '非法的时间间隔';

  @override
  String get invalidCounter => '非法的计数器';

  @override
  String get invalidPin => '非法的PIN码';

  @override
  String get invalidSecretKey => '非法的密钥';
}
