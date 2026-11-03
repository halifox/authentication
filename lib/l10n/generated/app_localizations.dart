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
  /// In en, this message translates to:
  /// **'Authentication'**
  String get appTitle;

  /// 主界面添加新认证器的浮动操作按钮文本
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// 添加页面扫描二维码的操作按钮文本
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan;

  /// 主界面底部导航栏设置选项卡标签
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// 扫描页面的页面标题，指引用户扫描二维码
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get scanQRCode;

  /// 手动输入页面密钥字段的标签，用于输入认证器的密钥
  ///
  /// In en, this message translates to:
  /// **'Secret'**
  String get secret;

  /// 认证器配置页面算法选择字段的标签
  ///
  /// In en, this message translates to:
  /// **'Algorithm'**
  String get algorithm;

  /// 认证器配置页面代码位数选择字段的标签
  ///
  /// In en, this message translates to:
  /// **'Digits'**
  String get digits;

  /// 对话框和表单中取消操作的按钮文本
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// 认证器项目滑动操作中删除按钮的文本
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// 认证器项目滑动操作中编辑按钮的文本
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// 对话框和确认弹窗中确认操作的按钮文本
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// 复制验证码后显示的成功提示消息
  ///
  /// In en, this message translates to:
  /// **'Code Copied'**
  String get codeCopied;

  /// 成功操作结果弹窗的标题
  ///
  /// In en, this message translates to:
  /// **'Tip'**
  String get tip;

  /// 警告类型结果弹窗的标题
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// 数据导入操作失败时的结果弹窗标题
  ///
  /// In en, this message translates to:
  /// **'Import Failed'**
  String get importFailed;

  /// 数据导入操作成功时的结果弹窗标题
  ///
  /// In en, this message translates to:
  /// **'Import Successful'**
  String get importSuccess;

  /// 数据导出操作成功时的结果弹窗标题
  ///
  /// In en, this message translates to:
  /// **'Export Successful'**
  String get exportSuccess;

  /// 成功添加新认证器后的成功提示消息
  ///
  /// In en, this message translates to:
  /// **'Added Successfully'**
  String get addSuccess;

  /// 成功更新认证器配置后的成功提示消息
  ///
  /// In en, this message translates to:
  /// **'Updated Successfully'**
  String get updateSuccess;

  /// 保存认证器配置失败时的错误弹窗标题
  ///
  /// In en, this message translates to:
  /// **'Save Failed'**
  String get saveFailed;

  /// 当前平台不支持某功能时的错误提示消息
  ///
  /// In en, this message translates to:
  /// **'This feature is currently only supported on Android and iOS platforms.'**
  String get platformNotSupported;

  /// 扫描到不支持的二维码格式时的错误提示消息
  ///
  /// In en, this message translates to:
  /// **'This type of QR code is not supported.'**
  String get unsupportedQRCode;

  /// 添加已存在的认证器时询问是否覆盖的确认对话框消息
  ///
  /// In en, this message translates to:
  /// **'Token {issuer}:{account} already exists. Do you want to overwrite it?'**
  String tokenExists(String issuer, String account);

  /// 删除认证器前显示的安全警告消息，提醒用户注意风险
  ///
  /// In en, this message translates to:
  /// **'You are about to delete the current two-factor authenticator.\nThis action will prevent you from using this authenticator for authentication.\nPlease make sure you have other authentication methods ready to ensure account security.'**
  String get deleteWarning;

  /// 添加页面通过上传图片导入二维码的选项按钮文本
  ///
  /// In en, this message translates to:
  /// **'Import QR Code'**
  String get uploadQRCode;

  /// 添加页面手动输入密钥的选项按钮文本
  ///
  /// In en, this message translates to:
  /// **'Enter Secret Code'**
  String get enterKey;

  /// 手动配置认证器页面的页面标题
  ///
  /// In en, this message translates to:
  /// **'Enter Secret Key'**
  String get enterProvidedKey;

  /// 认证器配置页面选择认证器类型的字段标签
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// 认证器配置页面发行方名称的输入字段标签
  ///
  /// In en, this message translates to:
  /// **'Issuer'**
  String get issuer;

  /// 认证器配置页面账户名称的输入字段标签
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// mOTP类型认证器配置页面PIN码的输入字段标签
  ///
  /// In en, this message translates to:
  /// **'PIN Code'**
  String get pin;

  /// TOTP类型认证器配置页面时间间隔的输入字段标签
  ///
  /// In en, this message translates to:
  /// **'Period (seconds)'**
  String get period;

  /// HOTP类型认证器配置页面计数器的输入字段标签
  ///
  /// In en, this message translates to:
  /// **'Counter'**
  String get counter;

  /// 认证器类型选择器中TOTP选项的显示文本
  ///
  /// In en, this message translates to:
  /// **'TOTP (Time-based)'**
  String get totp;

  /// 认证器类型选择器中HOTP选项的显示文本
  ///
  /// In en, this message translates to:
  /// **'HOTP (Counter-based)'**
  String get hotp;

  /// 认证器类型选择器中mOTP选项的显示文本
  ///
  /// In en, this message translates to:
  /// **'mOTP (Mobile-OTP)'**
  String get motp;

  /// 设置页面控制点击验证码时显示/隐藏的选项文本
  ///
  /// In en, this message translates to:
  /// **'Tap to Reveal Code'**
  String get showCaptchaOnTap;

  /// 设置页面控制点击验证码时自动复制的选项文本
  ///
  /// In en, this message translates to:
  /// **'Tap to Copy Code'**
  String get copyCaptchaOnTap;

  /// 算法选择器中SHA1加密算法选项的显示文本
  ///
  /// In en, this message translates to:
  /// **'SHA1'**
  String get sha1;

  /// 算法选择器中SHA256加密算法选项的显示文本
  ///
  /// In en, this message translates to:
  /// **'SHA256'**
  String get sha256;

  /// 算法选择器中SHA512加密算法选项的显示文本
  ///
  /// In en, this message translates to:
  /// **'SHA512'**
  String get sha512;

  /// 图标选择器页面的页面标题
  ///
  /// In en, this message translates to:
  /// **'Select Icon'**
  String get selectIcon;

  /// 密钥格式不正确时的表单验证错误消息
  ///
  /// In en, this message translates to:
  /// **'Invalid secret'**
  String get invalidSecret;

  /// 模态对话框和弹窗中关闭按钮的文本
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// 二维码URL格式不正确时的验证错误消息
  ///
  /// In en, this message translates to:
  /// **'Invalid scheme'**
  String get invalidScheme;

  /// 认证器类型参数无效时的验证错误消息
  ///
  /// In en, this message translates to:
  /// **'Invalid type'**
  String get invalidType;

  /// 发行方字段为空时的表单验证错误消息
  ///
  /// In en, this message translates to:
  /// **'Issuer cannot be empty'**
  String get issuerCannotBeEmpty;

  /// 用户名字段为空时的表单验证错误消息
  ///
  /// In en, this message translates to:
  /// **'Account cannot be empty'**
  String get accountCannotBeEmpty;

  /// 加密算法参数无效时的验证错误消息
  ///
  /// In en, this message translates to:
  /// **'Invalid algorithm'**
  String get invalidAlgorithm;

  /// 验证码位数参数无效时的验证错误消息
  ///
  /// In en, this message translates to:
  /// **'Invalid digits'**
  String get invalidDigits;

  /// TOTP时间间隔参数无效时的验证错误消息
  ///
  /// In en, this message translates to:
  /// **'Invalid period'**
  String get invalidPeriod;

  /// HOTP计数器参数无效时的验证错误消息
  ///
  /// In en, this message translates to:
  /// **'Invalid counter'**
  String get invalidCounter;

  /// mOTP的PIN码参数无效时的验证错误消息
  ///
  /// In en, this message translates to:
  /// **'Invalid PIN code'**
  String get invalidPin;

  /// 密钥参数无效或格式错误时的验证错误消息
  ///
  /// In en, this message translates to:
  /// **'Invalid secret key'**
  String get invalidSecretKey;

  /// 主页列表为空时显示的提示文本
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// 搜索框的提示文本或标签
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// 导出失败标题
  ///
  /// In en, this message translates to:
  /// **'Export Failed'**
  String get exportFailed;

  /// 没有数据可导出时的提示
  ///
  /// In en, this message translates to:
  /// **'No data available to export'**
  String get noDataToExport;

  /// No description provided for @importFile.
  ///
  /// In en, this message translates to:
  /// **'Import file'**
  String get importFile;

  /// No description provided for @exportFile.
  ///
  /// In en, this message translates to:
  /// **'Export file'**
  String get exportFile;

  /// No description provided for @backupPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup password'**
  String get backupPasswordTitle;

  /// No description provided for @backupPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Leave empty for an unencrypted file'**
  String get backupPasswordHint;

  /// No description provided for @backupPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter backup password'**
  String get backupPasswordRequired;

  /// No description provided for @backupPasswordConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get backupPasswordConfirm;

  /// No description provided for @backupPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get backupPasswordMismatch;

  /// No description provided for @backupPlainWarning.
  ///
  /// In en, this message translates to:
  /// **'Without a password, this file contains all your secret keys in plain text. Keep it in a safe place.'**
  String get backupPlainWarning;

  /// No description provided for @backupReplaceWarning.
  ///
  /// In en, this message translates to:
  /// **'Importing replaces accounts with the same issuer and account name. Continue?'**
  String get backupReplaceWarning;

  /// No description provided for @backupFileTooLarge.
  ///
  /// In en, this message translates to:
  /// **'The backup file is too large.'**
  String get backupFileTooLarge;

  /// No description provided for @backupFileError.
  ///
  /// In en, this message translates to:
  /// **'The file could not be imported. Check the password and file contents.'**
  String get backupFileError;

  /// No description provided for @backupSaved.
  ///
  /// In en, this message translates to:
  /// **'Backup file saved.'**
  String get backupSaved;

  /// No description provided for @backupImported.
  ///
  /// In en, this message translates to:
  /// **'Backup file imported.'**
  String get backupImported;

  /// No description provided for @backupDownloadStarted.
  ///
  /// In en, this message translates to:
  /// **'The browser was asked to download the backup. Check that the download completed.'**
  String get backupDownloadStarted;

  /// No description provided for @importUriList.
  ///
  /// In en, this message translates to:
  /// **'Import URI list'**
  String get importUriList;

  /// No description provided for @exportUriList.
  ///
  /// In en, this message translates to:
  /// **'Export URI list'**
  String get exportUriList;

  /// No description provided for @uriPlainWarning.
  ///
  /// In en, this message translates to:
  /// **'This file contains account secrets in plain text. Anyone with the file can generate your codes. Store it securely.'**
  String get uriPlainWarning;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No matching accounts'**
  String get noSearchResults;

  /// No description provided for @settingsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Settings could not be loaded.'**
  String get settingsLoadError;

  /// No description provided for @backupSettingsWarning.
  ///
  /// In en, this message translates to:
  /// **'Accounts with the same issuer and account name will be updated. If included, categories will be merged by name, memberships for imported accounts replaced, settings and default category restored, and same-name icon packs replaced. Continue?'**
  String get backupSettingsWarning;

  /// No description provided for @showAccountName.
  ///
  /// In en, this message translates to:
  /// **'Show account name'**
  String get showAccountName;

  /// No description provided for @hideCodeAfter.
  ///
  /// In en, this message translates to:
  /// **'Automatically hide revealed codes'**
  String get hideCodeAfter;

  /// No description provided for @never.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get never;

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'{count} seconds'**
  String seconds(int count);

  /// No description provided for @advanceHotpOnCopy.
  ///
  /// In en, this message translates to:
  /// **'Advance HOTP after copying'**
  String get advanceHotpOnCopy;

  /// No description provided for @resetCopyCount.
  ///
  /// In en, this message translates to:
  /// **'Reset copy count'**
  String get resetCopyCount;

  /// No description provided for @resetCopyCountWarning.
  ///
  /// In en, this message translates to:
  /// **'Reset this account’s copy count?'**
  String get resetCopyCountWarning;

  /// No description provided for @copyCount.
  ///
  /// In en, this message translates to:
  /// **'Copies: {count}'**
  String copyCount(int count);

  /// No description provided for @copyFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not copy the code.'**
  String get copyFailed;

  /// No description provided for @copyRecordFailed.
  ///
  /// In en, this message translates to:
  /// **'Code copied, but the count or HOTP counter could not be updated. Check the account before copying again.'**
  String get copyRecordFailed;

  /// No description provided for @sortAccounts.
  ///
  /// In en, this message translates to:
  /// **'Sort accounts'**
  String get sortAccounts;

  /// No description provided for @sortCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom order'**
  String get sortCustom;

  /// No description provided for @sortNameAscending.
  ///
  /// In en, this message translates to:
  /// **'Name A–Z'**
  String get sortNameAscending;

  /// No description provided for @sortNameDescending.
  ///
  /// In en, this message translates to:
  /// **'Name Z–A'**
  String get sortNameDescending;

  /// No description provided for @sortCopiesAscending.
  ///
  /// In en, this message translates to:
  /// **'Fewest copies'**
  String get sortCopiesAscending;

  /// No description provided for @sortCopiesDescending.
  ///
  /// In en, this message translates to:
  /// **'Most copies'**
  String get sortCopiesDescending;

  /// No description provided for @lockSorting.
  ///
  /// In en, this message translates to:
  /// **'Lock custom order'**
  String get lockSorting;

  /// No description provided for @unlockSorting.
  ///
  /// In en, this message translates to:
  /// **'Unlock custom order'**
  String get unlockSorting;

  /// No description provided for @clearSearchToReorder.
  ///
  /// In en, this message translates to:
  /// **'Clear the search to reorder accounts.'**
  String get clearSearchToReorder;

  /// No description provided for @reorderFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not reorder accounts. Try again.'**
  String get reorderFailed;

  /// No description provided for @dragToReorder.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder'**
  String get dragToReorder;

  /// No description provided for @codeGrouping.
  ///
  /// In en, this message translates to:
  /// **'Code grouping'**
  String get codeGrouping;

  /// No description provided for @groupNone.
  ///
  /// In en, this message translates to:
  /// **'No grouping'**
  String get groupNone;

  /// No description provided for @groupEvery.
  ///
  /// In en, this message translates to:
  /// **'Every {count} characters'**
  String groupEvery(int count);

  /// No description provided for @groupHalves.
  ///
  /// In en, this message translates to:
  /// **'Two equal groups'**
  String get groupHalves;

  /// No description provided for @groupThirds.
  ///
  /// In en, this message translates to:
  /// **'Three equal groups'**
  String get groupThirds;

  /// No description provided for @codeHidden.
  ///
  /// In en, this message translates to:
  /// **'Code hidden'**
  String get codeHidden;

  /// No description provided for @dynamicColor.
  ///
  /// In en, this message translates to:
  /// **'Use system dynamic colors'**
  String get dynamicColor;

  /// No description provided for @themeChoice.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeChoice;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow system'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeBlack.
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get themeBlack;

  /// No description provided for @themeSystemBlack.
  ///
  /// In en, this message translates to:
  /// **'System with black dark mode'**
  String get themeSystemBlack;

  /// No description provided for @accentChoice.
  ///
  /// In en, this message translates to:
  /// **'Accent color'**
  String get accentChoice;

  /// No description provided for @accentDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get accentDefault;

  /// No description provided for @accentRed.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get accentRed;

  /// No description provided for @accentOrange.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get accentOrange;

  /// No description provided for @accentGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get accentGreen;

  /// No description provided for @accentTeal.
  ///
  /// In en, this message translates to:
  /// **'Teal'**
  String get accentTeal;

  /// No description provided for @accentBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get accentBlue;

  /// No description provided for @accentIndigo.
  ///
  /// In en, this message translates to:
  /// **'Indigo'**
  String get accentIndigo;

  /// No description provided for @accentPink.
  ///
  /// In en, this message translates to:
  /// **'Pink'**
  String get accentPink;

  /// No description provided for @accentPriority.
  ///
  /// In en, this message translates to:
  /// **'System dynamic colors take priority when enabled and available.'**
  String get accentPriority;

  /// No description provided for @showSavedAccountQr.
  ///
  /// In en, this message translates to:
  /// **'Show saved account QR code'**
  String get showSavedAccountQr;

  /// No description provided for @qrSecretWarning.
  ///
  /// In en, this message translates to:
  /// **'This QR code contains the saved account secret in plain text. Anyone who scans or photographs it can generate your codes. Show it only to a trusted device. Unsaved edits are not included. The receiving app may ignore some code settings; verify them after scanning.'**
  String get qrSecretWarning;

  /// No description provided for @qrUnsupportedAccount.
  ///
  /// In en, this message translates to:
  /// **'QR export is available only for time-based and counter-based accounts.'**
  String get qrUnsupportedAccount;

  /// No description provided for @qrAccountUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The saved account could not be loaded.'**
  String get qrAccountUnavailable;

  /// No description provided for @qrTooLarge.
  ///
  /// In en, this message translates to:
  /// **'The QR code cannot be displayed at a scannable size.'**
  String get qrTooLarge;

  /// No description provided for @qrSecretSemantics.
  ///
  /// In en, this message translates to:
  /// **'QR code containing an account secret'**
  String get qrSecretSemantics;

  /// No description provided for @qrUnsupportedParameters.
  ///
  /// In en, this message translates to:
  /// **'Standard QR codes require account and issuer names without colons and a 6- or 8-digit code.'**
  String get qrUnsupportedParameters;

  /// No description provided for @exportHtml.
  ///
  /// In en, this message translates to:
  /// **'Export HTML backup'**
  String get exportHtml;

  /// No description provided for @htmlBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Account QR backup'**
  String get htmlBackupTitle;

  /// No description provided for @htmlPlainWarning.
  ///
  /// In en, this message translates to:
  /// **'This unencrypted HTML file contains account secrets in QR codes. Anyone with the file can generate your codes. Store it securely. It does not include categories, icons, settings or statistics, and cannot be restored as a backup file. Some apps may ignore code settings.'**
  String get htmlPlainWarning;

  /// No description provided for @htmlExportFailed.
  ///
  /// In en, this message translates to:
  /// **'The file could not be created. Check that all accounts support standard QR codes and the backup is not too large.'**
  String get htmlExportFailed;

  /// No description provided for @migrationTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan migration codes'**
  String get migrationTitle;

  /// No description provided for @migrationNext.
  ///
  /// In en, this message translates to:
  /// **'Received {received} of {total} codes. Continue to scan the next code, or cancel to discard this import.'**
  String migrationNext(int received, int total);

  /// No description provided for @migrationConfirm.
  ///
  /// In en, this message translates to:
  /// **'Import {count} accounts? Accounts with the same issuer and account name will be updated; existing icons, order and copy counts will be retained.'**
  String migrationConfirm(int count);

  /// No description provided for @migrationImported.
  ///
  /// In en, this message translates to:
  /// **'Imported {count} accounts.'**
  String migrationImported(int count);

  /// No description provided for @migrationInvalid.
  ///
  /// In en, this message translates to:
  /// **'The migration data is invalid, unsupported, duplicated or incomplete. No accounts were imported.'**
  String get migrationInvalid;

  /// No description provided for @languageChoice.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageChoice;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow system'**
  String get languageSystem;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @categoryCreate.
  ///
  /// In en, this message translates to:
  /// **'Create category'**
  String get categoryCreate;

  /// No description provided for @categoryRename.
  ///
  /// In en, this message translates to:
  /// **'Rename category'**
  String get categoryRename;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get categoryName;

  /// No description provided for @categoryOperationFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save the category. Check its name and try again.'**
  String get categoryOperationFailed;

  /// No description provided for @categoryLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load categories.'**
  String get categoryLoadFailed;

  /// No description provided for @categoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No categories yet.'**
  String get categoryEmpty;

  /// No description provided for @categoryDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get categoryDefault;

  /// No description provided for @categoryActions.
  ///
  /// In en, this message translates to:
  /// **'Category actions'**
  String get categoryActions;

  /// No description provided for @categoryClearDefault.
  ///
  /// In en, this message translates to:
  /// **'Clear default'**
  String get categoryClearDefault;

  /// No description provided for @categorySetDefault.
  ///
  /// In en, this message translates to:
  /// **'Set as default'**
  String get categorySetDefault;

  /// No description provided for @categoryDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete category'**
  String get categoryDelete;

  /// No description provided for @categoryDeleteWarning.
  ///
  /// In en, this message translates to:
  /// **'Delete this category? Accounts will remain.'**
  String get categoryDeleteWarning;

  /// No description provided for @assignCategories.
  ///
  /// In en, this message translates to:
  /// **'Assign categories'**
  String get assignCategories;

  /// No description provided for @assignAccounts.
  ///
  /// In en, this message translates to:
  /// **'Assign accounts'**
  String get assignAccounts;

  /// No description provided for @categorySelectionEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing to select.'**
  String get categorySelectionEmpty;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All accounts'**
  String get allCategories;

  /// No description provided for @uncategorized.
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get uncategorized;

  /// No description provided for @categoryFilter.
  ///
  /// In en, this message translates to:
  /// **'Filter categories'**
  String get categoryFilter;

  /// No description provided for @clearFilterToReorder.
  ///
  /// In en, this message translates to:
  /// **'Show all accounts and clear search to reorder.'**
  String get clearFilterToReorder;

  /// No description provided for @backupReminders.
  ///
  /// In en, this message translates to:
  /// **'Backup reminders'**
  String get backupReminders;

  /// No description provided for @backupReminderMessage.
  ///
  /// In en, this message translates to:
  /// **'Your data has changed. Create a backup.'**
  String get backupReminderMessage;

  /// No description provided for @accountView.
  ///
  /// In en, this message translates to:
  /// **'Account view'**
  String get accountView;

  /// No description provided for @viewDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get viewDefault;

  /// No description provided for @viewCompact.
  ///
  /// In en, this message translates to:
  /// **'Compact'**
  String get viewCompact;

  /// No description provided for @viewTiles.
  ///
  /// In en, this message translates to:
  /// **'Tiles'**
  String get viewTiles;

  /// No description provided for @externalAccount.
  ///
  /// In en, this message translates to:
  /// **'External account link'**
  String get externalAccount;

  /// No description provided for @externalAccountInvalid.
  ///
  /// In en, this message translates to:
  /// **'The link is invalid or unsupported. No account was imported.'**
  String get externalAccountInvalid;

  /// No description provided for @externalAccountUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Could not receive external account links.'**
  String get externalAccountUnavailable;

  /// No description provided for @systemCodeFont.
  ///
  /// In en, this message translates to:
  /// **'Use system font for codes'**
  String get systemCodeFont;

  /// No description provided for @legacyImport.
  ///
  /// In en, this message translates to:
  /// **'Import andOTP backup'**
  String get legacyImport;

  /// No description provided for @legacyImportFormat.
  ///
  /// In en, this message translates to:
  /// **'Choose backup format'**
  String get legacyImportFormat;

  /// No description provided for @legacyPlain.
  ///
  /// In en, this message translates to:
  /// **'Plain JSON'**
  String get legacyPlain;

  /// No description provided for @legacyEncrypted.
  ///
  /// In en, this message translates to:
  /// **'Encrypted backup (0.6.3 or later)'**
  String get legacyEncrypted;

  /// No description provided for @legacyEncryptedOld.
  ///
  /// In en, this message translates to:
  /// **'Old encrypted backup (0.6.2 or earlier)'**
  String get legacyEncryptedOld;

  /// No description provided for @legacyImportWarning.
  ///
  /// In en, this message translates to:
  /// **'Import {count} accounts? Matching issuer and account names will be updated; existing icons, order, copy counts, and categories are preserved. Source categories are merged by name; source icons and usage statistics are not imported.'**
  String legacyImportWarning(int count);

  /// No description provided for @legacyImportError.
  ///
  /// In en, this message translates to:
  /// **'Import failed. Check the file, password, and format. Only TOTP, HOTP, and Steam accounts with an issuer and account name are supported; duplicate accounts, invalid tags, or unsupported entries reject the entire file.'**
  String get legacyImportError;

  /// No description provided for @revealPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get revealPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @tokenListImport.
  ///
  /// In en, this message translates to:
  /// **'Import FreeOTP+ backup'**
  String get tokenListImport;

  /// No description provided for @tokenListImportError.
  ///
  /// In en, this message translates to:
  /// **'Import failed. Check the plain JSON file. Accounts, order, secrets, categories, and OTP parameters must be valid; duplicates, missing records, or unsupported entries reject the entire file.'**
  String get tokenListImportError;

  /// No description provided for @vaultImport.
  ///
  /// In en, this message translates to:
  /// **'Import Bitwarden JSON'**
  String get vaultImport;

  /// No description provided for @vaultImportWarning.
  ///
  /// In en, this message translates to:
  /// **'Import {count} verification accounts and skip {skipped} non-login or no-code items? Matching accounts are updated, existing categories and metadata are preserved, and folders merge into categories. Passwords, notes, attachments, and other data are not imported.'**
  String vaultImportWarning(int count, int skipped);

  /// No description provided for @vaultImportError.
  ///
  /// In en, this message translates to:
  /// **'Import failed. Choose an unencrypted JSON export and check the codes, folders, and account names. Duplicate or unsupported codes reject the entire file.'**
  String get vaultImportError;

  /// No description provided for @groupedImport.
  ///
  /// In en, this message translates to:
  /// **'Import Aegis backup'**
  String get groupedImport;

  /// No description provided for @groupedImportWarning.
  ///
  /// In en, this message translates to:
  /// **'Import {count} accounts? Matching accounts are updated; existing categories and account metadata are preserved. Source groups merge into categories; missing issuers use the account name. New accounts retain supported custom images, while existing icons remain. Notes and favorites are not imported.'**
  String groupedImportWarning(int count);

  /// No description provided for @groupedImportError.
  ///
  /// In en, this message translates to:
  /// **'Import failed. Check the file, password, groups, and OTP parameters. Unsupported encryption parameters, invalid entries, or duplicates reject the entire file.'**
  String get groupedImportError;

  /// No description provided for @backupDecrypting.
  ///
  /// In en, this message translates to:
  /// **'Decrypting backup. Please wait.'**
  String get backupDecrypting;

  /// No description provided for @uriBackupImport.
  ///
  /// In en, this message translates to:
  /// **'Import Proton Authenticator backup'**
  String get uriBackupImport;

  /// No description provided for @uriBackupImportWarning.
  ///
  /// In en, this message translates to:
  /// **'Import {count} accounts? Matching accounts are updated and existing categories and metadata are preserved. Unnamed Steam accounts use “Steam” as their account name; source notes are not imported.'**
  String uriBackupImportWarning(int count);

  /// No description provided for @uriBackupImportError.
  ///
  /// In en, this message translates to:
  /// **'Import failed. Check the file, password, and account names. Duplicate, invalid, or unsupported records reject the entire file.'**
  String get uriBackupImportError;

  /// No description provided for @authproImport.
  ///
  /// In en, this message translates to:
  /// **'Import .authpro file'**
  String get authproImport;

  /// No description provided for @authproImportWarning.
  ///
  /// In en, this message translates to:
  /// **'Import {count} accounts? Matching accounts are updated; existing categories and metadata remain. Source categories are merged. Unnamed accounts use the issuer as their name. New accounts keep supported custom images; existing account icons remain. Source built-in icons and category-specific ordering are not imported.'**
  String authproImportWarning(int count);

  /// No description provided for @authproImportError.
  ///
  /// In en, this message translates to:
  /// **'Import failed. Check the file, password, and account parameters. Invalid, duplicate, or unsupported records reject the entire file.'**
  String get authproImportError;

  /// No description provided for @authproLegacyWarning.
  ///
  /// In en, this message translates to:
  /// **'Import {count} accounts? Matching accounts are updated; existing categories and metadata remain. Source categories are merged. Unnamed accounts use the issuer as their name. New accounts keep supported custom images; existing account icons remain. Source built-in icons and category-specific ordering are not imported. This legacy encryption cannot verify file integrity.'**
  String authproLegacyWarning(int count);

  /// No description provided for @pinLengthRequired.
  ///
  /// In en, this message translates to:
  /// **'PIN must contain {count} characters'**
  String pinLengthRequired(int count);

  /// No description provided for @twoFasImport.
  ///
  /// In en, this message translates to:
  /// **'Import 2FAS backup'**
  String get twoFasImport;

  /// No description provided for @twoFasImportWarning.
  ///
  /// In en, this message translates to:
  /// **'Import {count} accounts? Matching accounts are updated and existing metadata is preserved. Groups merge into categories; group names are not authenticated in encrypted files. Missing account names use the service name. Source icons and display order are not imported.'**
  String twoFasImportWarning(int count);

  /// No description provided for @twoFasImportError.
  ///
  /// In en, this message translates to:
  /// **'Import failed. Check the file, password, and account details. Invalid, duplicate, or unsupported entries reject the entire file.'**
  String get twoFasImportError;

  /// No description provided for @lastPassImport.
  ///
  /// In en, this message translates to:
  /// **'Import LastPass Authenticator backup'**
  String get lastPassImport;

  /// No description provided for @lastPassImportWarning.
  ///
  /// In en, this message translates to:
  /// **'Import {count} accounts? Matching accounts are updated; existing metadata remains. Folders merge into categories. Missing issuer or account names use the other name. Source favorites, icons and folder ordering are not imported.'**
  String lastPassImportWarning(int count);

  /// No description provided for @lastPassImportError.
  ///
  /// In en, this message translates to:
  /// **'Import failed. Only version 3 files with supported 6–10 digit accounts can be imported. Invalid, duplicate or unsupported entries reject the entire file.'**
  String get lastPassImportError;

  /// No description provided for @winAuthImport.
  ///
  /// In en, this message translates to:
  /// **'Import WinAuth backup'**
  String get winAuthImport;

  /// No description provided for @winAuthImportWarning.
  ///
  /// In en, this message translates to:
  /// **'Import {count} accounts? Matching accounts are updated and existing metadata is preserved. Missing issuer or account names use the other name. Source icons and other metadata are not imported. Older ZIP encryption uses CRC and cannot authenticate file integrity.'**
  String winAuthImportWarning(int count);

  /// No description provided for @winAuthImportError.
  ///
  /// In en, this message translates to:
  /// **'Import failed. Check the file, password and account details. Unsupported, invalid or duplicate entries reject the entire file.'**
  String get winAuthImportError;

  /// No description provided for @totpAuthImport.
  ///
  /// In en, this message translates to:
  /// **'Import TOTP Authenticator backup'**
  String get totpAuthImport;

  /// No description provided for @totpAuthImportWarning.
  ///
  /// In en, this message translates to:
  /// **'Import {count} accounts? Matching accounts are updated and existing metadata is preserved. Missing issuer or account names use the other name. Source icons and other metadata are not imported. This older encryption cannot authenticate file integrity.'**
  String totpAuthImportWarning(int count);

  /// No description provided for @totpAuthImportError.
  ///
  /// In en, this message translates to:
  /// **'Import failed. Check the password and account details. Invalid, duplicate or unsupported records reject the entire file.'**
  String get totpAuthImportError;

  /// No description provided for @chooseCustomIcon.
  ///
  /// In en, this message translates to:
  /// **'Choose image'**
  String get chooseCustomIcon;

  /// No description provided for @invalidCustomIcon.
  ///
  /// In en, this message translates to:
  /// **'Choose a valid PNG or JPEG image up to 4096 pixels per side.'**
  String get invalidCustomIcon;

  /// No description provided for @backupProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing backup. Please wait.'**
  String get backupProcessing;

  /// No description provided for @importIconPack.
  ///
  /// In en, this message translates to:
  /// **'Import icon pack'**
  String get importIconPack;

  /// No description provided for @iconLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load icons.'**
  String get iconLoadError;

  /// No description provided for @iconPackImportConfirm.
  ///
  /// In en, this message translates to:
  /// **'Import “{name}” with {count} icons? An existing pack with the same name will be replaced.'**
  String iconPackImportConfirm(String name, int count);

  /// No description provided for @iconPackImported.
  ///
  /// In en, this message translates to:
  /// **'Icon pack imported.'**
  String get iconPackImported;

  /// No description provided for @iconPackError.
  ///
  /// In en, this message translates to:
  /// **'Could not process the icon pack. Check its format and images.'**
  String get iconPackError;

  /// No description provided for @iconPackDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete “{name}”? Icons already assigned to accounts will remain.'**
  String iconPackDeleteConfirm(String name);

  /// No description provided for @freeOtpImport.
  ///
  /// In en, this message translates to:
  /// **'Import FreeOTP backup'**
  String get freeOtpImport;

  /// No description provided for @freeOtpImportWarning.
  ///
  /// In en, this message translates to:
  /// **'Import {count} accounts? Matching accounts are updated and existing metadata is preserved. Missing issuers use the account label; source icons and ordering are not imported.'**
  String freeOtpImportWarning(int count);

  /// No description provided for @freeOtpImportError.
  ///
  /// In en, this message translates to:
  /// **'Import failed. Check the password and backup. Unsupported, invalid or duplicate records reject the entire file.'**
  String get freeOtpImportError;

  /// No description provided for @importAccountCounts.
  ///
  /// In en, this message translates to:
  /// **'New accounts: {newCount}. Existing accounts to update: {updateCount}.'**
  String importAccountCounts(int newCount, int updateCount);

  /// No description provided for @importPreviewExpired.
  ///
  /// In en, this message translates to:
  /// **'Accounts or settings changed. Select the file again to review the updated counts.'**
  String get importPreviewExpired;

  /// No description provided for @migrationGuides.
  ///
  /// In en, this message translates to:
  /// **'Migration guides'**
  String get migrationGuides;

  /// No description provided for @migrationGuideIntro.
  ///
  /// In en, this message translates to:
  /// **'Follow the steps for your existing service. Keep your existing access and recovery options until the new setup works.'**
  String get migrationGuideIntro;

  /// No description provided for @authyGuide.
  ///
  /// In en, this message translates to:
  /// **'Authy does not provide token export. For each service:\n\n1. Sign in using your existing verification method.\n2. In that service’s security settings, turn off two-factor authentication and enable it again.\n3. Scan the new QR code in this app, or enter the new setup key manually.\n4. Verify a new code with the service before removing the old entry.\n\nServices may offer different recovery options. If you cannot sign in, contact that service’s support.\n\nOfficial help: https://help.twilio.com/hc/en-us/articles/19753420684059-Export-or-Import-Tokens-in-the-Authy-app-Not-Supported'**
  String get authyGuide;

  /// No description provided for @steamGuide.
  ///
  /// In en, this message translates to:
  /// **'Steam’s official transfer moves its mobile authenticator to the Steam app on a new device; it does not export its secret to this app.\n\n1. Install Steam Mobile on the new phone and sign in.\n2. On the Steam Guard screen, choose Move Authenticator and follow the confirmation steps.\n3. Store the new recovery code safely. If the old device is unavailable, follow Steam’s recovery instructions or contact Steam Support.\n\nThis app can generate Steam codes if you already have a compatible secret, but this guide does not retrieve one. Steam’s official transfer may impose temporary trading restrictions.\n\nOfficial help: https://help.steampowered.com/en/faqs/view/29A9-9EEE-09F0-75F9'**
  String get steamGuide;

  /// No description provided for @blizzardGuide.
  ///
  /// In en, this message translates to:
  /// **'Blizzard account authentication is managed through its official mobile app. This guide does not extract or import its secret.\n\n1. Keep your existing authenticator and recovery information available.\n2. On the new device, sign in to the official app and follow its authenticator setup or recovery prompts.\n3. If you cannot approve the sign-in or restore access, use Blizzard Support’s account recovery process before removing the old authenticator.\n\nCheck the provider’s current instructions before making changes: https://us.support.blizzard.com/'**
  String get blizzardGuide;

  /// No description provided for @userGuide.
  ///
  /// In en, this message translates to:
  /// **'Using the app'**
  String get userGuide;

  /// No description provided for @guideAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add an account'**
  String get guideAddTitle;

  /// No description provided for @guideAddBody.
  ///
  /// In en, this message translates to:
  /// **'Choose Add to scan a setup QR code, select a supported image, or enter the setup key. Verify a code with the service before removing your previous method.'**
  String get guideAddBody;

  /// No description provided for @guideCodesTitle.
  ///
  /// In en, this message translates to:
  /// **'Use your codes'**
  String get guideCodesTitle;

  /// No description provided for @guideCodesBody.
  ///
  /// In en, this message translates to:
  /// **'Enter the current code at the service. Time-based codes change automatically; counter-based codes can be advanced manually. Search, categories, and sorting help organize accounts.'**
  String get guideCodesBody;

  /// No description provided for @guideBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep a backup'**
  String get guideBackupTitle;

  /// No description provided for @guideBackupBody.
  ///
  /// In en, this message translates to:
  /// **'Export a password-protected backup and store it safely. Test recovery before replacing your device. Unencrypted exports and QR codes reveal account secrets.'**
  String get guideBackupBody;

  /// No description provided for @guideMigrationTitle.
  ///
  /// In en, this message translates to:
  /// **'Move existing accounts'**
  String get guideMigrationTitle;

  /// No description provided for @guideMigrationBody.
  ///
  /// In en, this message translates to:
  /// **'Choose Add to import a supported file or follow the migration guides. Imports show a confirmation and conflict policy before saving.'**
  String get guideMigrationBody;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcomeTitle;

  /// No description provided for @welcomeIntro.
  ///
  /// In en, this message translates to:
  /// **'Set up verification codes, keep a protected backup, and retain recovery options for your accounts.'**
  String get welcomeIntro;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutApp;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'An offline app for managing verification codes.'**
  String get aboutDescription;

  /// No description provided for @sourceCode.
  ///
  /// In en, this message translates to:
  /// **'Source code'**
  String get sourceCode;

  /// No description provided for @openSourceLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open-source licenses'**
  String get openSourceLicenses;

  /// No description provided for @aboutPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Account secrets are encrypted on this device. Exported files and QR codes may reveal them.'**
  String get aboutPrivacy;

  /// No description provided for @googleGuide.
  ///
  /// In en, this message translates to:
  /// **'On the old device, open Google Authenticator, choose the menu, then Transfer codes (or Transfer accounts) and Export. Unlock the device, select the accounts, and continue to display the QR code.\n\nIn this app, return to Add and choose Scan QR code. Scan every code from the same export; this app asks for confirmation after the complete batch is received. Check the import summary and verify codes with the services before removing the old setup.\n\nThe QR codes contain account secrets. Keep them private. Camera support varies by platform; unsupported or incomplete batches are not imported. If the old device is unavailable, use each service’s recovery options.\n\nOfficial help: https://support.google.com/accounts/answer/1066447'**
  String get googleGuide;

  /// No description provided for @automaticBackup.
  ///
  /// In en, this message translates to:
  /// **'Automatic backup'**
  String get automaticBackup;

  /// No description provided for @autoBackupIntro.
  ///
  /// In en, this message translates to:
  /// **'Choose a local storage folder and a backup password. The app saves a new encrypted file after changes while it is running. Keep the password separately; losing it prevents recovery. Old files are not deleted and keep their original password.'**
  String get autoBackupIntro;

  /// No description provided for @autoBackupUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Automatic backup is not available on this platform.'**
  String get autoBackupUnsupported;

  /// No description provided for @autoBackupDisabled.
  ///
  /// In en, this message translates to:
  /// **'Automatic backup is off.'**
  String get autoBackupDisabled;

  /// No description provided for @autoBackupReady.
  ///
  /// In en, this message translates to:
  /// **'Automatic backup is enabled.'**
  String get autoBackupReady;

  /// No description provided for @autoBackupSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving an encrypted backup…'**
  String get autoBackupSaving;

  /// No description provided for @autoBackupFailed.
  ///
  /// In en, this message translates to:
  /// **'Automatic backup failed. Check storage permission and try again or choose the folder again.'**
  String get autoBackupFailed;

  /// No description provided for @autoBackupConfigure.
  ///
  /// In en, this message translates to:
  /// **'Choose folder and enable'**
  String get autoBackupConfigure;

  /// No description provided for @autoBackupRetry.
  ///
  /// In en, this message translates to:
  /// **'Back up now'**
  String get autoBackupRetry;

  /// No description provided for @autoBackupDisable.
  ///
  /// In en, this message translates to:
  /// **'Turn off'**
  String get autoBackupDisable;

  /// No description provided for @autoBackupLocalOnly.
  ///
  /// In en, this message translates to:
  /// **'Choose a local device storage folder, not a cloud provider.'**
  String get autoBackupLocalOnly;

  /// No description provided for @autoBackupSaved.
  ///
  /// In en, this message translates to:
  /// **'Encrypted backup saved and verified.'**
  String get autoBackupSaved;
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
