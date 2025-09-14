// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Purity Auth';

  @override
  String get add => 'Añadir';

  @override
  String get scan => 'Escanear';

  @override
  String get settings => 'Configuración';

  @override
  String get scanQRCode => 'Escanear código QR';

  @override
  String get secret => 'Secreto';

  @override
  String get algorithm => 'Algoritmo';

  @override
  String get digits => 'Dígitos';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get edit => 'Editar';

  @override
  String get ok => 'Aceptar';

  @override
  String get codeCopied => 'Código copiado';

  @override
  String get tip => 'Consejo';

  @override
  String get warning => 'Advertencia';

  @override
  String get importFailed => 'Importación fallida';

  @override
  String get importSuccess => 'Importación exitosa';

  @override
  String get exportSuccess => 'Exportación exitosa';

  @override
  String get addSuccess => 'Añadido con éxito';

  @override
  String get updateSuccess => 'Actualización exitosa';

  @override
  String get saveFailed => 'Error al guardar';

  @override
  String get platformNotSupported =>
      'Esta función actualmente solo es compatible con plataformas Android e iOS.';

  @override
  String get cannotGetClipboardData =>
      'No se pueden obtener los datos del portapapeles';

  @override
  String importedCount(int count) {
    return '$count elementos importados desde el portapapeles';
  }

  @override
  String exportedCount(int count) {
    return '$count elementos exportados al portapapeles';
  }

  @override
  String get unsupportedQRCode => 'Este tipo de código QR no es compatible';

  @override
  String tokenExists(String issuer, String account) {
    return 'El token $issuer:$account ya existe. ¿Desea sobrescribirlo?';
  }

  @override
  String get deleteWarning =>
      'Está a punto de eliminar el autenticador de dos factores actual.\nEsta acción le impedirá usar este autenticador para la autenticación.\nPor favor, asegúrese de tener otros métodos de autenticación listos para garantizar la seguridad de la cuenta.';

  @override
  String get uploadQRCode => 'Importar código QR';

  @override
  String get enterKey => 'Ingresar clave';

  @override
  String get importFromClipboard => 'Importar desde portapapeles';

  @override
  String get exportToClipboard => 'Exportar al portapapeles';

  @override
  String get enterProvidedKey => 'Ingresar clave';

  @override
  String get type => 'Tipo';

  @override
  String get issuer => 'Emisor';

  @override
  String get account => 'Cuenta';

  @override
  String get pin => 'Código PIN';

  @override
  String get period => 'Período (segundos)';

  @override
  String get counter => 'Contador';

  @override
  String get totp => 'TOTP (Basado en tiempo)';

  @override
  String get hotp => 'HOTP (Basado en contador)';

  @override
  String get motp => 'mOTP (OTP Móvil)';

  @override
  String get showCaptchaOnTap => 'Tocar para mostrar';

  @override
  String get copyCaptchaOnTap => 'Tocar para copiar';

  @override
  String get sha1 => 'SHA1';

  @override
  String get sha256 => 'SHA256';

  @override
  String get sha512 => 'SHA512';

  @override
  String get selectIcon => 'Seleccionar icono';

  @override
  String get invalidSecret => 'Secreto inválido';

  @override
  String get dismiss => 'Cerrar';

  @override
  String get invalidScheme => 'Esquema inválido';

  @override
  String get invalidType => 'Tipo inválido';

  @override
  String get issuerCannotBeEmpty => 'El emisor no puede estar vacío';

  @override
  String get accountCannotBeEmpty => 'La cuenta no puede estar vacía';

  @override
  String get invalidAlgorithm => 'Algoritmo inválido';

  @override
  String get invalidDigits => 'Número de dígitos inválido';

  @override
  String get invalidPeriod => 'Período inválido';

  @override
  String get invalidCounter => 'Contador inválido';

  @override
  String get invalidPin => 'Código PIN inválido';

  @override
  String get invalidSecretKey => 'Clave secreta inválida';
}
