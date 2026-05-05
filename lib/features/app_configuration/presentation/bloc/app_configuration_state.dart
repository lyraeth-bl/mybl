part of 'app_configuration_bloc.dart';

@freezed
sealed class AppConfigurationState with _$AppConfigurationState {
  const factory AppConfigurationState.initial() = _Initial;

  const factory AppConfigurationState.loading() = _Loading;

  const factory AppConfigurationState.success({
    required AppConfigurationEntity appConfiguration,
  }) = _Success;

  const factory AppConfigurationState.failure(Failure failure) = _Failure;
}
