part of 'notification_bloc.dart';

@freezed
sealed class NotificationState with _$NotificationState {
  const factory NotificationState.initial() = _Initial;

  const factory NotificationState.loading({
    @Default(<AppNotification>[]) List<AppNotification> notifications,
  }) = _Loading;

  const factory NotificationState.success({
    required List<AppNotification> notifications,
  }) = _Success;

  const factory NotificationState.failure(Failure failure) = _Failure;
}
