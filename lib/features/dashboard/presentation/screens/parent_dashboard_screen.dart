// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_router/app_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../sessions/presentation/bloc/session_bloc.dart';
import '../../../user/presentation/bloc/parent_bloc/parent_bloc.dart';

/// Placeholder dashboard untuk parent. Sengaja kosong supaya parent tidak
/// menembak endpoint student-only (yang masih menolak token parent di BE).
/// Nantinya halaman ini diisi data anak yang dipilih.
class ParentDashboardScreen extends StatelessWidget {
  const ParentDashboardScreen({super.key});

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
        child: BlocBuilder<ParentBloc, ParentState>(
          builder: (context, state) {
            final record = state.maybeWhen(
              ready: (parent, children, selectedChild) => (
                nama: parent.nama,
                child: selectedChild,
                hasMultipleChildren: children.length > 1,
              ),
              orElse: () => (nama: '', child: null, hasMultipleChildren: false),
            );

            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _greeting(l10n),
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    record.nama,
                    style: textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 32),
                  if (record.child != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: colorScheme.outlineVariant),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            record.child!.nama,
                            style: textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${record.child!.kelas} · ${record.child!.nis}',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Spacer(),
                  if (record.hasMultipleChildren)
                    OutlinedButton(
                      onPressed: () =>
                          context.go(RouteNames.parentChildSelector),
                      child: Text(l10n.parentChildSelectorMultipleChildren),
                    ),
                  if (record.hasMultipleChildren) const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context.read<SessionBloc>().add(
                      const SessionEvent.loggedOut(),
                    ),
                    child: Text(l10n.logout),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
