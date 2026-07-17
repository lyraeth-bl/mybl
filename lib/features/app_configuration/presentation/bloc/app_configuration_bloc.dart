// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/enums/user_role.dart';
import '../../../../core/failure/failure.dart';
import '../../domain/entities/app_configuration_entity/app_configuration_entity.dart';
import '../../domain/usecases/fetch_app_config_use_case.dart';

part 'app_configuration_bloc.freezed.dart';
part 'app_configuration_event.dart';
part 'app_configuration_state.dart';

class AppConfigurationBloc
    extends Bloc<AppConfigurationEvent, AppConfigurationState> {
  AppConfigurationBloc(this._appConfigUseCase)
    : super(const AppConfigurationState.initial()) {
    on<_AppConfigurationRequested>(_onAppConfigurationRequested);
    on<_AppConfigurationRetried>(_onAppConfigurationRetried);
  }

  final FetchAppConfigUseCase _appConfigUseCase;
  UserRole _role = UserRole.student;

  Future<void> _onAppConfigurationRetried(
    _AppConfigurationRetried event,
    Emitter<AppConfigurationState> emit,
  ) => _fetch(role: _role, forceRefresh: true, emit: emit);

  Future<void> _onAppConfigurationRequested(
    _AppConfigurationRequested event,
    Emitter<AppConfigurationState> emit,
  ) {
    _role = event.role;
    return _fetch(
      role: event.role,
      forceRefresh: event.forceRefresh,
      emit: emit,
    );
  }

  Future<void> _fetch({
    required UserRole role,
    required bool forceRefresh,
    required Emitter<AppConfigurationState> emit,
  }) async {
    emit(const AppConfigurationState.loading());

    final result = await _appConfigUseCase.call(
      role: role,
      forceRefresh: forceRefresh,
    );

    return result.match(
      (failure) => emit(AppConfigurationState.failure(failure)),
      (data) => emit(AppConfigurationState.success(appConfiguration: data)),
    );
  }
}
