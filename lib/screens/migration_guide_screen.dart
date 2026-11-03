import 'package:authentication/l10n/generated/app_localizations.dart';
import 'package:authentication/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class MigrationGuideScreen extends StatelessWidget {
  const MigrationGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final guides = [
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
