// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'Purity Auth';

  @override
  String get add => '추가';

  @override
  String get scan => '스캔';

  @override
  String get settings => '설정';

  @override
  String get scanQRCode => 'QR코드 스캔';

  @override
  String get secret => '시크릿';

  @override
  String get algorithm => '알고리즘';

  @override
  String get digits => '자릿수';

  @override
  String get cancel => '취소';

  @override
  String get delete => '삭제';

  @override
  String get edit => '편집';

  @override
  String get ok => '확인';

  @override
  String get codeCopied => '코드가 복사되었습니다';

  @override
  String get tip => '알림';

  @override
  String get warning => '경고';

  @override
  String get importFailed => '가져오기 실패';

  @override
  String get importSuccess => '가져오기 성공';

  @override
  String get exportSuccess => '내보내기 성공';

  @override
  String get addSuccess => '추가 성공';

  @override
  String get updateSuccess => '업데이트 성공';

  @override
  String get saveFailed => '저장 실패';

  @override
  String get platformNotSupported => '이 기능은 현재 Android와 iOS 플랫폼에서만 지원됩니다.';

  @override
  String get cannotGetClipboardData => '클립보드 데이터를 가져올 수 없습니다';

  @override
  String importedCount(int count) {
    return '$count개의 데이터가 클립보드에서 가져왔습니다';
  }

  @override
  String exportedCount(int count) {
    return '$count개의 데이터가 클립보드로 내보냈습니다';
  }

  @override
  String get unsupportedQRCode => '이 타입의 QR코드는 지원되지 않습니다';

  @override
  String tokenExists(String issuer, String account) {
    return '토큰$issuer:$account이 이미 존재합니다. 덮어쓰시겠습니까?';
  }

  @override
  String get deleteWarning =>
      '현재의 이단계 인증기를 삭제하려고 합니다.\n이 작업으로 이 인증기를 사용한 인증을 할 수 없게 됩니다.\n계정의 보안을 위해 다른 인증 방법이 준비되어 있는지 확인하세요.';

  @override
  String get uploadQRCode => 'QR코드 가져오기';

  @override
  String get enterKey => '키 입력';

  @override
  String get importFromClipboard => '클립보드에서 가져오기';

  @override
  String get exportToClipboard => '클립보드로 내보내기';

  @override
  String get enterProvidedKey => '키 입력';

  @override
  String get type => '타입';

  @override
  String get issuer => '발급자';

  @override
  String get account => '계정';

  @override
  String get pin => 'PIN 코드';

  @override
  String get period => '기간(초)';

  @override
  String get counter => '카운터';

  @override
  String get totp => 'TOTP(시간 기반)';

  @override
  String get hotp => 'HOTP(카운터 기반)';

  @override
  String get motp => 'mOTP(모바일 OTP)';

  @override
  String get showCaptchaOnTap => '탭하여 표시';

  @override
  String get copyCaptchaOnTap => '탭하여 복사';

  @override
  String get sha1 => 'SHA1';

  @override
  String get sha256 => 'SHA256';

  @override
  String get sha512 => 'SHA512';

  @override
  String get selectIcon => '아이콘 선택';

  @override
  String get invalidSecret => '유효하지 않은 시크릿';

  @override
  String get dismiss => '닫기';

  @override
  String get invalidScheme => '유효하지 않은 스킴';

  @override
  String get invalidType => '유효하지 않은 타입';

  @override
  String get issuerCannotBeEmpty => '발급자는 비어 있을 수 없습니다';

  @override
  String get accountCannotBeEmpty => '계정은 비어 있을 수 없습니다';

  @override
  String get invalidAlgorithm => '유효하지 않은 알고리즘';

  @override
  String get invalidDigits => '유효하지 않은 자릿수';

  @override
  String get invalidPeriod => '유효하지 않은 기간';

  @override
  String get invalidCounter => '유효하지 않은 카운터';

  @override
  String get invalidPin => '유효하지 않은 PIN 코드';

  @override
  String get invalidSecretKey => '유효하지 않은 시크릿 키';

  @override
  String get noData => '데이터 없음';

  @override
  String get search => '검색';

  @override
  String get importWarning =>
      '클립보드에서 데이터를 가져오려고 합니다. 데이터베이스에 동일한 계정이 이미 있는 경우 덮어씌워집니다. 계속하시겠습니까?';

  @override
  String get exportFailed => '내보내기 실패';

  @override
  String get noDataToExport => '내보낼 데이터가 없습니다';

  @override
  String get exportWarning =>
      '모든 인증기를 클립보드로 내보내려고 합니다. 내보낸 내용은 일반 텍스트 형식입니다. 사용 중인 환경이 안전한지 확인하고 나중에 클립보드를 비워주세요. 계속하시겠습니까?';
}
