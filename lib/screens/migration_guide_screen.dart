import 'package:authentication/l10n/generated/app_localizations.dart';
import 'package:authentication/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: CustomAppBar(title: l10n.aboutApp),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Text(
            l10n.aboutDescription,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Text(l10n.aboutPrivacy, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 24),
          Text(l10n.sourceCode, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const SelectableText('https://github.com/halifox/authentication'),
          const SizedBox(height: 24),
          Material(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(24),
            child: ListTile(
              title: Text(l10n.openSourceLicenses),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showLicensePage(
                context: context,
                applicationName: 'Authentication',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class IntroductionScreen extends StatelessWidget {
  const IntroductionScreen({
    required this.saving,
    required this.onContinue,
    super.key,
  });

  final bool saving;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: CustomAppBar(title: l10n.welcomeTitle),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              l10n.welcomeIntro,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            for (final section in [
              (l10n.guideAddTitle, l10n.guideAddBody),
              (l10n.guideBackupTitle, l10n.guideBackupBody),
              (l10n.guideMigrationTitle, l10n.guideMigrationBody),
            ]) ...[
              Text(section.$1, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(section.$2, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 24),
            ],
            FilledButton(
              onPressed: saving ? null : onContinue,
              child: Text(l10n.getStarted),
            ),
          ],
        ),
      ),
    );
  }
}

class UserGuideScreen extends StatelessWidget {
  const UserGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sections = [
      (title: l10n.guideAddTitle, body: l10n.guideAddBody),
      (title: l10n.guideCodesTitle, body: l10n.guideCodesBody),
      (title: l10n.guideBackupTitle, body: l10n.guideBackupBody),
      (title: l10n.guideMigrationTitle, body: l10n.guideMigrationBody),
    ];
    return Scaffold(
      appBar: CustomAppBar(title: l10n.userGuide),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        itemCount: sections.length,
        separatorBuilder: (_, _) => const SizedBox(height: 16),
        itemBuilder: (context, index) => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sections[index].title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                sections[index].body,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MigrationGuideScreen extends StatelessWidget {
  const MigrationGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final guides = [
      (title: 'Google Authenticator', body: l10n.googleGuide),
      (title: 'Authy', body: l10n.authyGuide),
      (title: 'Steam', body: l10n.steamGuide),
      (title: 'Blizzard', body: l10n.blizzardGuide),
    ];
    return Scaffold(
      appBar: CustomAppBar(title: l10n.migrationGuides),
      body: ListView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Text(
            l10n.migrationGuideIntro,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          for (final guide in guides) ...[
            Material(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(24),
              clipBehavior: Clip.antiAlias,
              child: ExpansionTile(
                title: Text(guide.title),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  SelectableText(
                    guide.body,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}
