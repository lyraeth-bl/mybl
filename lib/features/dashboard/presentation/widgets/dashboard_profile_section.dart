// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/app_container.dart';
import '../../../../core/widgets/app_profile_picture.dart';
import '../../../../core/widgets/app_sliver_group.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../user/presentation/bloc/user_bloc.dart';

class DashboardProfileSection extends StatelessWidget {
  const DashboardProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return AppSliverGroup(
      title: _dashboardGreeting(l10n, DateTime.now()),
      titleStyle: textTheme.titleMedium!.copyWith(
        color: colorScheme.onSurface,
        fontWeight: .bold,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: AppContainer(
        backgroundColor: colorScheme.surfaceContainerLow,
        margin: EdgeInsets.zero,
        elevation: 0,
        borderRadius: BorderRadius.circular(16),
        child: BlocConsumer<UserBloc, UserState>(
          listener: (context, state) => state.whenOrNull(
            failure: (failure) =>
                AppToast.error(context, failure.localizedMessage(l10n)),
          ),
          builder: (context, state) {
            final isLoading = state.maybeWhen(
              loading: () => true,
              orElse: () => false,
            );

            final student = state.maybeWhen(
              success: (student) => student,
              orElse: () => null,
            );

            if (!isLoading && student == null) {
              return const SizedBox.shrink();
            }

            String normalizeClass() {
              if (student == null) return "";
              if (student.noKelasSaatIni == "1") {
                return student.kelasSaatIni!.replaceFirstMapped(
                  RegExp(r'^(XII|XI|X)'),
                  (match) => '${match.group(0)}',
                );
              }
              return l10n.classRoomValue(
                "${student.kelasSaatIni} ${student.noKelasSaatIni}",
              );
            }

            return Row(
              children: [
                AppProfilePicture(
                  imageUrl: student?.profileImageUrl,
                  initials: AppProfilePicture.initialFrom(
                    student?.nama ?? student?.namaPanggilan,
                  ),
                  side: BorderSide(color: colorScheme.outlineVariant, width: 2),
                ).toShimmer(
                  context,
                  isLoading: isLoading,
                  borderRadius: BorderRadius.circular(999),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student?.nama ?? student?.namaPanggilan ?? "",
                        style: textTheme.titleMedium!.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                      ).toShimmer(
                        context,
                        isLoading: isLoading,
                        width: 120,
                        height: 12,
                      ),

                      const SizedBox(height: 8),

                      Text(
                        normalizeClass(),
                        style: textTheme.labelMedium!.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ).toShimmer(
                        context,
                        isLoading: isLoading,
                        width: 80,
                        height: 12,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

String _dashboardGreeting(AppLocalizations l10n, DateTime now) {
  final hour = now.hour;

  if (hour < 11) return l10n.goodMorning;
  if (hour < 15) return l10n.goodAfternoon;
  if (hour < 18) return l10n.goodEvening;
  return l10n.goodNight;
}
