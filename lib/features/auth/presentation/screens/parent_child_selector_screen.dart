// lib/features/auth/presentation/screens/parent_child_selector_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_router/app_router.dart';
import '../../../user/domain/entities/child_entity/child_entity.dart';
import '../../../user/domain/entities/parent_entity/parent_entity.dart';
import '../../../user/presentation/bloc/parent_bloc/parent_bloc.dart';

String _toTitleCase(String text) => text
    .toLowerCase()
    .split(' ')
    .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : w)
    .join(' ');

class ParentChildSelectorScreen extends StatelessWidget {
  const ParentChildSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ParentBloc, ParentState>(
      builder: (context, state) => state.when(
        initial: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        active: (parent) => _ChildSelectorContent(parent: parent),
      ),
    );
  }
}

class _ChildSelectorContent extends StatelessWidget {
  const _ChildSelectorContent({required this.parent});

  final ParentEntity parent;

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat pagi';
    if (hour < 15) return 'Selamat siang';
    if (hour < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
                _greeting(),
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _toTitleCase(parent.nama),
                style: textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
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
                  const SizedBox(width: 10),
                  Text(
                    parent.children.length == 1
                        ? 'Data anak Anda'
                        : 'Pilih data anak yang ingin dipantau',
                    style: textTheme.titleSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // List
              Expanded(
                child: ListView.separated(
                  itemCount: parent.children.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final child = parent.children[index];
                    final isSelected = child.nis == parent.selectedChild.nis;
                    return _ChildCard(
                      child: child,
                      isSelected: isSelected,
                      onTap: () {
                        context.read<ParentBloc>().add(
                          ParentEvent.childSelected(child),
                        );
                        context.go(RouteNames.dashboard);
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
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
              // Avatar
              _ChildAvatar(child: child, isSelected: isSelected),
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
                          size: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          child.kelas,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.badge_outlined,
                          size: 13,
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
                duration: const Duration(milliseconds: 200),
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
    );
  }
}

class _ChildAvatar extends StatelessWidget {
  const _ChildAvatar({required this.child, required this.isSelected});

  final ChildEntity child;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
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
