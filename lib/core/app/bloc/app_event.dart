part of 'app_bloc.dart';

@freezed
abstract class AppEvent with _$AppEvent {
  const factory AppEvent.loadInitialLanguage() = _LoadInitialLanguage;

  const factory AppEvent.changeLanguage(String languageCode) = _ChangeLanguage;

  const factory AppEvent.changeTheme(ThemeMode themeMode) = _ChangeTheme;
}
