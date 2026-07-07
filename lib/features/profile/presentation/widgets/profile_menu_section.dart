// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../../../core/internal/src/extensions/extensions.dart';
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
    final l10n = AppLocalizations.of(context)!;

    return SliverList.list(
      children: [
        Padding(
          padding: const .symmetric(horizontal: 16),
          child: ProfileCardMenu(
            title: l10n.personalInfo,
            subtitle: l10n.personalInfoDesc,
            icon: Icons.medical_information_outlined,
            onTap: onPersonalInfoTap,
          ),
        ),
        Padding(
          padding: .symmetric(horizontal: 16),
          child: LogoutButton(
            onPressed: onLogoutPressed,
            isLoading: isLogoutLoading,
          ),
        ),
      ].separatedBy(16.h),
    );
  }
}
