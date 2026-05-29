// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/app/bloc/app_bloc.dart';
import '../../../../l10n/app_localizations.dart';

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
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainer,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar.medium(
            backgroundColor: colorScheme.primaryContainer,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            title: Text(l10n.settings),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList.list(
              children: const [
                _LanguageSection(),
                SizedBox(height: 16),
                _ThemeSection(),
                SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageSection extends StatelessWidget {
  const _LanguageSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocSelector<AppBloc, AppState, String>(
      selector: (state) => state.locale.languageCode,
      builder: (context, languageCode) {
        return _SettingsSection(
          title: l10n.language,
          icon: Icons.language_rounded,
          children: [
            _SettingsOptionTile(
              title: l10n.indonesian,
              selected: languageCode == 'id',
              onTap: () => _changeLanguage(context, 'id'),
            ),
            _SettingsOptionTile(
              title: l10n.english,
              selected: languageCode == 'en',
              onTap: () => _changeLanguage(context, 'en'),
            ),
          ],
        );
      },
    );
  }

  void _changeLanguage(BuildContext context, String languageCode) {
    context.read<AppBloc>().add(AppEvent.changeLanguage(languageCode));
  }
}

class _ThemeSection extends StatelessWidget {
  const _ThemeSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocSelector<AppBloc, AppState, ThemeMode>(
      selector: (state) => state.themeMode,
      builder: (context, themeMode) {
        return _SettingsSection(
          title: l10n.theme,
          icon: Icons.palette_outlined,
          children: [
            _SettingsOptionTile(
              title: l10n.systemTheme,
              selected: themeMode == ThemeMode.system,
              onTap: () => _changeTheme(context, ThemeMode.system),
            ),
            _SettingsOptionTile(
              title: l10n.lightTheme,
              selected: themeMode == ThemeMode.light,
              onTap: () => _changeTheme(context, ThemeMode.light),
            ),
            _SettingsOptionTile(
              title: l10n.darkTheme,
              selected: themeMode == ThemeMode.dark,
              onTap: () => _changeTheme(context, ThemeMode.dark),
            ),
          ],
        );
      },
    );
  }

  void _changeTheme(BuildContext context, ThemeMode themeMode) {
    context.read<AppBloc>().add(AppEvent.changeTheme(themeMode));
  }
}

class _SettingsOptionTile extends StatelessWidget {
  const _SettingsOptionTile({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      onTap: onTap,
      title: Text(title),
      trailing: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: selected
            ? Icon(
                Icons.check_circle_rounded,
                key: const ValueKey('selected'),
                color: colorScheme.primary,
              )
            : Icon(
                Icons.circle_outlined,
                key: const ValueKey('unselected'),
                color: colorScheme.outline,
              ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card.filled(
      color: colorScheme.surface,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Icon(icon, color: colorScheme.primary),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}
