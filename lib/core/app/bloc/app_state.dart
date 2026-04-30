part of 'app_bloc.dart';

@freezed
abstract class AppState with _$AppState {
  const factory AppState({
    required Locale locale,
    required ThemeMode themeMode,
  }) = _AppState;
}
