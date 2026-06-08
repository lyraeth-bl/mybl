// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../../../core/widgets/app_container.dart';
import '../../../../core/widgets/app_profile_picture.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../user/domain/entities/student_entity/student_entity.dart';

class ProfileOverviewSection extends StatelessWidget {
  const ProfileOverviewSection({super.key, required this.student});

  final StudentEntity student;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final name = student.nama ?? l10n.emptyName;

    return SliverToBoxAdapter(
      child: AppContainer(
        backgroundColor: colorScheme.surfaceContainerLow,
        elevation: 0,
        borderRadius: BorderRadius.circular(16),
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
            const SizedBox(height: 24),
            Text(
              name,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: .bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${student.nis} / ${student.nisn ?? '-'}',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
