// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../localizations/localization_storage.dart';
import '../../theme/theme_storage.dart';

part 'app_bloc.freezed.dart';
part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc(this._themeStorage, this._localizationStorage)
    : super(
        AppState(
          locale: const Locale('id'),
          themeMode: _themeStorage.read() ?? ThemeMode.system,
        ),
      ) {
    on<_ChangeLanguage>(_onChangeLanguage);
    on<_ChangeTheme>(_onChangeTheme);
    on<_LoadInitialLanguage>(_onLoadInitialLanguage);

    add(const AppEvent.loadInitialLanguage());
  }

  final ThemeStorage _themeStorage;
  final LocalizationStorage _localizationStorage;

  Future<void> _onLoadInitialLanguage(
    _LoadInitialLanguage event,
    Emitter<AppState> emit,
  ) async {
    final savedCode = _localizationStorage.read();

    if (savedCode != null) {
      emit(state.copyWith(locale: Locale(savedCode)));
    }
  }

  Future<void> _onChangeLanguage(
    _ChangeLanguage event,
    Emitter<AppState> emit,
  ) async {
    await _localizationStorage.save(event.languageCode);

    emit(state.copyWith(locale: Locale(event.languageCode)));
  }

  Future<void> _onChangeTheme(
    _ChangeTheme event,
    Emitter<AppState> emit,
  ) async {
    await _themeStorage.save(event.themeMode);
    emit(state.copyWith(themeMode: event.themeMode));
  }
}
