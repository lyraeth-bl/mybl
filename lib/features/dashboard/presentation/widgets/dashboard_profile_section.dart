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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;

    return AppSliverGroup(
      title: _dashboardGreeting(l10n, DateTime.now()),
      titleStyle: textTheme.titleMedium!.copyWith(color: colorScheme.onSurface),
      child: AppFramedContainer(
        gap: .zero,
        margin: .zero,
        elevation: 0,
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
                ).toShimmer(
                  context,
                  isLoading: isLoading,
                  borderRadius: .circular(24),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Text(
                        student?.nama?.capitalizeEveryWord ??
                            student?.namaPanggilan ??
                            "",
                        style: textTheme.titleMedium!.copyWith(
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 2,
                      ).toShimmer(
                        context,
                        isLoading: isLoading,
                        width: 160,
                        height: 16,
                        borderRadius: .circular(24),
                      ),
                      Text(
                        normalizeClass(),
                        style: textTheme.labelMedium!.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ).toShimmer(
                        context,
                        isLoading: isLoading,
                        width: 80,
                        height: 16,
                        borderRadius: .circular(24),
                      ),
                    ].separatedBy(8.h),
                  ),
                ),
              ].separatedBy(16.w),
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
