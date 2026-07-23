// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/app_container.dart';
import '../../domain/entities/sarpras/sarpras.dart';
import 'sarpras_status_badge.dart';

/// A single request row in the sarpras list.
class SarprasListItem extends StatelessWidget {
  const SarprasListItem({
    super.key,
    required this.sarpras,
    required this.onTap,
  });

  final Sarpras sarpras;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return AppFramedContainer(
      margin: .zero,
      gap: .zero,
      onTap: onTap,
      child: Row(
        crossAxisAlignment: .start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  sarpras.namaKegiatan,
                  style: textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${sarpras.tanggalKegiatan.toDayMonthYearFormat(context)}'
                  ' • ${sarpras.waktuKegiatan}',
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ].separatedBy(4.h),
            ),
          ),
          SarprasStatusBadge(status: sarpras.status),
        ].separatedBy(8.w),
      ),
    );
  }
}
