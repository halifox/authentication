import 'package:authentication/otp/otp.dart';
import 'package:authentication/otp/validation.dart';

/// Protocol data independent of the database and UI.
class OtpAccount {
  const OtpAccount({
    required this.type,
    required this.issuer,
    required this.account,
    required this.secret,
    this.algorithm = 'sha1',
    this.digits = 6,
    this.period = 30,
    this.counter = 0,
    this.pin = '',
    this.id = 0,
    this.icon = 'assets/icons/passkey.svg',
    this.sortOrder = 0,
    this.createdAt = 0,
    this.copyCount = 0,
  });

  final String type, issuer, account, secret, algorithm, pin;
  final int digits, period, counter, id, sortOrder, createdAt, copyCount;
  final String icon;

  OtpAccount copyWith({
    int? id,
    String? type,
    String? issuer,
    String? account,
    String? secret,
    String? algorithm,
    int? digits,
    int? period,
    int? counter,
    String? pin,
    String? icon,
    int? sortOrder,
    int? createdAt,
    int? copyCount,
  }) => OtpAccount(
    id: id ?? this.id,
    type: type ?? this.type,
    issuer: issuer ?? this.issuer,
    account: account ?? this.account,
    secret: secret ?? this.secret,
    algorithm: algorithm ?? this.algorithm,
    digits: digits ?? this.digits,
    period: period ?? this.period,
    counter: counter ?? this.counter,
    pin: pin ?? this.pin,
    icon: icon ?? this.icon,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    copyCount: copyCount ?? this.copyCount,
  );

  String generateCodeString() {
    final algo = switch (algorithm.toLowerCase()) {
      'sha1' => Algorithm.sha1,
      'sha256' => Algorithm.sha256,
      'sha512' => Algorithm.sha512,
      _ => throw StateError('Invalid OTP algorithm'),
    };
    return switch (type.toLowerCase()) {
      'totp' => OTP.generateTOTPCodeString(
        secret: secret,
        digits: digits,
        algorithm: algo,
        intervalSeconds: period,
        isBase32: true,
      ),
      'hotp' => OTP.generateHOTPCodeString(
        secret: secret,
        digits: digits,
        algorithm: algo,
        counter: counter,
        isBase32: true,
      ),
      'motp' => OTP.generateMOTPCodeString(
        secret: secret,
        digits: digits,
        intervalSeconds: period,
        pin: pin,
      ),
      'steam' => OTP.generateSteamCode(secret: secret),
      'yandex' => OTP.generateYandexCode(secret: secret, pin: pin),
      _ => throw StateError('Invalid OTP type'),
    };
  }

  String toOtpUri() {
    final kind = type.toLowerCase();
    final params = <String, String>{
      'secret': kind == 'motp' ? secret : secret.toUpperCase(),
      'issuer': issuer,
      'algorithm': algorithm.toLowerCase(),
      'digits': '$digits',
    };
    if (kind == 'totp' || kind == 'motp') params['period'] = '$period';
    if (kind == 'hotp') params['counter'] = '$counter';
    if ((kind == 'motp' || kind == 'yandex') && pin.isNotEmpty)
      params['pin'] = pin;
    return Uri(
      scheme: 'otpauth',
      host: kind,
      path: '/$issuer:$account',
      queryParameters: params,
    ).toString();
  }

  void validate() {
    if (copyCount < 0) throw const FormatException('Invalid copy count.');
    AuthValidator.validate(
      scheme: 'otpauth',
      typeStr: type,
      issuer: issuer,
      account: account,
      algorithmStr: algorithm,
      digits: digits,
      period: period,
      counter: counter,
      secret: secret,
      pin: pin,
    );
  }
}

OtpAccount parseOtpUri(String input, {bool detectSteam = false}) {
  final uri = Uri.parse(input);
  if (uri.scheme.toLowerCase() != 'otpauth') {
    throw AuthFailure(AuthErrorCode.invalidScheme);
  }
  final requestedType = uri.host.toLowerCase();
  final label = uri.path.length > 1
      ? Uri.decodeFull(uri.path.substring(1))
      : '';
  final params = uri.queryParameters;
  final secret = params['secret'];
  if (secret == null || secret.isEmpty)
    throw AuthFailure(AuthErrorCode.invalidSecretKey);
  final issuer = params['issuer']?.isNotEmpty == true
      ? params['issuer']!
      : label.contains(':')
      ? label.split(':').first.trim()
      : '';
  final account = params['account']?.isNotEmpty == true
      ? params['account']!
      : label.contains(':')
      ? label.split(':').skip(1).join(':').trim()
      : label.trim();
  final isSteam =
      detectSteam &&
      requestedType == 'totp' &&
      (issuer == 'Steam' ||
          params.containsKey('steam') ||
          params['encoder']?.toLowerCase() == 'steam');
  final type = isSteam ? 'steam' : requestedType;
  if (isSteam &&
      ((params['algorithm'] != null &&
              params['algorithm']!.toLowerCase() != 'sha1') ||
          (params['period'] != null && params['period'] != '30') ||
          (params['digits'] != null &&
              !const ['5', '6'].contains(params['digits'])))) {
    throw AuthFailure(AuthErrorCode.invalidType);
  }
  int number(String key, int defaultValue, AuthErrorCode error) {
    final value = params[key];
    return value == null
        ? defaultValue
        : int.tryParse(value) ?? (throw AuthFailure(error));
  }

  return OtpAccount(
    type: type,
    issuer: issuer,
    account: account,
    secret: type == 'motp'
        ? secret
        : secret.replaceAll(RegExp(r'\s+'), '').toUpperCase(),
    algorithm: params['algorithm'] ?? 'sha1',
    digits: isSteam ? 5 : number('digits', 6, AuthErrorCode.invalidDigits),
    period: number('period', 30, AuthErrorCode.invalidPeriod),
    counter: number('counter', 0, AuthErrorCode.invalidCounter),
    pin: params['pin'] ?? '',
  );
}

/// Produces a standard provisioning URI for QR export.
String toStandardOtpQrUri(OtpAccount account) {
  account.validate();
  final type = account.type.toLowerCase();
  if ((type != 'totp' && type != 'hotp') ||
      (account.digits != 6 && account.digits != 8) ||
      account.issuer.contains(':') ||
      account.account.contains(':')) {
    throw const FormatException('Unsupported QR account parameters.');
  }
  return Uri(
    scheme: 'otpauth',
    host: type,
    pathSegments: ['${account.issuer}:${account.account}'],
    queryParameters: {
      'secret': account.secret.replaceAll(RegExp(r'\s+|='), '').toUpperCase(),
      'issuer': account.issuer,
      'algorithm': account.algorithm.toUpperCase(),
      'digits': '${account.digits}',
      if (type == 'totp') 'period': '${account.period}',
      if (type == 'hotp') 'counter': '${account.counter}',
    },
  ).toString();
}
