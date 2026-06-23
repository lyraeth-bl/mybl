// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_router/app_router.dart';
import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_responsive_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/decorated_background.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _WelcomeView();
  }
}

class _WelcomeView extends StatefulWidget {
  const _WelcomeView();

  @override
  State<_WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<_WelcomeView> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Image.asset("assets/images/sekolah_budi_luhur.png", scale: 6),
        backgroundColor: colorScheme.primaryContainer,
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
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _WelcomeRoleSelectorSheet(),
  );
}

class _WelcomeRoleSelectorSheet extends StatelessWidget {
  const _WelcomeRoleSelectorSheet();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(l10n.loginAs, style: textTheme.titleLarge),
          ),
          8.h,
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.welcomeRoleSelectorDescription,
              style: textTheme.bodyMedium!.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          24.h,
          AppButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.push(RouteNames.authStudent);
            },
            child: Text(l10n.student),
          ),
          12.h,
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return DecoratedBackground(
      child: SafeArea(
        child: AppResponsiveContainer(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              crossAxisAlignment: .start,
              children: [
                const Spacer(),
                Text(
                  l10n.welcomePortalLabel,
                  style: textTheme.titleMedium!.copyWith(
                    color: colorScheme.onPrimaryContainer.withValues(alpha: .7),
                    letterSpacing: 1.1,
                  ),
                ),
                4.h,
                Text(
                  l10n.welcomeTitle,
                  style: textTheme.headlineLarge!.copyWith(
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                12.h,
                Text(
                  l10n.welcomeDescription,
                  style: textTheme.bodyMedium!.copyWith(
                    color: colorScheme.onPrimaryContainer.withValues(alpha: .7),
                  ),
                ),
                const Spacer(),
                AppButton(
                  onPressed: () => _showRoleSelector(context),
                  child: Text(l10n.welcomeGetStarted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
