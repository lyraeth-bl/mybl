// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_router/app_router.dart';
import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/app_container.dart';
import '../../../../core/widgets/app_profile_picture.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../sessions/presentation/bloc/session_bloc.dart';
import '../../../user/presentation/bloc/parent_bloc/parent_bloc.dart';

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

    return BlocBuilder<ParentBloc, ParentState>(
      builder: (context, state) {
        final record = state.maybeWhen(
          ready: (parent, children, selectedChild) => (
            nama: parent.nama,
            child: selectedChild,
            hasMultipleChildren: children.length > 1,
          ),
          orElse: () => (nama: '', child: null, hasMultipleChildren: false),
        );

        return Scaffold(
          appBar: AppTopBar(
            toolbarHeight: 80,
            actions: [Icon(Icons.person)],
            centerTitle: false,
            title: Column(
              crossAxisAlignment: .start,
              children: [
                Row(
                  children: [
                    Icon(Icons.waving_hand, color: colorScheme.onSurface),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: .start,
                        children: [
                          Text(
                            _greeting(l10n),
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          BlocSelector<ParentBloc, ParentState, String>(
                            selector: (state) => state.maybeWhen(
                              ready: (parent, _, _) => parent.nama,
                              orElse: () => '',
                            ),
                            builder: (context, name) {
                              return Text(
                                l10n.parentGreetingName(
                                  name.capitalizeEveryWord,
                                ),
                                style: textTheme.titleMedium?.copyWith(
                                  color: colorScheme.onSurface,
                                ),
                              );
                            },
                          ),
                        ].separatedBy(2.h),
                      ),
                    ),
                  ].separatedBy(8.w),
                ),
              ],
            ),
          ),
          backgroundColor: colorScheme.surfaceContainer,
          body: SafeArea(
            child: BlocBuilder<ParentBloc, ParentState>(
              builder: (context, state) {
                return Padding(
                  padding: const .fromLTRB(16, 24, 16, 24),
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      if (record.child != null)
                        AppFramedContainer(
                          margin: .zero,
                          innerPadding: .zero,
                          gap: .zero,
                          innerColor: colorScheme.surface,
                          borderRadius: .circular(16),
                          innerBorderRadius: .circular(12),
                          title: Text(l10n.parentChildSelectorSingleChild),
                          titleTextStyle: textTheme.titleSmall!.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          trailing: Icon(
                            Icons.chevron_right,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          child: ListTile(
                            leading: AppProfilePicture(
                              backgroundColor: colorScheme.inverseSurface,
                              foregroundColor: colorScheme.onInverseSurface,
                              radius: 22,
                            ),
                            title: Text(
                              record.child!.nama.capitalizeEveryWord,
                              style: textTheme.titleMedium!.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const .only(top: 4.0),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.badge_outlined,
                                    size: 14,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  Text(record.child!.nis),
                                  Text("-"),
                                  Icon(
                                    Icons.school_outlined,
                                    size: 14,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  Text(record.child!.kelas),
                                ].separatedBy(4.w),
                              ),
                            ),
                          ),
                        ),
                      32.h,
                      AppFramedContainer(
                        onTap: () => {},
                        margin: .zero,
                        gap: .zero,
                        borderRadius: .circular(16),
                        innerBorderRadius: .circular(12),
                        innerColor: colorScheme.surface,
                        title: Text(l10n.dailyAttendance),
                        titleTextStyle: textTheme.titleSmall!.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        child: AppNoData(
                          title: l10n.noAttendanceData,
                          message: l10n.parentDailyAttendanceNoDataDesc(
                            record.child!.nama.takeFirstWordAndCapitalize,
                          ),
                          icon: Icons.calendar_today,
                          actionLabel: l10n.reload,
                          onAction: () => {},
                        ),
                      ),
                      const Spacer(),
                      if (record.hasMultipleChildren)
                        OutlinedButton(
                          onPressed: () =>
                              context.go(RouteNames.parentChildSelector),
                          child: Text(l10n.parentChildSelectorMultipleChildren),
                        ),
                      if (record.hasMultipleChildren) 12.h,
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
      },
    );
  }
}
