// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_router/app_router.dart';
import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_responsive_container.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../l10n/app_localizations.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _WelcomeView();
  }
}

class _WelcomeView extends StatelessWidget {
  const _WelcomeView();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppTopBar(
        backgroundColor: colorScheme.primaryContainer,
        title: Image.asset("assets/images/sekolah_budi_luhur.png", scale: 4),
        centerTitle: false,
      ),
      body: const _WelcomeViewContent(),
    );
  }
}

void _showRoleSelector(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    useSafeArea: true,
    enableDrag: true,
    showDragHandle: true,
    builder: (_) => const _WelcomeRoleSelectorSheet(),
  );
}

class _WelcomeRoleSelectorSheet extends StatelessWidget {
  const _WelcomeRoleSelectorSheet();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        mainAxisSize: .min,
        children: [
          Align(
            alignment: .centerLeft,
            child: Text(l10n.loginAs, style: textTheme.titleLarge),
          ),
          8.h,
          Align(
            alignment: .centerLeft,
            child: Text(
              l10n.welcomeRoleSelectorDescription,
              style: textTheme.bodyMedium!.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          24.h,
          AppButton.outlined(
            onPressed: () {
              Navigator.of(context).pop();
              context.push(RouteNames.authStudent);
            },
            child: Text(l10n.student),
          ),
          16.h,
          AppButton.outlined(
            onPressed: () {
              Navigator.of(context).pop();
              context.push(RouteNames.authParent);
            },
            child: Text(l10n.parent),
          ),
        ],
      ),
    );
  }
}

class _WelcomeViewContent extends StatelessWidget {
  const _WelcomeViewContent();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return ColoredBox(
      color: colorScheme.primaryContainer,
      child: AppResponsiveContainer(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              crossAxisAlignment: .start,
              children: [
                const Spacer(),
                Text(
                  l10n.welcomePortalLabel,
                  style: textTheme.titleMedium!.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    letterSpacing: 1.1,
                  ),
                ).makeAnimate(delay: 100.ms),
                8.h,
                Text(
                  l10n.welcomeTitle,
                  style: textTheme.headlineLarge!.copyWith(
                    color: colorScheme.onPrimaryContainer,
                  ),
                ).makeAnimate(delay: 180.ms),
                16.h,
                Text(
                  l10n.welcomeDescription,
                  style: textTheme.bodyMedium!.copyWith(
                    color: colorScheme.onPrimaryContainer,
                  ),
                ).makeAnimate(delay: 260.ms),
                const Spacer(),
                AppButton(
                  onPressed: () => _showRoleSelector(context),
                  child: Text(l10n.welcomeGetStarted),
                ).makeAnimate(delay: 360.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
