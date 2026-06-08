// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../../../core/widgets/app_container.dart';
import '../../../../core/widgets/app_icon_container.dart';

class ProfileCardMenu extends StatelessWidget {
  const ProfileCardMenu({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
    this.shape,
  });

  /// Judul utama yang bakal ditebelin tulisannya.
  final String title;

  /// Keterangan tambahan di bawah judul.
  final String subtitle;

  /// Icon yang muncul di sebelah kiri.
  final IconData icon;

  /// Bentuk pojokan kartunya, default-nya [RoundedRectangleBorder] dengan radius 24.
  final ShapeBorder? shape;

  /// Fungsi yang dipanggil pas kartu ini diklik.
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppContainer(
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.zero,
      backgroundColor: colorScheme.surfaceContainerLow,
      elevation: 0,
      shape:
          shape ??
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      borderRadius: null,
      onTap: onTap,
      child: ListTile(
        shape:
            shape ??
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: AppIconContainer(
          icon: icon,
          padding: const EdgeInsets.all(12),
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
