// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Authentication';

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

  @override
  String get noData => '暂无数据';

  @override
  String get search => '搜索';

  @override
  String get exportFailed => '导出失败';

  @override
  String get noDataToExport => '没有可导出的数据';

  @override
  String get importFile => '从文件导入';

  @override
  String get exportFile => '导出到文件';

  @override
  String get backupPasswordTitle => '备份密码';

  @override
  String get backupPasswordHint => '留空则导出未加密文件';

  @override
  String get backupPasswordRequired => '请输入备份密码';

  @override
  String get backupPasswordConfirm => '确认密码';

  @override
  String get backupPasswordMismatch => '两次输入的密码不一致';

  @override
  String get backupPlainWarning => '不设置密码时，文件会明文包含所有密钥。请安全保管。';

  @override
  String get backupReplaceWarning => '导入将覆盖发行者和账户名相同的条目。是否继续？';

  @override
  String get backupFileTooLarge => '备份文件过大。';

  @override
  String get backupFileError => '无法导入文件，请检查密码和文件内容。';

  @override
  String get backupSaved => '备份文件已保存。';

  @override
  String get backupImported => '备份文件已导入。';

  @override
  String get backupDownloadStarted => '已请求浏览器下载备份文件。请确认下载完成。';

  @override
  String get importUriList => '导入 URI 列表';

  @override
  String get exportUriList => '导出 URI 列表';

  @override
  String get uriPlainWarning => '此文件明文包含账户密钥。任何取得文件的人都可以生成验证码，请安全保管。';

  @override
  String get clearSearch => '清除搜索';

  @override
  String get noSearchResults => '没有匹配的账户';

  @override
  String get settingsLoadError => '无法加载设置。';

  @override
  String get backupSettingsWarning => '发行者和账户名相同的条目将被更新。备份中包含的设置也会被恢复。是否继续？';

  @override
  String get showAccountName => '显示账户名';

  @override
  String get hideCodeAfter => '显示后自动隐藏验证码';

  @override
  String get never => '从不';

  @override
  String seconds(int count) {
    return '$count 秒';
  }

  @override
  String get advanceHotpOnCopy => '复制后前进 HOTP 计数器';

  @override
  String get resetCopyCount => '重置复制次数';

  @override
  String get resetCopyCountWarning => '重置此账户的复制次数？';

  @override
  String copyCount(int count) {
    return '复制次数：$count';
  }

  @override
  String get copyFailed => '无法复制验证码。';

  @override
  String get copyRecordFailed => '验证码已复制，但无法更新复制次数或 HOTP 计数器。再次复制前请检查账户。';

  @override
  String get sortAccounts => '账户排序';

  @override
  String get sortCustom => '自定义顺序';

  @override
  String get sortNameAscending => '名称升序';

  @override
  String get sortNameDescending => '名称降序';

  @override
  String get sortCopiesAscending => '复制次数升序';

  @override
  String get sortCopiesDescending => '复制次数降序';

  @override
  String get lockSorting => '锁定自定义顺序';

  @override
  String get unlockSorting => '解锁自定义顺序';

  @override
  String get clearSearchToReorder => '清除搜索后可调整账户顺序。';

  @override
  String get reorderFailed => '无法调整账户顺序，请重试。';

  @override
  String get dragToReorder => '拖动以调整顺序';

  @override
  String get codeGrouping => '验证码分组';

  @override
  String get groupNone => '不分组';

  @override
  String groupEvery(int count) {
    return '每 $count 位';
  }

  @override
  String get groupHalves => '分成两组';

  @override
  String get groupThirds => '分成三组';

  @override
  String get codeHidden => '验证码已隐藏';

  @override
  String get dynamicColor => '使用系统动态配色';

  @override
  String get themeChoice => '主题';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get themeBlack => '纯黑';

  @override
  String get themeSystemBlack => '跟随系统（深色时纯黑）';

  @override
  String get accentChoice => '强调色';

  @override
  String get accentDefault => '默认';

  @override
  String get accentRed => '红色';

  @override
  String get accentOrange => '橙色';

  @override
  String get accentGreen => '绿色';

  @override
  String get accentTeal => '青色';

  @override
  String get accentBlue => '蓝色';

  @override
  String get accentIndigo => '靛蓝';

  @override
  String get accentPink => '粉色';

  @override
  String get accentPriority => '系统动态配色可用且启用时优先使用动态配色。';
}
