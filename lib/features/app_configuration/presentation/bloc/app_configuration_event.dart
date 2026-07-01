part of 'app_configuration_bloc.dart';

@freezed
sealed class AppConfigurationEvent with _$AppConfigurationEvent {
  const factory AppConfigurationEvent.appConfigurationRequested({
    required UserRole role,
    @Default(false) bool forceRefresh,
  }) = _AppConfigurationRequested;

  const factory AppConfigurationEvent.retried() = _AppConfigurationRetried;
}
