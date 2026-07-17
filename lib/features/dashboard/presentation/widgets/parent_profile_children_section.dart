// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/app_container.dart';
import '../../../../core/widgets/app_profile_picture.dart';
import '../../../../core/widgets/app_sliver_group.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../user/domain/entities/child_entity/child_entity.dart';

class ParentProfileChildrenSection extends StatelessWidget {
  const ParentProfileChildrenSection({
    super.key,
    required this.children,
    required this.selectedChild,
    required this.onChildSelected,
  });

  final List<ChildEntity> children;
  final ChildEntity? selectedChild;
  final void Function(ChildEntity child) onChildSelected;

  Future<void> _handleTap(BuildContext context, ChildEntity child) async {
    if (child.nis == selectedChild?.nis) return;

    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.parentProfileSwitchChildTitle),
        content: Text(
          l10n.parentProfileSwitchChildMessage(child.nama.capitalizeEveryWord),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );

    if (confirmed ?? false) onChildSelected(child);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return AppSliverGroup(
      title: l10n.parentProfileChildrenTitle,
      titleStyle: textTheme.titleMedium!.copyWith(color: colorScheme.onSurface),
      child: AppFramedContainer(
        margin: .zero,
        innerPadding: .zero,
        gap: .zero,
        child: children.isEmpty
            ? Padding(
                padding: const .symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  mainAxisSize: .min,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    Text(
                      l10n.noData,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ].separatedBy(8.w),
                ),
              )
            : Column(
                children: children
                    .map(
                      (child) => _ChildTile(
                        child: child,
                        isActive: child.nis == selectedChild?.nis,
                        onTap: () => _handleTap(context, child),
                      ),
                    )
                    .toList(),
              ),
      ),
    );
  }
}

class _ChildTile extends StatelessWidget {
  const _ChildTile({
    required this.child,
    required this.isActive,
    required this.onTap,
  });

  final ChildEntity child;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    return ListTile(
      onTap: onTap,
      leading: AppProfilePicture(
        backgroundColor: colorScheme.inverseSurface,
        foregroundColor: colorScheme.onInverseSurface,
        imageUrl: child.profileImageUrl,
        initials: AppProfilePicture.initialFrom(child.nama),
        radius: 24,
      ),
      title: Text(
        child.nama.capitalizeEveryWord,
        style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface),
      ),
      subtitle: Padding(
        padding: const .only(top: 8.0),
        child: Row(
          children: [
            Icon(
              Icons.school_outlined,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
            Text(child.kelas),
          ].separatedBy(4.w),
        ),
      ),
      trailing: isActive
          ? Icon(Icons.check_circle_rounded, color: colorScheme.primary)
          : null,
    );
  }
}
