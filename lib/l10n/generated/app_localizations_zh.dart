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
      '发行者和账户名相同的条目将被更新。若备份包含分类和设置，将按名称合并分类、替换导入账户的分类，并恢复设置和默认分类。同名图标包将被替换。是否继续？';

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

  @override
  String get vaultImport => '导入 Bitwarden JSON';

  @override
  String vaultImportWarning(int count, int skipped) {
    return '将导入 $count 个验证码账户，跳过 $skipped 个不含验证码或非登录条目。同名账户将更新，已有分类和其他账户元数据保留；文件夹会合并为分类。密码、笔记、附件和其他资料不会导入。确认继续？';
  }

  @override
  String get vaultImportError =>
      '无法导入。请选择未加密 JSON，并检查验证码、文件夹及账户名称；重复或不支持的验证码会导致整批拒绝。';

  @override
  String get groupedImport => '导入 Aegis 备份';

  @override
  String groupedImportWarning(int count) {
    return '导入 $count 个账户？同名账户将更新，已有分类和账户元数据保留；来源分组按名称合并为分类，缺少发行方时使用账户名称；新账户保留受支持的自定义图片，已有账户图标不变。备注和收藏状态不会导入。';
  }

  @override
  String get groupedImportError =>
      '无法导入。请检查文件、密码、分组和验证码参数；不支持的加密参数、无效或重复记录会导致整批拒绝。';

  @override
  String get backupDecrypting => '正在解密备份，请稍候。';

  @override
  String get uriBackupImport => '导入 Proton Authenticator 备份';

  @override
  String uriBackupImportWarning(int count) {
    return '导入 $count 个账户？同名账户将更新，已有分类和元数据保留。没有名称的 Steam 账户将使用“Steam”作为账户名；来源备注不会导入。';
  }

  @override
  String get uriBackupImportError => '无法导入。请检查文件、密码及账户名称；重复、无效或不受支持的记录会导致整批拒绝。';

  @override
  String get authproImport => '导入 .authpro 文件';

  @override
  String authproImportWarning(int count) {
    return '导入 $count 个账户？同名账户将更新，已有分类和元数据保留，来源分类按名称合并。空账户名使用发行方名称；新账户保留受支持的自定义图片，已有账户图标不变；来源内置图标和分类内顺序不会导入。';
  }

  @override
  String get authproImportError => '导入失败。请检查文件、密码及账户参数；无效、重复或不受支持的记录会导致整批拒绝。';

  @override
  String authproLegacyWarning(int count) {
    return '导入 $count 个账户？同名账户将更新，已有分类和元数据保留，来源分类按名称合并。空账户名使用发行方名称；新账户保留受支持的自定义图片，已有账户图标不变；来源内置图标和分类内顺序不会导入。 此旧版加密无法验证文件完整性。';
  }

  @override
  String pinLengthRequired(int count) {
    return 'PIN 必须为 $count 个字符';
  }

  @override
  String get twoFasImport => '导入 2FAS 备份';

  @override
  String twoFasImportWarning(int count) {
    return '导入 $count 个账户？同名账户将更新，已有元数据保留；分组按名称合并为分类。加密文件中的分组名称没有完整性认证。缺少账户名时使用服务名称；来源图标和显示顺序不会导入。';
  }

  @override
  String get twoFasImportError => '导入失败。请检查文件、密码和账户信息；无效、重复或不受支持的记录会导致整批拒绝。';

  @override
  String get lastPassImport => '导入 LastPass Authenticator 备份';

  @override
  String lastPassImportWarning(int count) {
    return '导入 $count 个账户？同名账户将更新，已有元数据保留；文件夹按名称合并为分类。缺少发行方或账户名时使用另一个名称；来源收藏、图标及文件夹内顺序不会导入。';
  }

  @override
  String get lastPassImportError =>
      '导入失败。仅支持版本 3 和受支持的 6–10 位账户；无效、重复或不受支持的记录会导致整批拒绝。';

  @override
  String get winAuthImport => '导入 WinAuth 备份';

  @override
  String winAuthImportWarning(int count) {
    return '导入 $count 个账户？同名账户将更新，已有元数据保留。缺少发行方或账户名时使用另一个名称；来源图标和其他元数据不会导入。旧版 ZIP 加密使用 CRC，无法验证文件的密码学完整性。';
  }

  @override
  String get winAuthImportError => '导入失败。请检查文件、密码和账户信息；不支持、无效或重复的记录会导致整批拒绝。';

  @override
  String get totpAuthImport => '导入 TOTP Authenticator 备份';

  @override
  String totpAuthImportWarning(int count) {
    return '导入 $count 个账户？同名账户将更新，已有元数据保留。缺少发行方或账户名时使用另一个名称；来源图标和其他元数据不会导入。此旧加密格式无法验证文件完整性。';
  }

  @override
  String get totpAuthImportError => '导入失败。请检查密码和账户信息；无效、重复或不受支持的记录会导致整批拒绝。';

  @override
  String get chooseCustomIcon => '选择图片';

  @override
  String get invalidCustomIcon => '请选择有效的 PNG 或 JPEG 图片，边长不得超过 4096 像素。';

  @override
  String get backupProcessing => '正在处理备份，请稍候。';

  @override
  String get importIconPack => '导入图标包';

  @override
  String get iconLoadError => '无法加载图标。';

  @override
  String iconPackImportConfirm(String name, int count) {
    return '导入包含 $count 个图标的“$name”？同名图标包将被替换。';
  }

  @override
  String get iconPackImported => '图标包已导入。';

  @override
  String get iconPackError => '无法处理图标包，请检查文件格式和图片。';

  @override
  String iconPackDeleteConfirm(String name) {
    return '删除“$name”？已分配给账户的图标会保留。';
  }

  @override
  String get freeOtpImport => '导入 FreeOTP 备份';

  @override
  String freeOtpImportWarning(int count) {
    return '导入 $count 个账户？同名账户将更新，已有元数据保留；缺少发行方时使用账户标签。来源图标和排序不会导入。';
  }

  @override
  String get freeOtpImportError => '导入失败。请检查密码和备份文件；不支持、无效或重复的记录会导致整批拒绝。';

  @override
  String importAccountCounts(int newCount, int updateCount) {
    return '新增账户：$newCount 个；更新已有账户：$updateCount 个。';
  }

  @override
  String get importPreviewExpired => '账户或设置已更改，请重新选择文件并确认更新后的数量。';

  @override
  String get migrationGuides => '迁移指南';

  @override
  String get migrationGuideIntro =>
      '以下指南说明需要在各服务中完成的操作，不会自动导入账户。在新设置验证成功前，请保留现有登录方式和恢复选项。';

  @override
  String get authyGuide =>
      'Authy 不提供令牌导出。请对每个服务分别操作：\n\n1. 使用现有验证方式登录该服务。\n2. 在该服务的安全设置中关闭双重验证，然后重新启用。\n3. 使用本应用扫描新二维码，或手动输入新的设置密钥。\n4. 使用新验证码完成服务端验证后，再移除旧条目。\n\n不同服务的恢复方式可能不同；无法登录时请联系对应服务的支持。\n\n官方帮助：https://help.twilio.com/hc/en-us/articles/19753420684059-Export-or-Import-Tokens-in-the-Authy-app-Not-Supported';

  @override
  String get steamGuide =>
      'Steam 官方迁移会将移动验证器转移到新设备的 Steam 应用，不会向本应用导出密钥。\n\n1. 在新手机安装 Steam Mobile 并登录。\n2. 在 Steam Guard 页面选择转移验证器（Move Authenticator），按提示完成确认。\n3. 妥善保存新的恢复代码。无法使用旧设备时，请按 Steam 的恢复说明操作或联系 Steam 支持。\n\n如果已拥有兼容密钥，本应用可以生成 Steam 验证码；本指南不会提取密钥。官方迁移可能导致暂时的交易限制。\n\n官方帮助：https://help.steampowered.com/en/faqs/view/29A9-9EEE-09F0-75F9';

  @override
  String get blizzardGuide =>
      'Blizzard 账户验证通过其官方移动应用管理，本指南不会提取或导入密钥。\n\n1. 保留现有验证器和恢复信息。\n2. 在新设备登录官方应用，按提示设置或恢复验证器。\n3. 无法批准登录或恢复访问时，请先通过 Blizzard 支持的账户恢复流程处理，再移除旧验证器。\n\n操作前请查看服务提供方的最新说明：https://us.support.blizzard.com/';

  @override
  String get userGuide => '使用指南';

  @override
  String get guideAddTitle => '添加账户';

  @override
  String get guideAddBody =>
      '选择添加，扫描设置二维码、选择受支持的图片或手动输入设置密钥。移除原有验证方式前，请先在服务中验证新验证码。';

  @override
  String get guideCodesTitle => '使用验证码';

  @override
  String get guideCodesBody =>
      '在服务中输入当前验证码。时间型验证码自动更新；计数器型验证码可手动前进。搜索、分类和排序可帮助管理账户。';

  @override
  String get guideBackupTitle => '保存备份';

  @override
  String get guideBackupBody =>
      '导出受密码保护的备份并妥善保管。更换设备前请测试恢复。未加密导出文件和二维码会暴露账户密钥。';

  @override
  String get guideMigrationTitle => '迁移已有账户';

  @override
  String get guideMigrationBody => '选择添加以导入受支持的文件或查看迁移指南。保存前会显示确认和冲突处理方式。';

  @override
  String get welcomeTitle => '欢迎使用';

  @override
  String get welcomeIntro => '设置验证码，保存受保护的备份，并保留账户的恢复方式。';

  @override
  String get getStarted => '开始使用';

  @override
  String get aboutApp => '关于';

  @override
  String get aboutDescription => '用于管理验证码的离线应用。';

  @override
  String get sourceCode => '源代码';

  @override
  String get openSourceLicenses => '开源许可';

  @override
  String get aboutPrivacy => '账户密钥在此设备上加密存储。导出文件和二维码可能暴露密钥。';
}
