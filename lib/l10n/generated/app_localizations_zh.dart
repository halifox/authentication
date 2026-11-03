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
  String get backupSettingsWarning =>
      '发行者和账户名相同的条目将被更新。若备份包含分类和设置，将按名称合并分类、替换导入账户的分类，并恢复设置和默认分类。是否继续？';

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

  @override
  String get showSavedAccountQr => '显示已保存账户的二维码';

  @override
  String get qrSecretWarning =>
      '二维码明文包含已保存的账户密钥。扫描或拍摄它的人都可以生成验证码，请仅向可信设备展示。未保存的修改不会包含在内。接收应用可能忽略部分验证码设置，扫码后请核对。';

  @override
  String get qrUnsupportedAccount => '仅支持为时间型和计数器型账户展示二维码。';

  @override
  String get qrAccountUnavailable => '无法加载已保存的账户。';

  @override
  String get qrTooLarge => '无法以可扫描的尺寸显示二维码。';

  @override
  String get qrSecretSemantics => '包含账户密钥的二维码';

  @override
  String get qrUnsupportedParameters => '标准二维码要求账户名和发行方不含冒号，且验证码为 6 位或 8 位。';

  @override
  String get exportHtml => '导出 HTML 备份';

  @override
  String get htmlBackupTitle => '账户二维码备份';

  @override
  String get htmlPlainWarning =>
      '此未加密的 HTML 文件以二维码包含账户密钥。任何取得文件的人都可以生成验证码，请安全保管。文件不包含分类、图标、设置或统计，不能作为备份文件恢复。部分应用可能忽略验证码设置。';

  @override
  String get htmlExportFailed => '无法创建文件。请检查所有账户是否支持标准二维码，以及备份是否过大。';

  @override
  String get migrationTitle => '扫描迁移二维码';

  @override
  String migrationNext(int received, int total) {
    return '已接收 $received／$total 个二维码。继续扫描下一个，或取消并放弃本次导入。';
  }

  @override
  String migrationConfirm(int count) {
    return '导入 $count 个账户？发行方和账户名相同的条目将被更新，已有图标、顺序和复制次数会保留。';
  }

  @override
  String migrationImported(int count) {
    return '已导入 $count 个账户。';
  }

  @override
  String get migrationInvalid => '迁移数据无效、不受支持、重复或不完整，未导入任何账户。';

  @override
  String get languageChoice => '语言';

  @override
  String get languageSystem => '跟随系统';

  @override
  String get categories => '分类';

  @override
  String get categoryCreate => '创建分类';

  @override
  String get categoryRename => '重命名分类';

  @override
  String get categoryName => '分类名称';

  @override
  String get categoryOperationFailed => '无法保存分类，请检查名称后重试。';

  @override
  String get categoryLoadFailed => '无法加载分类。';

  @override
  String get categoryEmpty => '尚无分类。';

  @override
  String get categoryDefault => '默认';

  @override
  String get categoryActions => '分类操作';

  @override
  String get categoryClearDefault => '取消默认分类';

  @override
  String get categorySetDefault => '设为默认分类';

  @override
  String get categoryDelete => '删除分类';

  @override
  String get categoryDeleteWarning => '删除此分类？账户会保留。';

  @override
  String get assignCategories => '分配分类';

  @override
  String get assignAccounts => '分配账户';

  @override
  String get categorySelectionEmpty => '没有可选择的项目。';

  @override
  String get allCategories => '全部账户';

  @override
  String get uncategorized => '未分类';

  @override
  String get categoryFilter => '筛选分类';

  @override
  String get clearFilterToReorder => '显示全部账户并清除搜索后可调整顺序。';

  @override
  String get backupReminders => '备份提醒';

  @override
  String get backupReminderMessage => '数据已更改，请创建备份';

  @override
  String get accountView => '账户视图';

  @override
  String get viewDefault => '默认';

  @override
  String get viewCompact => '紧凑';

  @override
  String get viewTiles => '平铺';

  @override
  String get externalAccount => '外部账户链接';

  @override
  String get externalAccountInvalid => '链接无效或不受支持，未导入任何账户。';

  @override
  String get externalAccountUnavailable => '无法接收外部账户链接。';

  @override
  String get systemCodeFont => '验证码使用系统字体';

  @override
  String get legacyImport => '导入 andOTP 备份';

  @override
  String get legacyImportFormat => '选择备份格式';

  @override
  String get legacyPlain => '明文 JSON';

  @override
  String get legacyEncrypted => '加密备份（0.6.3 及以上）';

  @override
  String get legacyEncryptedOld => '旧版加密备份（0.6.2 及以下）';

  @override
  String legacyImportWarning(int count) {
    return '导入 $count 个账户？发行方和账户名相同的账户将更新，已有图标、排序、复制次数和分类会保留。来源分类按名称合并；来源图标和使用统计不会导入。';
  }

  @override
  String get legacyImportError =>
      '无法导入：请检查文件、密码和格式。仅支持发行方及账户名均非空的 TOTP、HOTP 和 Steam；重复账户、无效标签或含不支持条目的文件会整批拒绝。';

  @override
  String get revealPassword => '显示密码';

  @override
  String get hidePassword => '隐藏密码';

  @override
  String get tokenListImport => '导入 FreeOTP+ 备份';

  @override
  String get tokenListImportError =>
      '无法导入：请检查明文 JSON 文件。账户、顺序表、密钥、分类和验证码参数必须有效；重复、缺失或不支持的记录会导致整批拒绝。';
}
