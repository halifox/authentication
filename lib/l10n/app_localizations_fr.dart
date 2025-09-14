// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Purity Auth';

  @override
  String get add => 'Ajouter';

  @override
  String get scan => 'Scanner';

  @override
  String get settings => 'Paramètres';

  @override
  String get scanQRCode => 'Scanner le QR code';

  @override
  String get secret => 'Secret';

  @override
  String get algorithm => 'Algorithme';

  @override
  String get digits => 'Chiffres';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get edit => 'Modifier';

  @override
  String get ok => 'OK';

  @override
  String get codeCopied => 'Code copié';

  @override
  String get tip => 'Astuce';

  @override
  String get warning => 'Avertissement';

  @override
  String get importFailed => 'Échec de l\'importation';

  @override
  String get importSuccess => 'Importation réussie';

  @override
  String get exportSuccess => 'Exportation réussie';

  @override
  String get addSuccess => 'Ajout réussi';

  @override
  String get updateSuccess => 'Mise à jour réussie';

  @override
  String get saveFailed => 'Échec de la sauvegarde';

  @override
  String get platformNotSupported =>
      'Cette fonctionnalité n\'est actuellement prise en charge que sur les plateformes Android et iOS.';

  @override
  String get cannotGetClipboardData =>
      'Impossible de récupérer les données du presse-papiers';

  @override
  String importedCount(int count) {
    return '$count éléments importés depuis le presse-papiers';
  }

  @override
  String exportedCount(int count) {
    return '$count éléments exportés vers le presse-papiers';
  }

  @override
  String get unsupportedQRCode =>
      'Ce type de QR code n\'est pas pris en charge';

  @override
  String tokenExists(String issuer, String account) {
    return 'Le jeton $issuer:$account existe déjà. Voulez-vous l\'écraser ?';
  }

  @override
  String get deleteWarning =>
      'Vous êtes sur le point de supprimer l\'authentificateur à deux facteurs actuel.\nCette action vous empêchera d\'utiliser cet authentificateur pour l\'authentification.\nVeuillez vous assurer que vous avez d\'autres méthodes d\'authentification prêtes pour assurer la sécurité de votre compte.';

  @override
  String get uploadQRCode => 'Importer QR code';

  @override
  String get enterKey => 'Entrer la clé';

  @override
  String get importFromClipboard => 'Importer depuis le presse-papiers';

  @override
  String get exportToClipboard => 'Exporter vers le presse-papiers';

  @override
  String get enterProvidedKey => 'Entrer la clé';

  @override
  String get type => 'Type';

  @override
  String get issuer => 'Émetteur';

  @override
  String get account => 'Compte';

  @override
  String get pin => 'Code PIN';

  @override
  String get period => 'Période (secondes)';

  @override
  String get counter => 'Compteur';

  @override
  String get totp => 'TOTP (Basé sur le temps)';

  @override
  String get hotp => 'HOTP (Basé sur un compteur)';

  @override
  String get motp => 'mOTP (OTP Mobile)';

  @override
  String get showCaptchaOnTap => 'Appuyer pour afficher';

  @override
  String get copyCaptchaOnTap => 'Appuyer pour copier';

  @override
  String get sha1 => 'SHA1';

  @override
  String get sha256 => 'SHA256';

  @override
  String get sha512 => 'SHA512';

  @override
  String get selectIcon => 'Sélectionner une icône';

  @override
  String get invalidSecret => 'Secret invalide';

  @override
  String get dismiss => 'Fermer';

  @override
  String get invalidScheme => 'Schéma invalide';

  @override
  String get invalidType => 'Type invalide';

  @override
  String get issuerCannotBeEmpty => 'L\'émetteur ne peut pas être vide';

  @override
  String get accountCannotBeEmpty => 'Le compte ne peut pas être vide';

  @override
  String get invalidAlgorithm => 'Algorithme invalide';

  @override
  String get invalidDigits => 'Nombre de chiffres invalide';

  @override
  String get invalidPeriod => 'Période invalide';

  @override
  String get invalidCounter => 'Compteur invalide';

  @override
  String get invalidPin => 'Code PIN invalide';

  @override
  String get invalidSecretKey => 'Clé secrète invalide';
}
