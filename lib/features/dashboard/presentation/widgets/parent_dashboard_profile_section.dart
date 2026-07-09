// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/app_chip_container.dart';
import '../../../../core/widgets/app_container.dart';
import '../../../../core/widgets/app_profile_picture.dart';
import '../../../../core/widgets/app_sliver_group.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../user/domain/entities/child_entity/child_entity.dart';

class ParentDashboardProfileSection extends StatelessWidget {
  const ParentDashboardProfileSection({
    super.key,
    this.children,
    this.isLoading = false,
  });

  final List<ChildEntity>? children;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final String locale = Localizations.localeOf(context).toString();

    return AppSliverGroup(
      title: l10n.parentDashboardProfileTitle,
      titleStyle: textTheme.titleMedium!.copyWith(color: colorScheme.onSurface),
      action: AppChipContainer.outlined(
        value: DateFormat.yMMMMEEEEd(locale).format(DateTime.now()),
      ),
      child: AppFramedContainer(
        margin: .zero,
        innerPadding: .zero,
        gap: .zero,
        child: isLoading
            ? _ChildrenDetailSkeleton(isLoading: isLoading)
            : (children == null || children!.isEmpty)
            ? _ChildrenEmptyState(l10n: l10n)
            : Column(
                children: children!
                    .map(
                      (child) => _ChildrenDetail(
                        classRoom: child.kelas,
                        name: child.nama.capitalizeEveryWord,
                        nis: child.nis,
                      ),
                    )
                    .toList(),
              ),
      ),
    );
  }
}

class _ChildrenEmptyState extends StatelessWidget {
  const _ChildrenEmptyState({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Icon(
            Icons.people_outline,
            size: 16,
            color: colorScheme.onSurfaceVariant,
          ),
          8.w,
          Text(
            l10n.noData,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChildrenDetailSkeleton extends StatelessWidget {
  const _ChildrenDetailSkeleton({required this.isLoading});

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading:
          AppProfilePicture(
            backgroundColor: colorScheme.inverseSurface,
            foregroundColor: colorScheme.onInverseSurface,
            radius: 24,
          ).toShimmer(
            context,
            isLoading: isLoading,
            width: 48,
            height: 48,
            borderRadius: .circular(24),
          ),
      title: Align(
        alignment: .centerLeft,
        child: Text("").toShimmer(
          context,
          isLoading: isLoading,
          width: 200,
          height: 16,
          borderRadius: .circular(24),
        ),
      ),
      subtitle: Padding(
        padding: const .only(top: 8.0),
        child: Align(
          alignment: .centerLeft,
          child: Text("").toShimmer(
            context,
            isLoading: isLoading,
            width: 120,
            height: 16,
            borderRadius: .circular(24),
          ),
        ),
      ),
    );
  }
}

class _ChildrenDetail extends StatelessWidget {
  const _ChildrenDetail({
    required this.name,
    required this.nis,
    required this.classRoom,
  });

  final String name;
  final String nis;
  final String classRoom;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    return ListTile(
      leading: AppProfilePicture(
        backgroundColor: colorScheme.inverseSurface,
        foregroundColor: colorScheme.onInverseSurface,
        radius: 24,
      ),
      title: Text(
        name,
        style: textTheme.titleMedium!.copyWith(color: colorScheme.onSurface),
      ),
      subtitle: Padding(
        padding: const .only(top: 8.0),
        child: Row(
          children: [
            Icon(
              Icons.badge_outlined,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
            Text(nis),
            Text('-'),
            Icon(
              Icons.school_outlined,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
            Text(classRoom),
          ].separatedBy(4.w),
        ),
      ),
    );
  }
}
