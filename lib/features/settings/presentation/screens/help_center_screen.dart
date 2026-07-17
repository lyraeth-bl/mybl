// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/app_sliver_group.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/settings_card.dart';
import '../widgets/settings_menu_tile.dart';

enum _SocialPlatform { instagram, youtube, tiktok, website }

typedef _SocialAccount = ({
  _SocialPlatform platform,
  String handle,
  String url,
});

const List<_SocialAccount> _smaSocialAccounts = [
  (
    platform: .instagram,
    handle: '@budiluhursma',
    url: 'https://www.instagram.com/budiluhursma/',
  ),
  (
    platform: .youtube,
    handle: '@smabudiluhur4113',
    url: 'https://www.youtube.com/@smabudiluhur4113',
  ),
  (
    platform: .tiktok,
    handle: '@sma.budiluhur',
    url: 'https://www.tiktok.com/@sma.budiluhur',
  ),
  (
    platform: .website,
    handle: 'sma.sekolahbudiluhur.sch.id',
    url: 'https://sma.sekolahbudiluhur.sch.id/',
  ),
];

const List<_SocialAccount> _smkSocialAccounts = [
  (
    platform: .instagram,
    handle: '@smk.budiluhur',
    url: 'https://www.instagram.com/smk.budiluhur/',
  ),
  (
    platform: .youtube,
    handle: '@smkbudiluhurchannel4019',
    url: 'https://www.youtube.com/@smkbudiluhurchannel4019',
  ),
  (
    platform: .tiktok,
    handle: '@smk.budiluhur',
    url: 'https://www.tiktok.com/@smk.budiluhur',
  ),
  (
    platform: .website,
    handle: 'smk.sekolahbudiluhur.sch.id',
    url: 'https://smk.sekolahbudiluhur.sch.id/',
  ),
];

const String _smaEmail = 'sma@budiluhur.sch.id';
const String _smkEmail = 'smk@budiluhur.sch.id';
const String _schoolPhone = '+62217306247';
const String _schoolPhoneDisplay = '(021) - 730 6247';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _HelpCenterView();
  }
}

class _HelpCenterView extends StatelessWidget {
  const _HelpCenterView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      appBar: AppTopBar(toolbarHeight: 72, title: Text(l10n.helpCenter)),
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          const _FaqSection(),
          const _ContactSection(),
          _SocialMediaSection(
            title: l10n.socialMediaSma,
            accounts: _smaSocialAccounts,
          ),
          _SocialMediaSection(
            title: l10n.socialMediaSmk,
            accounts: _smkSocialAccounts,
          ),
          const _OfficeHoursSection(),
          SliverToBoxAdapter(child: 24.h),
        ],
      ),
    );
  }
}

class _HelpCenterSliverGroup extends StatelessWidget {
  const _HelpCenterSliverGroup({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppSliverGroup(
      title: title,
      titleStyle: textTheme.titleMedium?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: .bold,
      ),
      contentPadding: const .symmetric(horizontal: 16, vertical: 8),
      child: child,
    );
  }
}

class _FaqSection extends StatelessWidget {
  const _FaqSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = [
      (question: l10n.faqGradesQuestion, answer: l10n.faqGradesAnswer),
      (question: l10n.faqAttendanceQuestion, answer: l10n.faqAttendanceAnswer),
      (
        question: l10n.faqLanguageThemeQuestion,
        answer: l10n.faqLanguageThemeAnswer,
      ),
      (question: l10n.faqPasswordQuestion, answer: l10n.faqPasswordAnswer),
    ];

