import 'package:authentication/l10n/generated/app_localizations.dart';
import 'package:authentication/widgets/app_scaffold.dart';
import 'package:authentication/widgets/custom_app_bar.dart';
import 'package:authentication/widgets/glass_inputs.dart';
import 'package:authentication/widgets/glass_surface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppScaffold(
      largeTitle: true,
      appBar: CustomAppBar(title: l10n.aboutApp),
      body: AppPageList(
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
          AppGlassCard(
            padding: EdgeInsets.zero,
            child: GlassListTile(
              title: Text(l10n.openSourceLicenses),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const LicensesScreen()),
              ),
            ),
          ),
        ],
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
    return AppScaffold(
      largeTitle: true,
      appBar: CustomAppBar(title: l10n.userGuide),
      body: AppPageList(
        children: [
          for (final section in sections) ...[
            AppGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    section.body,
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
    return AppScaffold(
      largeTitle: true,
      appBar: CustomAppBar(title: l10n.migrationGuides),
      body: AppPageList(
        children: [
          Text(
            l10n.migrationGuideIntro,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          for (final guide in guides) ...[
            AppGlassCard(
              padding: EdgeInsets.zero,
              child: GlassDisclosureGroup(
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

final licensesProvider = FutureProvider.autoDispose<List<LicenseEntry>>(
  (ref) => LicenseRegistry.licenses.toList(),
);

class LicensesScreen extends ConsumerWidget {
  const LicensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return AppScaffold(
      largeTitle: true,
      appBar: CustomAppBar(title: l10n.openSourceLicenses),
      body: AppPageScrollView(
        slivers: [
          ref
              .watch(licensesProvider)
              .when(
                loading: () => const SliverFillRemaining(
                  child: Center(child: GlassProgressIndicator.circular()),
                ),
                error: (_, _) => SliverFillRemaining(
                  child: Center(
                    child: AppButton(
                      onPressed: () => ref.invalidate(licensesProvider),
                      child: Text(l10n.screenProtectionRetry),
                    ),
                  ),
                ),
                data: (entries) => SliverList.builder(
                  itemCount: entries.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: GlassDisclosureGroup.standalone(
                      surfaceStyle: GlassSurfaceStyle.solid,
                      title: Text(entries[index].packages.join(', ')),
                      childrenPadding: const EdgeInsets.all(16),
                      children: [
                        for (final paragraph in entries[index].paragraphs)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: SelectableText(paragraph.text),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
