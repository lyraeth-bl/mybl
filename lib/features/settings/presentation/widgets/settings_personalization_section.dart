// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/app/bloc/app_bloc.dart';
import '../../../../core/widgets/app_sliver_group.dart';
import '../../../../l10n/app_localizations.dart';
import 'settings_card.dart';

class SettingsPersonalizationSection extends StatelessWidget {
  const SettingsPersonalizationSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return AppSliverGroup(
      title: l10n.personalization,
      titleStyle: textTheme.titleMedium?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.bold,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: const SettingsCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ThemeSelector(),
            Divider(height: 28),
            _LanguageSelector(),
          ],
        ),
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocSelector<AppBloc, AppState, ThemeMode>(
      selector: (state) => state.themeMode,
      builder: (context, themeMode) {
        return _SettingsControlGroup(
          icon: Icons.palette_outlined,
          title: l10n.appTheme,
          child: Row(
            children: [
              Expanded(
                child: _ThemeOptionButton(
                  icon: Icons.light_mode_outlined,
                  label: l10n.lightTheme,
                  selected: themeMode == ThemeMode.light,
                  onTap: () => _changeTheme(context, ThemeMode.light),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ThemeOptionButton(
                  icon: Icons.dark_mode_outlined,
                  label: l10n.darkTheme,
                  selected: themeMode == ThemeMode.dark,
                  onTap: () => _changeTheme(context, ThemeMode.dark),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ThemeOptionButton(
                  icon: Icons.settings_system_daydream_outlined,
                  label: l10n.systemTheme,
                  selected: themeMode == ThemeMode.system,
                  onTap: () => _changeTheme(context, ThemeMode.system),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _changeTheme(BuildContext context, ThemeMode themeMode) {
    context.read<AppBloc>().add(AppEvent.changeTheme(themeMode));
  }
}

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocSelector<AppBloc, AppState, String>(
      selector: (state) => state.locale.languageCode,
      builder: (context, languageCode) {
        return Row(
          children: [
            Expanded(
              child: _SettingsControlLabel(
                icon: Icons.language_rounded,
                title: l10n.language,
              ),
            ),
            const SizedBox(width: 12),
            _LanguageSegmentedControl(
              languageCode: languageCode,
              onChanged: (value) => _changeLanguage(context, value),
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

class _SettingsControlGroup extends StatelessWidget {
  const _SettingsControlGroup({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SettingsControlLabel(icon: icon, title: title),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _SettingsControlLabel extends StatelessWidget {
  const _SettingsControlLabel({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _ThemeOptionButton extends StatelessWidget {
  const _ThemeOptionButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final backgroundColor = selected
        ? colorScheme.primary
        : colorScheme.surfaceContainerHighest;
    final foregroundColor = selected
        ? colorScheme.onPrimary
        : colorScheme.onSurfaceVariant;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 72,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: foregroundColor),
              const SizedBox(height: 8),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelSmall?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageSegmentedControl extends StatelessWidget {
  const _LanguageSegmentedControl({
    required this.languageCode,
    required this.onChanged,
  });

  final String languageCode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SegmentedButton<String>(
      showSelectedIcon: false,
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.surfaceContainerHighest;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.onPrimary;
          }
          return colorScheme.onSurfaceVariant;
        }),
        side: WidgetStateProperty.all(BorderSide.none),
      ),
      segments: const [
        ButtonSegment(value: 'id', label: Text('Indo')),
        ButtonSegment(value: 'en', label: Text('Eng')),
      ],
      selected: {languageCode},
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}
