part of 'app_configuration_bloc.dart';

@freezed
sealed class AppConfigurationEvent with _$AppConfigurationEvent {
  const factory AppConfigurationEvent.appConfigurationRequested({
    @Default(false) bool forceRefresh,
  }) = _AppConfigurationRequested;
}
