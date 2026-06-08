// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../../../core/widgets/app_sliver_group.dart';
import '../../../../core/widgets/logout_button.dart';
import '../../../../l10n/app_localizations.dart';
import 'profile_card_menu.dart';

class ProfileMenuSection extends StatelessWidget {
  const ProfileMenuSection({
    super.key,
    required this.isLogoutLoading,
    required this.onPersonalInfoTap,
    required this.onLogoutPressed,
  });

  final bool isLogoutLoading;
  final VoidCallback onPersonalInfoTap;
  final VoidCallback onLogoutPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return AppSliverGroup(
      title: l10n.profile,
      titleStyle: textTheme.titleMedium?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.bold,
      ),
      headerPadding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 8),
      headerHeight: 48,
      titleOffset: 0,
      collapsedOpacity: 1,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: SliverList.list(
        children: [
          ProfileCardMenu(
            title: l10n.personalInfo,
            subtitle: l10n.personalInfoDesc,
            icon: Icons.medical_information_outlined,
            onTap: onPersonalInfoTap,
          ),
          const SizedBox(height: 16),
          LogoutButton(onPressed: onLogoutPressed, isLoading: isLogoutLoading),
        ],
      ),
    );
  }
}
