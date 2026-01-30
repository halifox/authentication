// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Purity Auth';

  @override
  String get add => '追加';

  @override
  String get scan => 'スキャン';

  @override
  String get settings => '設定';

  @override
  String get scanQRCode => 'QRコードをスキャン';

  @override
  String get secret => 'シークレット';

  @override
  String get algorithm => 'アルゴリズム';

  @override
  String get digits => '桁数';

  @override
  String get cancel => 'キャンセル';

  @override
  String get delete => '削除';

  @override
  String get edit => '編集';

  @override
  String get ok => 'OK';

  @override
  String get codeCopied => 'コードがコピーされました';

  @override
  String get tip => 'ヒント';

  @override
  String get warning => '警告';

  @override
  String get importFailed => 'インポート失敗';

  @override
  String get importSuccess => 'インポート成功';

  @override
  String get exportSuccess => 'エクスポート成功';

  @override
  String get addSuccess => '追加成功';

  @override
  String get updateSuccess => '更新成功';

  @override
  String get saveFailed => '保存失敗';

  @override
  String get platformNotSupported => 'この機能は現在AndroidとiOSプラットフォームでのみサポートされています。';

  @override
  String get cannotGetClipboardData => 'クリップボードデータを取得できません';

  @override
  String importedCount(int count) {
    return '$count件のデータがクリップボードからインポートされました';
  }

  @override
  String exportedCount(int count) {
    return '$count件のデータがクリップボードにエクスポートされました';
  }

  @override
  String get unsupportedQRCode => 'この種類のQRコードはサポートされていません';

  @override
  String tokenExists(String issuer, String account) {
    return 'トークン$issuer:$accountは既に存在します。上書きしますか？';
  }

  @override
  String get deleteWarning =>
      '現在の二段階認証器を削除しようとしています。\nこの操作により、この認証器を使用した認証ができなくなります。\nアカウントのセキュリティを確保するため、他の認証方法が準備されていることを確認してください。';

  @override
  String get uploadQRCode => 'QRコードをインポート';

  @override
  String get enterKey => 'キーを入力';

  @override
  String get importFromClipboard => 'クリップボードからインポート';

  @override
  String get exportToClipboard => 'クリップボードにエクスポート';

  @override
  String get enterProvidedKey => 'キーを入力';

  @override
  String get type => 'タイプ';

  @override
  String get issuer => '発行者';

  @override
  String get account => 'アカウント';

  @override
  String get pin => 'PINコード';

  @override
  String get period => '期間（秒）';

  @override
  String get counter => 'カウンター';

  @override
  String get totp => 'TOTP（時間ベース）';

  @override
  String get hotp => 'HOTP（カウンターベース）';

  @override
  String get motp => 'mOTP（モバイルOTP）';

  @override
  String get showCaptchaOnTap => 'タップして表示';

  @override
  String get copyCaptchaOnTap => 'タップしてコピー';

  @override
  String get sha1 => 'SHA1';

  @override
  String get sha256 => 'SHA256';

  @override
  String get sha512 => 'SHA512';

  @override
  String get selectIcon => 'アイコンを選択';

  @override
  String get invalidSecret => '無効なシークレット';

  @override
  String get dismiss => '閉じる';

  @override
  String get invalidScheme => '無効なスキーム';

  @override
  String get invalidType => '無効なタイプ';

  @override
  String get issuerCannotBeEmpty => '発行者は空にできません';

  @override
  String get accountCannotBeEmpty => 'アカウントは空にできません';

  @override
  String get invalidAlgorithm => '無効なアルゴリズム';

  @override
  String get invalidDigits => '無効な桁数';

  @override
  String get invalidPeriod => '無効な期間';

  @override
  String get invalidCounter => '無効なカウンター';

  @override
  String get invalidPin => '無効なPINコード';

  @override
  String get invalidSecretKey => '無効なシークレットキー';

  @override
  String get noData => 'データなし';

  @override
  String get search => '検索';

  @override
  String get importWarning =>
      'クリップボードからデータをインポートしようとしています。データベースに同じアカウントが既に存在する場合、それらは上書きされます。続行しますか？';

  @override
  String get exportFailed => 'エクスポート失敗';

  @override
  String get noDataToExport => 'エクスポートできるデータがありません';

  @override
  String get exportWarning =>
      'すべての認証器をクリップボードにエクスポートしようとしています。エクスポートされた内容はプレーンテキスト形式になります。環境が安全であることを確認し、その後クリップボードを消去してください。続行しますか？';
}
