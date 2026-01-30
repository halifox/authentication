// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Purity Auth';

  @override
  String get add => 'Adicionar';

  @override
  String get scan => 'Escanear';

  @override
  String get settings => 'Configurações';

  @override
  String get scanQRCode => 'Escanear código QR';

  @override
  String get secret => 'Segredo';

  @override
  String get algorithm => 'Algoritmo';

  @override
  String get digits => 'Dígitos';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Apagar';

  @override
  String get edit => 'Editar';

  @override
  String get ok => 'OK';

  @override
  String get codeCopied => 'Código copiado';

  @override
  String get tip => 'Dica';

  @override
  String get warning => 'Aviso';

  @override
  String get importFailed => 'Importação falhada';

  @override
  String get importSuccess => 'Importação bem-sucedida';

  @override
  String get exportSuccess => 'Exportação bem-sucedida';

  @override
  String get addSuccess => 'Adicionado com sucesso';

  @override
  String get updateSuccess => 'Atualização bem-sucedida';

  @override
  String get saveFailed => 'Falha ao guardar';

  @override
  String get platformNotSupported =>
      'Esta funcionalidade é atualmente suportada apenas nas plataformas Android e iOS.';

  @override
  String get cannotGetClipboardData =>
      'Não é possível obter dados da área de transferência';

  @override
  String importedCount(int count) {
    return '$count itens importados da área de transferência';
  }

  @override
  String exportedCount(int count) {
    return '$count itens exportados para a área de transferência';
  }

  @override
  String get unsupportedQRCode => 'Este tipo de código QR não é suportado';

  @override
  String tokenExists(String issuer, String account) {
    return 'O token $issuer:$account já existe. Deseja sobrescrever?';
  }

  @override
  String get deleteWarning =>
      'Está prestes a apagar o autenticador de dois fatores atual.\nEsta ação impedirá que use este autenticador para autenticação.\nPor favor, certifique-se de que tem outros métodos de autenticação prontos para garantir a segurança da conta.';

  @override
  String get uploadQRCode => 'Importar código QR';

  @override
  String get enterKey => 'Inserir chave';

  @override
  String get importFromClipboard => 'Importar da área de transferência';

  @override
  String get exportToClipboard => 'Exportar para área de transferência';

  @override
  String get enterProvidedKey => 'Inserir chave';

  @override
  String get type => 'Tipo';

  @override
  String get issuer => 'Emissor';

  @override
  String get account => 'Conta';

  @override
  String get pin => 'Código PIN';

  @override
  String get period => 'Período (segundos)';

  @override
  String get counter => 'Contador';

  @override
  String get totp => 'TOTP (Baseado em tempo)';

  @override
  String get hotp => 'HOTP (Baseado em contador)';

  @override
  String get motp => 'mOTP (OTP Móvel)';

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
  String get selectIcon => 'Selecionar ícone';

  @override
  String get invalidSecret => 'Segredo inválido';

  @override
  String get dismiss => 'Fechar';

  @override
  String get invalidScheme => 'Esquema inválido';

  @override
  String get invalidType => 'Tipo inválido';

  @override
  String get issuerCannotBeEmpty => 'O emissor não pode estar vazio';

  @override
  String get accountCannotBeEmpty => 'A conta não pode estar vazia';

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
  String get invalidSecretKey => 'Chave secreta inválida';

  @override
  String get noData => 'Sem dados';

  @override
  String get search => 'Pesquisar';

  @override
  String get importWarning =>
      'Você está prestes a importar dados da área de transferência. Se as mesmas contas já existirem no banco de datos, elas serão sobrescritas. Deseja continuar?';

  @override
  String get exportFailed => 'Falha na exportação';

  @override
  String get noDataToExport => 'Não há dados disponíveis para exportar';

  @override
  String get exportWarning =>
      'Você está prestes a exportar todos os autenticadores para a área de transferência. O conteúdo exportado estará em formato de texto simples. Certifique-se de que seu ambiente é seguro e limpe a área de transferência depois. Deseja continuar?';
}
