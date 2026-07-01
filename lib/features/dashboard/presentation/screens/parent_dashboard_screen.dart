// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/app_container.dart';
import '../../../../core/widgets/app_profile_picture.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../user/domain/entities/child_entity/child_entity.dart';
import '../../../user/presentation/bloc/parent_bloc/parent_bloc.dart';

class ParentDashboardScreen extends StatelessWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<ParentBloc, ParentState>(
      builder: (context, state) {
        final record = state.maybeWhen(
          ready: (parent, children, selectedChild) => (
            nama: parent.nama,
            child: selectedChild,
            hasMultipleChildren: children.length > 1,
            children: children,
          ),
          orElse: () => (
            nama: '',
            child: null,
            hasMultipleChildren: false,
            children: <ChildEntity>[],
          ),
        );

        return Scaffold(
          appBar: const _ParentDashboardAppTopBar(),
          backgroundColor: colorScheme.surfaceContainer,
          body: _ParentDashboardBody(
            childEntity: record.child,
            children: record.children,
          ),
        );
      },
    );
  }
}

class _ParentDashboardAppTopBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _ParentDashboardAppTopBar();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return AppTopBar(
      backgroundColor: colorScheme.surfaceContainerLow,
      toolbarHeight: 80,
      centerTitle: false,
      title: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              _WavingHands(colorScheme: colorScheme),
              _GreetingAndName(
                colorScheme: colorScheme,
                l10n: l10n,
                textTheme: textTheme,
              ),
            ].separatedBy(8.w),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}

class _ParentDashboardBody extends StatelessWidget {
  const _ParentDashboardBody({this.childEntity, this.children});

  final List<ChildEntity>? children;
  final ChildEntity? childEntity;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: BlocBuilder<ParentBloc, ParentState>(
        builder: (context, state) {
          return Padding(
            padding: const .fromLTRB(16, 24, 16, 24),
            child: Column(
              crossAxisAlignment: .start,
              children: [
                if (children != null && children!.isNotEmpty)
                  _DashboardOutlineCard(
                    onTap: () => {},
                    title: Text(
                      children!.length > 1
                          ? l10n.parentChildSelectorMultipleChildren
                          : l10n.parentChildSelectorSingleChild,
                    ),
                    child: Column(
                      children: children!
                          .map(
                            (child) => _ChildrenDetail(
                              classRoom: child.kelas,
                              name: child.nama.capitalizeEveryWord,
                              nis: child.nis,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                24.h,
                _DashboardOutlineCard(
                  onTap: () => {},
                  innerPadding: .all(16),
                  title: Text(l10n.dailyAttendance),
                  child: AppNoData(
                    title: l10n.noAttendanceData,
                    message: l10n.parentDailyAttendanceNoDataDesc(
                      childEntity!.nama.takeFirstWordAndCapitalize,
                    ),
                    icon: Icons.calendar_today,
                    actionLabel: l10n.reload,
                    onAction: () => {},
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DashboardOutlineCard extends StatelessWidget {
  const _DashboardOutlineCard({
    this.onTap,
    this.innerPadding,
    required this.title,
    required this.child,
  });

  final EdgeInsetsGeometry? innerPadding;
  final VoidCallback? onTap;
  final Widget title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppFramedContainer(
      onTap: onTap,
      margin: .zero,
      innerPadding: innerPadding ?? .zero,
      gap: .zero,
      innerColor: colorScheme.surface,
      borderRadius: .circular(16),
      innerBorderRadius: .circular(12),
      title: title,
      trailing: Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
      child: child,
    );
  }
}

class _WavingHands extends StatelessWidget {
  const _WavingHands({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.waving_hand, color: colorScheme.onSurface)
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .rotate(begin: -0.1, end: 0.05, duration: 3.seconds);
  }
}

class _GreetingAndName extends StatelessWidget {
  const _GreetingAndName({
    required this.colorScheme,
    required this.l10n,
    required this.textTheme,
  });

  final AppLocalizations l10n;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  String _greeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 11) return l10n.goodMorning;
    if (hour < 15) return l10n.goodAfternoon;
    if (hour < 18) return l10n.goodEvening;
    return l10n.goodNight;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
                l10n.parentGreetingName(name.capitalizeEveryWord),
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              );
            },
          ),
        ].separatedBy(2.h),
      ),
    );
  }
}

class _ChildrenDetail extends StatelessWidget {
  const _ChildrenDetail({
    required this.name,
    required this.nis,
    required this.classRoom,
  });

  final String name;
  final String nis;
  final String classRoom;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      leading: AppProfilePicture(
        backgroundColor: colorScheme.inverseSurface,
        foregroundColor: colorScheme.onInverseSurface,
        radius: 22,
      ),
      title: Text(
        name,
        style: textTheme.titleMedium!.copyWith(color: colorScheme.onSurface),
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
            Text(nis),
            Text("-"),
            Icon(
              Icons.school_outlined,
              size: 14,
              color: colorScheme.onSurfaceVariant,
            ),
            Text(classRoom),
          ].separatedBy(4.w),
        ),
      ),
    );
  }
}
