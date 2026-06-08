// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/get_it_constant.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/refresh_wrapper.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/app_notification/app_notification.dart';
import '../bloc/notification_bloc.dart';
import '../widgets/notification_header.dart';
import '../widgets/notification_helpers.dart';
import '../widgets/notification_list_section.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NotificationBloc>(
      create: (context) => di<NotificationBloc>(),
      child: const _NotificationView(),
    );
  }
}

class _NotificationView extends StatefulWidget {
  const _NotificationView();

  @override
  State<_NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<_NotificationView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<NotificationBloc>().add(
        const NotificationEvent.fetchNotificationsRequested(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const _NotificationFailureListener(
      child: Scaffold(appBar: _NotificationAppBar(), body: _NotificationBody()),
    );
  }
}

@immutable
class _NotificationAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _NotificationAppBar();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppTopBar(
      toolbarHeight: 72,
      title: Text(l10n.notifications),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(80);
}

class _NotificationFailureListener extends StatelessWidget {
  const _NotificationFailureListener({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<NotificationBloc, NotificationState>(
      listenWhen: (previous, current) =>
          current.maybeWhen(failure: (_) => true, orElse: () => false),
      listener: (context, state) {
        final failure = state.whenOrNull(failure: (failure) => failure);
        if (failure == null) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.localizedMessage(l10n))));
      },
      child: child,
    );
  }
}

class _NotificationRefreshWrapper extends StatelessWidget {
  const _NotificationRefreshWrapper({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RefreshWrapper(
      onRefresh: () {
        return blocRefresh<
          NotificationBloc,
          NotificationEvent,
          NotificationState
        >(
          context: context,
          event: const NotificationEvent.fetchNotificationsRequested(),
          isDone: (state) => state.maybeWhen(
            success: (_) => true,
            failure: (_) => true,
            orElse: () => false,
          ),
        );
      },
      child: child,
    );
  }
}

class _NotificationBody extends StatelessWidget {
  const _NotificationBody();

  @override
  Widget build(BuildContext context) {
    return _NotificationRefreshWrapper(
      child: BlocBuilder<NotificationBloc, NotificationState>(
        buildWhen: _notificationBuildWhen,
        builder: (context, state) {
          final notifications = notificationsFromState(state);
          final groups = groupNotifications(context, notifications);

          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              if (groups.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: NotificationEmptyState(),
                )
              else ...[
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                for (final group in groups)
                  NotificationSliverGroup(
                    group: group,
                    onNotificationTap: (notification) =>
                        _markAsRead(context, notification),
                    onMarkAllAsRead: (notifications) =>
                        _markAllAsRead(context, notifications),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ],
          );
        },
      ),
    );
  }
}

bool _notificationBuildWhen(
  NotificationState previous,
  NotificationState current,
) {
  final previousData = notificationsFromState(previous);
  final currentData = notificationsFromState(current);

  return previousData != currentData ||
      previous.runtimeType != current.runtimeType;
}

void _markAsRead(BuildContext context, AppNotification notification) {
  if (notificationIsRead(notification)) return;

  context.read<NotificationBloc>().add(
    NotificationEvent.notificationReadRequested(notification: notification),
  );
}

void _markAllAsRead(BuildContext context, List<AppNotification> notifications) {
  final unreadNotifications = notifications
      .where((notification) => !notificationIsRead(notification))
      .toList();
  if (unreadNotifications.isEmpty) return;

  final bloc = context.read<NotificationBloc>();
  for (final notification in unreadNotifications) {
    bloc.add(
      NotificationEvent.notificationReadRequested(notification: notification),
    );
  }
}