    return _HelpCenterSliverGroup(
      title: l10n.faqTitle,
      child: SettingsCard(
        padding: .zero,
        child: Column(
          children: [
            for (final item in items)
              _FaqTile(question: item.question, answer: item.answer),
          ],
        ),
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ExpansionTile(
      shape: const Border(),
      collapsedShape: const Border(),
      tilePadding: const .symmetric(horizontal: 16),
      childrenPadding: const .fromLTRB(16, 0, 16, 16),
      expandedCrossAxisAlignment: .start,
      iconColor: colorScheme.primary,
      collapsedIconColor: colorScheme.onSurfaceVariant,
      title: Text(
        question,
        style: textTheme.titleSmall?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: .w600,
        ),
      ),
      children: [
        Text(
          answer,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _ContactSection extends StatelessWidget {
  const _ContactSection();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return _HelpCenterSliverGroup(
      title: l10n.contactSchoolTitle,
      child: SettingsCard(
        padding: .zero,
        child: Column(
          children: [
            SettingsMenuTile(
              icon: Icons.call_outlined,
              iconBackgroundColor: colorScheme.primaryContainer,
              iconForegroundColor: colorScheme.onPrimaryContainer,
              title: l10n.contactPhone,
              subtitle: _schoolPhoneDisplay,
              onTap: () =>
                  _launch(context, Uri(scheme: 'tel', path: _schoolPhone)),
            ),
            SettingsMenuTile(
              icon: Icons.email_outlined,
              iconBackgroundColor: colorScheme.secondaryContainer,
              iconForegroundColor: colorScheme.onSecondaryContainer,
              title: '${l10n.contactEmail} SMA',
              subtitle: _smaEmail,
              onTap: () =>
                  _launch(context, Uri(scheme: 'mailto', path: _smaEmail)),
            ),
            SettingsMenuTile(
              icon: Icons.email_outlined,
              iconBackgroundColor: colorScheme.tertiaryContainer,
              iconForegroundColor: colorScheme.onTertiaryContainer,
              title: '${l10n.contactEmail} SMK',
              subtitle: _smkEmail,
              onTap: () =>
                  _launch(context, Uri(scheme: 'mailto', path: _smkEmail)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialMediaSection extends StatelessWidget {
  const _SocialMediaSection({required this.title, required this.accounts});

  final String title;
  final List<_SocialAccount> accounts;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return _HelpCenterSliverGroup(
      title: title,
      child: SettingsCard(
        padding: .zero,
        child: Column(
          children: [
            for (final account in accounts)
              SettingsMenuTile(
                icon: switch (account.platform) {
                  .instagram => Icons.photo_camera_outlined,
                  .youtube => Icons.smart_display_outlined,
                  .tiktok => Icons.music_note_outlined,
                  .website => Icons.language_outlined,
                },
                iconBackgroundColor: colorScheme.secondaryContainer,
                iconForegroundColor: colorScheme.onSecondaryContainer,
                title: switch (account.platform) {
                  .instagram => l10n.instagram,
                  .youtube => l10n.youtube,
                  .tiktok => l10n.tiktok,
                  .website => l10n.website,
                },
                subtitle: account.handle,
                onTap: () => _launch(context, Uri.parse(account.url)),
              ),
          ],
        ),
      ),
    );
  }
}

Future<void> _launch(BuildContext context, Uri uri) async {
  final l10n = AppLocalizations.of(context)!;
  final launched = await launchUrl(uri, mode: .externalApplication);

  if (!launched && context.mounted) {
    AppToast.error(context, l10n.contactOpenFailed);
  }
}

class _OfficeHoursSection extends StatelessWidget {
  const _OfficeHoursSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _HelpCenterSliverGroup(
      title: l10n.officeHoursTitle,
      child: SettingsCard(
        child: _OfficeHoursRow(
          day: l10n.officeHoursWeekdays,
          hours: '07.00–15.00',
        ),
      ),
    );
  }
}

class _OfficeHoursRow extends StatelessWidget {
  const _OfficeHoursRow({required this.day, required this.hours});

  final String day;
  final String hours;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(Icons.schedule_outlined, size: 20, color: colorScheme.primary),
        12.w,
        Expanded(
          child: Text(
            day,
            style: textTheme.titleSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: .w600,
            ),
          ),
        ),
        Text(
          hours,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
