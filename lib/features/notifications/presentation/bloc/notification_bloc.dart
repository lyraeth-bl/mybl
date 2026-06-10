// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/failure/failure.dart';
import '../../domain/entities/app_notification/app_notification.dart';
import '../../domain/usecases/mark_notification_as_read_use_case.dart';
import '../../domain/usecases/read_notifications_use_case.dart';

part 'notification_bloc.freezed.dart';
part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc(
    this._readNotificationsUseCase,
    this._markNotificationAsReadUseCase,
  ) : super(const NotificationState.initial()) {
    on<_FetchNotificationsRequested>(_onFetchNotificationsRequested);
    on<_NotificationReadRequested>(_onNotificationReadRequested);
  }

  final ReadNotificationsUseCase _readNotificationsUseCase;
  final MarkNotificationAsReadUseCase _markNotificationAsReadUseCase;

  Future<void> _onFetchNotificationsRequested(
    _FetchNotificationsRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(
      NotificationState.loading(notifications: _currentNotifications(state)),
    );

    final result = await _readNotificationsUseCase();

    return result.match(
      (failure) => emit(NotificationState.failure(failure)),
      (notifications) =>
          emit(NotificationState.success(notifications: notifications)),
    );
  }

  Future<void> _onNotificationReadRequested(
    _NotificationReadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    final notifications = _currentNotifications(state);
    if (_isRead(event.notification)) return;

    emit(NotificationState.loading(notifications: notifications));

    final result = await _markNotificationAsReadUseCase(event.notification.id);

    return result.match(
      (failure) => emit(NotificationState.failure(failure)),
      (_) => add(const NotificationEvent.fetchNotificationsRequested()),
    );
  }

  static List<AppNotification> _currentNotifications(NotificationState state) {
    return state.maybeWhen(
      loading: (notifications) => notifications,
      success: (notifications) => notifications,
      orElse: () => const <AppNotification>[],
    );
  }

  static bool _isRead(AppNotification notification) {
    return notification.isRead.toLowerCase() == 'true' ||
        notification.isRead == '1' ||
        notification.isReadAt != null;
  }
}
