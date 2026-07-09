// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/app_container.dart';
import '../../../../core/widgets/app_profile_picture.dart';
import '../../../user/domain/entities/parent_entity/parent_entity.dart';

class ParentProfileOverviewSection extends StatelessWidget {
  const ParentProfileOverviewSection({super.key, required this.parent});

  final ParentEntity parent;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    return SliverToBoxAdapter(
      child: Column(
        children: [
          16.h,
          AppFramedContainer(
            gap: .zero,
            elevation: 0,
            child: Column(
              children: [
                AppProfilePicture(
                  backgroundColor: colorScheme.primaryContainer,
                  foregroundColor: colorScheme.onPrimaryContainer,
                  initials: AppProfilePicture.initialFrom(parent.nama),
                  radius: 48,
                ),
                24.h,
                Text(
                  parent.nama.capitalizeEveryWord,
                  textAlign: .center,
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                8.h,
                Text(
                  parent.username,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                4.h,
                Text(
                  parent.telpon,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
