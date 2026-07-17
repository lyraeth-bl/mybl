// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/app_container.dart';
import '../../../../core/widgets/app_profile_picture.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../user/domain/entities/student_entity/student_entity.dart';

class ProfileOverviewSection extends StatelessWidget {
  const ProfileOverviewSection({super.key, required this.student});

  final StudentEntity student;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final String name = student.nama ?? l10n.emptyName;

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
                  imageUrl: student.profileImageUrl,
                  initials: AppProfilePicture.initialFrom(
                    student.nama ?? student.namaPanggilan,
                  ),
                  radius: 48,
                ),
                24.h,
                Text(
                  name.capitalizeEveryWord,
                  textAlign: .center,
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                8.h,
                Text(
                  '${student.nis} / ${student.nisn ?? '-'}',
                  textAlign: .center,
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
