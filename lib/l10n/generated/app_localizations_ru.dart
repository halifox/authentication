// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Purity Auth';

  @override
  String get add => 'Добавить';

  @override
  String get scan => 'Сканировать';

  @override
  String get settings => 'Настройки';

  @override
  String get scanQRCode => 'Сканировать QR-код';

  @override
  String get secret => 'Секрет';

  @override
  String get algorithm => 'Алгоритм';

  @override
  String get digits => 'Цифры';

  @override
  String get cancel => 'Отмена';

  @override
  String get delete => 'Удалить';

  @override
  String get edit => 'Редактировать';

  @override
  String get ok => 'OK';

  @override
  String get codeCopied => 'Код скопирован';

  @override
  String get tip => 'Подсказка';

  @override
  String get warning => 'Предупреждение';

  @override
  String get importFailed => 'Импорт не удался';

  @override
  String get importSuccess => 'Импорт успешен';

  @override
  String get exportSuccess => 'Экспорт успешен';

  @override
  String get addSuccess => 'Успешно добавлено';

  @override
  String get updateSuccess => 'Обновление успешно';

  @override
  String get saveFailed => 'Сохранение не удалось';

  @override
  String get platformNotSupported =>
      'Эта функция в настоящее время поддерживается только на платформах Android и iOS.';

  @override
  String get cannotGetClipboardData =>
      'Невозможно получить данные буфера обмена';

  @override
  String importedCount(int count) {
    return '$count элементов импортировано из буфера обмена';
  }

  @override
  String exportedCount(int count) {
    return '$count элементов экспортировано в буфер обмена';
  }

  @override
  String get unsupportedQRCode => 'Этот тип QR-кода не поддерживается';

  @override
  String tokenExists(String issuer, String account) {
    return 'Токен $issuer:$account уже существует. Хотите перезаписать?';
  }

  @override
  String get deleteWarning =>
      'Вы собираетесь удалить текущий двухфакторный аутентификатор.\nЭто действие не позволит вам использовать этот аутентификатор для аутентификации.\nПожалуйста, убедитесь, что у вас есть другие методы аутентификации для обеспечения безопасности аккаунта.';

  @override
  String get uploadQRCode => 'Импорт QR-кода';

  @override
  String get enterKey => 'Ввести ключ';

  @override
  String get importFromClipboard => 'Импорт из буфера обмена';

  @override
  String get exportToClipboard => 'Экспорт в буфер обмена';

  @override
  String get enterProvidedKey => 'Ввести ключ';

  @override
  String get type => 'Тип';

  @override
  String get issuer => 'Издатель';

  @override
  String get account => 'Аккаунт';

  @override
  String get pin => 'PIN-код';

  @override
  String get period => 'Период (секунды)';

  @override
  String get counter => 'Счетчик';

  @override
  String get totp => 'TOTP (Основанный на времени)';

  @override
  String get hotp => 'HOTP (Основанный на счетчике)';

  @override
  String get motp => 'mOTP (Мобильный OTP)';

  @override
  String get showCaptchaOnTap => 'Коснуться для показа';

  @override
  String get copyCaptchaOnTap => 'Коснуться для копирования';

  @override
  String get sha1 => 'SHA1';

  @override
  String get sha256 => 'SHA256';

  @override
  String get sha512 => 'SHA512';

  @override
  String get selectIcon => 'Выбрать значок';

  @override
  String get invalidSecret => 'Неверный секрет';

  @override
  String get dismiss => 'Закрыть';

  @override
  String get invalidScheme => 'Неверная схема';

  @override
  String get invalidType => 'Неверный тип';

  @override
  String get issuerCannotBeEmpty => 'Издатель не может быть пустым';

  @override
  String get accountCannotBeEmpty => 'Аккаунт не может быть пустым';

  @override
  String get invalidAlgorithm => 'Неверный алгоритм';

  @override
  String get invalidDigits => 'Неверное количество цифр';

  @override
  String get invalidPeriod => 'Неверный период';

  @override
  String get invalidCounter => 'Неверный счетчик';

  @override
  String get invalidPin => 'Неверный PIN-код';

  @override
  String get invalidSecretKey => 'Неверный секретный ключ';

  @override
  String get noData => 'Нет данных';

  @override
  String get search => 'Поиск';

  @override
  String get importWarning =>
      'Вы собираетесь импортировать данные из буфера обмена. Если в базе данных уже есть такие же учетные записи, они будут перезаписаны. Продолжить?';

  @override
  String get exportFailed => 'Экспорт не удался';

  @override
  String get noDataToExport => 'Нет данных для экспорта';

  @override
  String get exportWarning =>
      'Вы собираетесь экспортировать все аутентификаторы в буфер обмена. Экспортируемое содержимое будет в формате открытого текста. Убедитесь в безопасности вашего окружения и очистите буфер обмена после этого. Продолжить?';
}
