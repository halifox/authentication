import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('ru'),
    Locale('zh'),
  ];

  /// 应用程序主标题，显示在应用栏和应用名称
  ///
  /// In zh, this message translates to:
  /// **'Authentication'**
  String get appTitle;

  /// 主界面添加新认证器的浮动操作按钮文本
  ///
  /// In zh, this message translates to:
  /// **'添加'**
  String get add;

  /// 添加页面扫描二维码的操作按钮文本
  ///
  /// In zh, this message translates to:
  /// **'扫描'**
  String get scan;

  /// 主界面底部导航栏设置选项卡标签
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settings;

  /// 扫描页面的页面标题，指引用户扫描二维码
  ///
  /// In zh, this message translates to:
  /// **'扫描二维码'**
  String get scanQRCode;

  /// 手动输入页面密钥字段的标签，用于输入认证器的密钥
  ///
  /// In zh, this message translates to:
  /// **'密钥'**
  String get secret;

  /// 认证器配置页面算法选择字段的标签
  ///
  /// In zh, this message translates to:
  /// **'算法'**
  String get algorithm;

  /// 认证器配置页面代码位数选择字段的标签
  ///
  /// In zh, this message translates to:
  /// **'位数'**
  String get digits;

  /// 对话框和表单中取消操作的按钮文本
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel;

  /// 认证器项目滑动操作中删除按钮的文本
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get delete;

  /// 认证器项目滑动操作中编辑按钮的文本
  ///
  /// In zh, this message translates to:
  /// **'编辑'**
  String get edit;

  /// 对话框和确认弹窗中确认操作的按钮文本
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get ok;

  /// 复制验证码后显示的成功提示消息
  ///
  /// In zh, this message translates to:
  /// **'代码已复制'**
  String get codeCopied;

  /// 成功操作结果弹窗的标题
  ///
  /// In zh, this message translates to:
  /// **'提示'**
  String get tip;

  /// 警告类型结果弹窗的标题
  ///
  /// In zh, this message translates to:
  /// **'警告'**
  String get warning;

  /// 数据导入操作失败时的结果弹窗标题
  ///
  /// In zh, this message translates to:
  /// **'导入失败'**
  String get importFailed;

  /// 数据导入操作成功时的结果弹窗标题
  ///
  /// In zh, this message translates to:
  /// **'导入成功'**
  String get importSuccess;

  /// 数据导出操作成功时的结果弹窗标题
  ///
  /// In zh, this message translates to:
  /// **'导出成功'**
  String get exportSuccess;

  /// 成功添加新认证器后的成功提示消息
  ///
  /// In zh, this message translates to:
  /// **'添加成功'**
  String get addSuccess;

  /// 成功更新认证器配置后的成功提示消息
  ///
  /// In zh, this message translates to:
  /// **'更新成功'**
  String get updateSuccess;

  /// 保存认证器配置失败时的错误弹窗标题
  ///
  /// In zh, this message translates to:
  /// **'保存失败'**
  String get saveFailed;

  /// 当前平台不支持某功能时的错误提示消息
  ///
  /// In zh, this message translates to:
  /// **'该功能当前仅支持 Android 和 iOS 平台。'**
  String get platformNotSupported;

  /// 扫描到不支持的二维码格式时的错误提示消息
  ///
  /// In zh, this message translates to:
  /// **'不支持此类型的二维码'**
  String get unsupportedQRCode;

  /// 添加已存在的认证器时询问是否覆盖的确认对话框消息
  ///
  /// In zh, this message translates to:
  /// **'令牌{issuer}:{account}已存在，是否覆盖？'**
  String tokenExists(String issuer, String account);

  /// 删除认证器前显示的安全警告消息，提醒用户注意风险
  ///
  /// In zh, this message translates to:
  /// **'您即将删除当前的两步验证器。\n此操作将使您无法使用该验证器进行身份验证。\n请确保您已准备好其他身份验证方式以保障账户安全。'**
  String get deleteWarning;

  /// 添加页面通过上传图片导入二维码的选项按钮文本
  ///
  /// In zh, this message translates to:
  /// **'导入二维码'**
  String get uploadQRCode;

  /// 添加页面手动输入密钥的选项按钮文本
  ///
  /// In zh, this message translates to:
  /// **'输入密钥'**
  String get enterKey;

  /// 手动配置认证器页面的页面标题
  ///
  /// In zh, this message translates to:
  /// **'输入密钥'**
  String get enterProvidedKey;

  /// 认证器配置页面选择认证器类型的字段标签
  ///
  /// In zh, this message translates to:
  /// **'类型'**
  String get type;

  /// 认证器配置页面发行方名称的输入字段标签
  ///
  /// In zh, this message translates to:
  /// **'发行方'**
  String get issuer;

  /// 认证器配置页面账户名称的输入字段标签
  ///
  /// In zh, this message translates to:
  /// **'用户名'**
  String get account;

  /// mOTP类型认证器配置页面PIN码的输入字段标签
  ///
  /// In zh, this message translates to:
  /// **'PIN码'**
  String get pin;

  /// TOTP类型认证器配置页面时间间隔的输入字段标签
  ///
  /// In zh, this message translates to:
  /// **'时间间隔(秒)'**
  String get period;

  /// HOTP类型认证器配置页面计数器的输入字段标签
  ///
  /// In zh, this message translates to:
  /// **'计数器'**
  String get counter;

  /// 认证器类型选择器中TOTP选项的显示文本
  ///
  /// In zh, this message translates to:
  /// **'TOTP（基于时间）'**
  String get totp;

  /// 认证器类型选择器中HOTP选项的显示文本
  ///
  /// In zh, this message translates to:
  /// **'HOTP（基于计数器）'**
  String get hotp;

  /// 认证器类型选择器中mOTP选项的显示文本
  ///
  /// In zh, this message translates to:
  /// **'mOTP（Mobile-OTP）'**
  String get motp;

  /// 设置页面控制点击验证码时显示/隐藏的选项文本
  ///
  /// In zh, this message translates to:
  /// **'轻触显示代码'**
  String get showCaptchaOnTap;

  /// 设置页面控制点击验证码时自动复制的选项文本
  ///
  /// In zh, this message translates to:
  /// **'轻触复制代码'**
  String get copyCaptchaOnTap;

  /// 算法选择器中SHA1加密算法选项的显示文本
  ///
  /// In zh, this message translates to:
  /// **'SHA1'**
  String get sha1;

  /// 算法选择器中SHA256加密算法选项的显示文本
  ///
  /// In zh, this message translates to:
  /// **'SHA256'**
  String get sha256;

  /// 算法选择器中SHA512加密算法选项的显示文本
  ///
  /// In zh, this message translates to:
  /// **'SHA512'**
  String get sha512;

  /// 图标选择器页面的页面标题
  ///
  /// In zh, this message translates to:
  /// **'选择图标'**
  String get selectIcon;

  /// 密钥格式不正确时的表单验证错误消息
  ///
  /// In zh, this message translates to:
  /// **'无效的密钥'**
  String get invalidSecret;

  /// 模态对话框和弹窗中关闭按钮的文本
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get dismiss;

  /// 二维码URL格式不正确时的验证错误消息
  ///
  /// In zh, this message translates to:
  /// **'非法的scheme'**
  String get invalidScheme;

  /// 认证器类型参数无效时的验证错误消息
  ///
  /// In zh, this message translates to:
  /// **'非法的类型'**
  String get invalidType;

  /// 发行方字段为空时的表单验证错误消息
  ///
  /// In zh, this message translates to:
  /// **'发行方不能为空'**
  String get issuerCannotBeEmpty;

  /// 用户名字段为空时的表单验证错误消息
  ///
  /// In zh, this message translates to:
  /// **'用户名不能为空'**
  String get accountCannotBeEmpty;

  /// 加密算法参数无效时的验证错误消息
  ///
  /// In zh, this message translates to:
  /// **'非法的算法'**
  String get invalidAlgorithm;

  /// 验证码位数参数无效时的验证错误消息
  ///
  /// In zh, this message translates to:
  /// **'非法的位数'**
  String get invalidDigits;

  /// TOTP时间间隔参数无效时的验证错误消息
  ///
  /// In zh, this message translates to:
  /// **'非法的时间间隔'**
  String get invalidPeriod;

  /// HOTP计数器参数无效时的验证错误消息
  ///
  /// In zh, this message translates to:
  /// **'非法的计数器'**
  String get invalidCounter;

  /// mOTP的PIN码参数无效时的验证错误消息
  ///
  /// In zh, this message translates to:
  /// **'非法的PIN码'**
  String get invalidPin;

  /// 密钥参数无效或格式错误时的验证错误消息
  ///
  /// In zh, this message translates to:
  /// **'非法的密钥'**
  String get invalidSecretKey;

  /// 主页列表为空时显示的提示文本
  ///
  /// In zh, this message translates to:
  /// **'暂无数据'**
  String get noData;

  /// 搜索框的提示文本或标签
  ///
  /// In zh, this message translates to:
  /// **'搜索'**
  String get search;

  /// 导出失败标题
  ///
  /// In zh, this message translates to:
  /// **'导出失败'**
  String get exportFailed;

  /// 没有数据可导出时的提示
  ///
  /// In zh, this message translates to:
  /// **'没有可导出的数据'**
  String get noDataToExport;

  /// No description provided for @importFile.
  ///
  /// In zh, this message translates to:
  /// **'从文件导入'**
  String get importFile;

  /// No description provided for @exportFile.
  ///
  /// In zh, this message translates to:
  /// **'导出到文件'**
  String get exportFile;

  /// No description provided for @backupPasswordTitle.
  ///
  /// In zh, this message translates to:
  /// **'备份密码'**
  String get backupPasswordTitle;

  /// No description provided for @backupPasswordHint.
  ///
  /// In zh, this message translates to:
  /// **'留空则导出未加密文件'**
  String get backupPasswordHint;

  /// No description provided for @backupPasswordRequired.
  ///
  /// In zh, this message translates to:
  /// **'请输入备份密码'**
  String get backupPasswordRequired;

  /// No description provided for @backupPasswordConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确认密码'**
  String get backupPasswordConfirm;

  /// No description provided for @backupPasswordMismatch.
  ///
  /// In zh, this message translates to:
  /// **'两次输入的密码不一致'**
  String get backupPasswordMismatch;

  /// No description provided for @backupPlainWarning.
  ///
  /// In zh, this message translates to:
  /// **'不设置密码时，文件会明文包含所有密钥。请安全保管。'**
  String get backupPlainWarning;

  /// No description provided for @backupReplaceWarning.
  ///
  /// In zh, this message translates to:
  /// **'导入将覆盖发行者和账户名相同的条目。是否继续？'**
  String get backupReplaceWarning;

  /// No description provided for @backupFileTooLarge.
  ///
  /// In zh, this message translates to:
  /// **'备份文件过大。'**
  String get backupFileTooLarge;

  /// No description provided for @backupFileError.
  ///
  /// In zh, this message translates to:
  /// **'无法导入文件，请检查密码和文件内容。'**
  String get backupFileError;

  /// No description provided for @backupSaved.
  ///
  /// In zh, this message translates to:
  /// **'备份文件已保存。'**
  String get backupSaved;

  /// No description provided for @backupImported.
  ///
  /// In zh, this message translates to:
  /// **'备份文件已导入。'**
  String get backupImported;

  /// No description provided for @backupDownloadStarted.
  ///
  /// In zh, this message translates to:
  /// **'已请求浏览器下载备份文件。请确认下载完成。'**
  String get backupDownloadStarted;

  /// No description provided for @importUriList.
  ///
  /// In zh, this message translates to:
  /// **'导入 URI 列表'**
  String get importUriList;

  /// No description provided for @exportUriList.
  ///
  /// In zh, this message translates to:
  /// **'导出 URI 列表'**
  String get exportUriList;

  /// No description provided for @uriPlainWarning.
  ///
  /// In zh, this message translates to:
  /// **'此文件明文包含账户密钥。任何取得文件的人都可以生成验证码，请安全保管。'**
  String get uriPlainWarning;

  /// No description provided for @clearSearch.
  ///
  /// In zh, this message translates to:
  /// **'清除搜索'**
  String get clearSearch;

  /// No description provided for @noSearchResults.
  ///
  /// In zh, this message translates to:
  /// **'没有匹配的账户'**
  String get noSearchResults;

  /// No description provided for @settingsLoadError.
  ///
  /// In zh, this message translates to:
  /// **'无法加载设置。'**
  String get settingsLoadError;

  /// No description provided for @backupSettingsWarning.
  ///
  /// In zh, this message translates to:
  /// **'发行者和账户名相同的条目将被更新。备份中包含的设置也会被恢复。是否继续？'**
  String get backupSettingsWarning;

  /// No description provided for @showAccountName.
  ///
  /// In zh, this message translates to:
  /// **'显示账户名'**
  String get showAccountName;

  /// No description provided for @hideCodeAfter.
  ///
  /// In zh, this message translates to:
  /// **'显示后自动隐藏验证码'**
  String get hideCodeAfter;

  /// No description provided for @never.
  ///
  /// In zh, this message translates to:
  /// **'从不'**
  String get never;

  /// No description provided for @seconds.
  ///
  /// In zh, this message translates to:
  /// **'{count} 秒'**
  String seconds(int count);

  /// No description provided for @advanceHotpOnCopy.
  ///
  /// In zh, this message translates to:
  /// **'复制后前进 HOTP 计数器'**
  String get advanceHotpOnCopy;

  /// No description provided for @resetCopyCount.
  ///
  /// In zh, this message translates to:
  /// **'重置复制次数'**
  String get resetCopyCount;

  /// No description provided for @resetCopyCountWarning.
  ///
  /// In zh, this message translates to:
  /// **'重置此账户的复制次数？'**
  String get resetCopyCountWarning;

  /// No description provided for @copyCount.
  ///
  /// In zh, this message translates to:
  /// **'复制次数：{count}'**
  String copyCount(int count);

  /// No description provided for @copyFailed.
  ///
  /// In zh, this message translates to:
  /// **'无法复制验证码。'**
  String get copyFailed;

  /// No description provided for @copyRecordFailed.
  ///
  /// In zh, this message translates to:
  /// **'验证码已复制，但无法更新复制次数或 HOTP 计数器。再次复制前请检查账户。'**
  String get copyRecordFailed;

  /// No description provided for @sortAccounts.
  ///
  /// In zh, this message translates to:
  /// **'账户排序'**
  String get sortAccounts;

  /// No description provided for @sortCustom.
  ///
  /// In zh, this message translates to:
  /// **'自定义顺序'**
  String get sortCustom;

  /// No description provided for @sortNameAscending.
  ///
  /// In zh, this message translates to:
  /// **'名称升序'**
  String get sortNameAscending;

  /// No description provided for @sortNameDescending.
  ///
  /// In zh, this message translates to:
  /// **'名称降序'**
  String get sortNameDescending;

  /// No description provided for @sortCopiesAscending.
  ///
  /// In zh, this message translates to:
  /// **'复制次数升序'**
  String get sortCopiesAscending;

  /// No description provided for @sortCopiesDescending.
  ///
  /// In zh, this message translates to:
  /// **'复制次数降序'**
  String get sortCopiesDescending;

  /// No description provided for @lockSorting.
  ///
  /// In zh, this message translates to:
  /// **'锁定自定义顺序'**
  String get lockSorting;

  /// No description provided for @unlockSorting.
  ///
  /// In zh, this message translates to:
  /// **'解锁自定义顺序'**
  String get unlockSorting;

  /// No description provided for @clearSearchToReorder.
  ///
  /// In zh, this message translates to:
  /// **'清除搜索后可调整账户顺序。'**
  String get clearSearchToReorder;

  /// No description provided for @reorderFailed.
  ///
  /// In zh, this message translates to:
  /// **'无法调整账户顺序，请重试。'**
  String get reorderFailed;

  /// No description provided for @dragToReorder.
  ///
  /// In zh, this message translates to:
  /// **'拖动以调整顺序'**
  String get dragToReorder;

  /// No description provided for @codeGrouping.
  ///
  /// In zh, this message translates to:
  /// **'验证码分组'**
  String get codeGrouping;

  /// No description provided for @groupNone.
  ///
  /// In zh, this message translates to:
  /// **'不分组'**
  String get groupNone;

  /// No description provided for @groupEvery.
  ///
  /// In zh, this message translates to:
  /// **'每 {count} 位'**
  String groupEvery(int count);

  /// No description provided for @groupHalves.
  ///
  /// In zh, this message translates to:
  /// **'分成两组'**
  String get groupHalves;

  /// No description provided for @groupThirds.
  ///
  /// In zh, this message translates to:
  /// **'分成三组'**
  String get groupThirds;

  /// No description provided for @codeHidden.
  ///
  /// In zh, this message translates to:
  /// **'验证码已隐藏'**
  String get codeHidden;

  /// No description provided for @dynamicColor.
  ///
  /// In zh, this message translates to:
  /// **'使用系统动态配色'**
  String get dynamicColor;

  /// No description provided for @themeChoice.
  ///
  /// In zh, this message translates to:
  /// **'主题'**
  String get themeChoice;

  /// No description provided for @themeSystem.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In zh, this message translates to:
  /// **'浅色'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In zh, this message translates to:
  /// **'深色'**
  String get themeDark;

  /// No description provided for @themeBlack.
  ///
  /// In zh, this message translates to:
  /// **'纯黑'**
  String get themeBlack;

  /// No description provided for @themeSystemBlack.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统（深色时纯黑）'**
  String get themeSystemBlack;

  /// No description provided for @accentChoice.
  ///
  /// In zh, this message translates to:
  /// **'强调色'**
  String get accentChoice;

  /// No description provided for @accentDefault.
  ///
  /// In zh, this message translates to:
  /// **'默认'**
  String get accentDefault;

  /// No description provided for @accentRed.
  ///
  /// In zh, this message translates to:
  /// **'红色'**
  String get accentRed;

  /// No description provided for @accentOrange.
  ///
  /// In zh, this message translates to:
  /// **'橙色'**
  String get accentOrange;

  /// No description provided for @accentGreen.
  ///
  /// In zh, this message translates to:
  /// **'绿色'**
  String get accentGreen;

  /// No description provided for @accentTeal.
  ///
  /// In zh, this message translates to:
  /// **'青色'**
  String get accentTeal;

  /// No description provided for @accentBlue.
  ///
  /// In zh, this message translates to:
  /// **'蓝色'**
  String get accentBlue;

  /// No description provided for @accentIndigo.
  ///
  /// In zh, this message translates to:
  /// **'靛蓝'**
  String get accentIndigo;

  /// No description provided for @accentPink.
  ///
  /// In zh, this message translates to:
  /// **'粉色'**
  String get accentPink;

  /// No description provided for @accentPriority.
  ///
  /// In zh, this message translates to:
  /// **'系统动态配色可用且启用时优先使用动态配色。'**
  String get accentPriority;

  /// No description provided for @showSavedAccountQr.
  ///
  /// In zh, this message translates to:
  /// **'显示已保存账户的二维码'**
  String get showSavedAccountQr;

  /// No description provided for @qrSecretWarning.
  ///
  /// In zh, this message translates to:
  /// **'二维码明文包含已保存的账户密钥。扫描或拍摄它的人都可以生成验证码，请仅向可信设备展示。未保存的修改不会包含在内。接收应用可能忽略部分验证码设置，扫码后请核对。'**
  String get qrSecretWarning;

  /// No description provided for @qrUnsupportedAccount.
  ///
  /// In zh, this message translates to:
  /// **'仅支持为时间型和计数器型账户展示二维码。'**
  String get qrUnsupportedAccount;

  /// No description provided for @qrAccountUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'无法加载已保存的账户。'**
  String get qrAccountUnavailable;

  /// No description provided for @qrTooLarge.
  ///
  /// In zh, this message translates to:
  /// **'无法以可扫描的尺寸显示二维码。'**
  String get qrTooLarge;

  /// No description provided for @qrSecretSemantics.
  ///
  /// In zh, this message translates to:
  /// **'包含账户密钥的二维码'**
  String get qrSecretSemantics;

  /// No description provided for @qrUnsupportedParameters.
  ///
  /// In zh, this message translates to:
  /// **'标准二维码要求账户名和发行方不含冒号，且验证码为 6 位或 8 位。'**
  String get qrUnsupportedParameters;

  /// No description provided for @exportHtml.
  ///
  /// In zh, this message translates to:
  /// **'导出 HTML 备份'**
  String get exportHtml;

  /// No description provided for @htmlBackupTitle.
  ///
  /// In zh, this message translates to:
  /// **'账户二维码备份'**
  String get htmlBackupTitle;

  /// No description provided for @htmlPlainWarning.
  ///
  /// In zh, this message translates to:
  /// **'此未加密的 HTML 文件以二维码包含账户密钥。任何取得文件的人都可以生成验证码，请安全保管。文件不包含分类、图标、设置或统计，不能作为备份文件恢复。部分应用可能忽略验证码设置。'**
  String get htmlPlainWarning;

  /// No description provided for @htmlExportFailed.
  ///
  /// In zh, this message translates to:
  /// **'无法创建文件。请检查所有账户是否支持标准二维码，以及备份是否过大。'**
  String get htmlExportFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'it',
    'ja',
    'ko',
    'pt',
    'ru',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
