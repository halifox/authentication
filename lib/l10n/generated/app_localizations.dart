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
  /// **'Purity Auth'**
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

  /// 读取剪贴板内容失败时的错误提示消息
  ///
  /// In zh, this message translates to:
  /// **'无法获取剪贴板数据'**
  String get cannotGetClipboardData;

  /// 从剪贴板成功导入数据后显示的计数提示消息
  ///
  /// In zh, this message translates to:
  /// **'{count}条数据已从剪贴板导入'**
  String importedCount(int count);

  /// 成功导出数据到剪贴板后显示的计数提示消息
  ///
  /// In zh, this message translates to:
  /// **'{count}条数据已导出到剪贴板'**
  String exportedCount(int count);

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

  /// 设置页面从剪贴板导入数据的功能选项文本
  ///
  /// In zh, this message translates to:
  /// **'从剪贴板导入'**
  String get importFromClipboard;

  /// 设置页面导出数据到剪贴板的功能选项文本
  ///
  /// In zh, this message translates to:
  /// **'导出到剪贴板'**
  String get exportToClipboard;

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

  /// 批量导入前的警告提示
  ///
  /// In zh, this message translates to:
  /// **'您即将从剪贴板导入数据。如果数据库中已存在相同的账户，它们将被覆盖。是否继续？'**
  String get importWarning;

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

  /// No description provided for @exportWarning.
  ///
  /// In zh, this message translates to:
  /// **'您即将将所有认证器导出到剪贴板。导出的内容为明文格式，请确保您的环境安全并及时处理剪贴板内容。是否继续？'**
  String get exportWarning;
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
