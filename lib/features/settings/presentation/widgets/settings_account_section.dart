// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_router/app_router.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/widgets/app_sliver_group.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../sessions/presentation/bloc/session_bloc.dart';
import 'settings_card.dart';
import 'settings_menu_tile.dart';

/// Account-level settings, currently limited to the password reset flow.
///
/// The reset endpoints are keyed by NIS, so the section is only offered to a
/// student session — a parent signs in with a username instead.
class SettingsAccountSection extends StatelessWidget {
  const SettingsAccountSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return BlocSelector<SessionBloc, SessionState, bool>(
      selector: (state) => state.maybeWhen(
        authenticated: (_, role) => role == UserRole.student,
        orElse: () => false,
      ),
      builder: (context, isStudent) {
        if (!isStudent) return const SliverToBoxAdapter();

        return AppSliverGroup(
          title: l10n.account,
          titleStyle: textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: .bold,
          ),
          contentPadding: const .symmetric(horizontal: 16, vertical: 8),
          child: SettingsCard(
            padding: .zero,
            child: SettingsMenuTile(
              icon: Icons.lock_reset_rounded,
              iconBackgroundColor: colorScheme.primaryContainer,
              iconForegroundColor: colorScheme.onPrimaryContainer,
              title: l10n.changePassword,
              subtitle: l10n.changePasswordSubtitle,
              onTap: () => context.push(RouteNames.forgotPassword),
            ),
          ),
        );
      },
    );
  }
}
