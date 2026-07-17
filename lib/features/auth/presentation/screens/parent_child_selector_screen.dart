// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

// lib/features/auth/presentation/screens/parent_child_selector_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_router/app_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../user/domain/entities/child_entity/child_entity.dart';
import '../../../user/domain/entities/parent_entity/parent_entity.dart';
import '../../../user/presentation/bloc/parent_bloc/parent_bloc.dart';

String _toTitleCase(String text) => text
    .toLowerCase()
    .split(' ')
    .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : w)
    .join(' ');

class ParentChildSelectorScreen extends StatefulWidget {
  const ParentChildSelectorScreen({super.key});

  @override
  State<ParentChildSelectorScreen> createState() =>
      _ParentChildSelectorScreenState();
}

class _ParentChildSelectorScreenState extends State<ParentChildSelectorScreen> {
  @override
  void initState() {
    super.initState();
    // Hidrasi konteks parent saat restart. Kalau sudah ter-hidrasi lewat
    // login (state bukan initial), tidak perlu fetch ulang.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isInitial = context.read<ParentBloc>().state.maybeWhen(
        initial: () => true,
        orElse: () => false,
      );
      if (isInitial) {
        context.read<ParentBloc>().add(const ParentEvent.started());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ParentBloc, ParentState>(
      builder: (context, state) => state.maybeWhen(
        ready: (parent, children, selectedChild) => _ChildSelectorContent(
          parent: parent,
          children: children,
          selectedChild: selectedChild,
        ),
        failure: (_) => const _ChildSelectorError(),
        orElse: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
    );
  }
}

class _ChildSelectorContent extends StatelessWidget {
  const _ChildSelectorContent({
    required this.parent,
    required this.children,
    required this.selectedChild,
  });

  final ParentEntity parent;
  final List<ChildEntity> children;
  final ChildEntity? selectedChild;

  String _greeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 11) return l10n.goodMorning;
    if (hour < 15) return l10n.goodAfternoon;
    if (hour < 18) return l10n.goodEvening;
    return l10n.goodNight;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                _greeting(l10n),
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _toTitleCase(parent.nama),
                style: textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 32),

              // Section label
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    children.length == 1
                        ? l10n.parentChildSelectorSingleChild
                        : l10n.parentChildSelectorMultipleChildren,
                    style: textTheme.titleSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              if (children.isEmpty)
                Expanded(child: _EmptyChildrenState())
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: children.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final child = children[index];
                      final isSelected = child.nis == selectedChild?.nis;
                      return _ChildCard(
                        child: child,
                        isSelected: isSelected,
                        onTap: () {
                          context.read<ParentBloc>().add(
                            ParentEvent.childSelected(child),
                          );
                          context.go(RouteNames.parentDashboard);
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyChildrenState extends StatelessWidget {
  const _EmptyChildrenState();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.child_care_outlined,
            size: 48,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.parentChildSelectorNoChildren,
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.parentChildSelectorNoChildrenDesc,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ChildSelectorError extends StatelessWidget {
  const _ChildSelectorError();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.dioUnexpectedError,
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => context.read<ParentBloc>().add(
                    const ParentEvent.started(forceRefresh: true),
                  ),
                  child: Text(l10n.tryAgain),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChildCard extends StatelessWidget {
  const _ChildCard({
    required this.child,
    required this.isSelected,
    required this.onTap,
  });

  final ChildEntity child;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final animDuration = MediaQuery.of(context).disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: 200);

    return Semantics(
      label: l10n.parentChildSelectorSelectLabel(
        _toTitleCase(child.nama),
        child.kelas,
      ),
      button: true,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: animDuration,
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: isSelected
                  ? colorScheme.primaryContainer
                  : colorScheme.surfaceContainerLow,
              border: Border.all(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.outlineVariant,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                _ChildAvatar(
                  child: child,
                  isSelected: isSelected,
                  animDuration: animDuration,
                ),
                const SizedBox(width: 16),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _toTitleCase(child.nama),
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.class_outlined,
                            size: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            child.kelas,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.badge_outlined,
                            size: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            child.nis,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Trailing
                AnimatedSwitcher(
                  duration: animDuration,
                  child: isSelected
                      ? Icon(
                          Icons.check_circle_rounded,
                          key: const ValueKey('selected'),
                          color: colorScheme.primary,
                          size: 24,
                        )
                      : Icon(
                          Icons.chevron_right_rounded,
                          key: const ValueKey('unselected'),
                          color: colorScheme.onSurfaceVariant,
                          size: 24,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChildAvatar extends StatelessWidget {
  const _ChildAvatar({
    required this.child,
    required this.isSelected,
    required this.animDuration,
  });

  final ChildEntity child;
  final bool isSelected;
  final Duration animDuration;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AnimatedContainer(
      duration: animDuration,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: CircleAvatar(
        radius: 28,
        backgroundColor: isSelected
            ? colorScheme.primary
            : colorScheme.surfaceContainerHighest,
        backgroundImage: child.profileImageUrl != null
            ? NetworkImage(child.profileImageUrl!)
            : null,
        child: child.profileImageUrl == null
            ? Text(
                child.nama.isNotEmpty ? child.nama[0].toUpperCase() : '?',
                style: textTheme.titleLarge?.copyWith(
                  color: isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
    );
  }
}
