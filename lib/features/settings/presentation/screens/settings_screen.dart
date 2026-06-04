// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/app/bloc/app_bloc.dart';
import '../../../../core/widgets/app_container.dart';
import '../../../../core/widgets/app_sliver_group.dart';
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
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      appBar: const _SettingsAppBar(),
      body: const _SettingsBody(),
    );
  }
}

class _SettingsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _SettingsAppBar();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return AppBar(
      backgroundColor: colorScheme.primaryContainer,
      surfaceTintColor: colorScheme.primaryContainer,
      toolbarHeight: 72,
      title: Text(
        l10n.settings,
        style: const TextStyle(fontWeight: .bold, letterSpacing: 2),
      ),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          const _LanguageSection(),
          const _ThemeSection(),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
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
        duration: const Duration(milliseconds: 200),
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

    return AppSliverGroup(
      title: title,
      action: Icon(icon, color: colorScheme.primary),
      titleStyle: textTheme.titleMedium?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.bold,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      headerPadding: const EdgeInsetsDirectional.fromSTEB(16, 16, 32, 8),
      child: AppContainer(
        margin: EdgeInsets.zero,
        elevation: 0,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colorScheme.surfaceContainerHighest,
            offset: const Offset(5, 5),
          ),
        ],
        padding: const EdgeInsets.symmetric(vertical: 8),
        backgroundColor: colorScheme.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}
