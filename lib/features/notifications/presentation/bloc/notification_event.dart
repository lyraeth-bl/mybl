part of 'notification_bloc.dart';

@freezed
sealed class NotificationEvent with _$NotificationEvent {
  const factory NotificationEvent.fetchNotificationsRequested() =
      _FetchNotificationsRequested;

  const factory NotificationEvent.notificationReadRequested({
    required AppNotification notification,
  }) = _NotificationReadRequested;
}
