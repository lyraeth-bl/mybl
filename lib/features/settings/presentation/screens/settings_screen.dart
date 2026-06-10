// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../../../core/widgets/app_top_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/settings_app_version_footer.dart';
import '../widgets/settings_notification_section.dart';
import '../widgets/settings_personalization_section.dart';
import '../widgets/settings_support_section.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SettingsView();
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(appBar: _SettingsAppBar(), body: _SettingsBody());
  }
}

@immutable
class _SettingsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _SettingsAppBar();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppTopBar(
      toolbarHeight: 72,
      title: Text(l10n.settings),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(80);
}

class _SettingsBody extends StatelessWidget {
  const _SettingsBody();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: const [
        SettingsNotificationSection(),
        SettingsPersonalizationSection(),
        SettingsSupportSection(),
        SettingsAppVersionFooter(),
      ],
    );
  }
}
