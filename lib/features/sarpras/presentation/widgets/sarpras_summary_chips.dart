// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/sarpras_summary/sarpras_summary.dart';

/// Which subset of requests the list is showing.
enum SarprasFilter { all, waiting, accepted, rejected }

extension SarprasFilterMatcher on SarprasFilter {
  /// Whether a request with [status] belongs in this filter.
  bool matches(String status) => switch (this) {
    SarprasFilter.all => true,
    SarprasFilter.waiting => status == 'Menunggu',
    SarprasFilter.accepted => status == 'Disetujui',
    SarprasFilter.rejected => status == 'Ditolak',
  };
}

/// A row of selectable status chips showing per-status counts.
class SarprasSummaryChips extends StatelessWidget {
  const SarprasSummaryChips({
    super.key,
    required this.summary,
    required this.selected,
    required this.onSelected,
  });

  final SarprasSummary summary;
  final SarprasFilter selected;
  final ValueChanged<SarprasFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final total = summary.waiting + summary.accepted + summary.rejected;

    final entries = <(SarprasFilter, String, int)>[
      (SarprasFilter.all, l10n.sarprasFilterAll, total),
      (SarprasFilter.waiting, l10n.sarprasStatusWaiting, summary.waiting),
      (SarprasFilter.accepted, l10n.sarprasStatusAccepted, summary.accepted),
      (SarprasFilter.rejected, l10n.sarprasStatusRejected, summary.rejected),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: entries
            .map(
              (entry) => FilterChip(
                label: Text('${entry.$2} (${entry.$3})'),
                selected: selected == entry.$1,
                onSelected: entry.$3 == 0 && entry.$1 != SarprasFilter.all
                    ? null
                    : (_) => onSelected(entry.$1),
              ),
            )
            .toList()
            .separatedBy(8.w),
      ),
    );
  }
}
