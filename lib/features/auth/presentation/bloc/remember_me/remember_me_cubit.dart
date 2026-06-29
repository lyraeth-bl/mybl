// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_bl/core/enums/user_role.dart';

import '../../../domain/usecases/read_nis_use_case.dart';
import '../../../domain/usecases/read_username_use_case.dart';
import '../../../domain/usecases/save_nis_use_case.dart';
import '../../../domain/usecases/save_username_use_case.dart';

part 'remember_me_cubit.freezed.dart';
part 'remember_me_state.dart';

class RememberMeCubit extends Cubit<RememberMeState> {
  RememberMeCubit(
    this._readNisUseCase,
    this._saveNisUseCase,
    this._readUsernameUseCase,
    this._saveUsernameUseCase,
  ) : super(const RememberMeState());

  final ReadNisUseCase _readNisUseCase;
  final SaveNisUseCase _saveNisUseCase;
  final ReadUsernameUseCase _readUsernameUseCase;
  final SaveUsernameUseCase _saveUsernameUseCase;

  Future<void> loadSavedIdentifier(UserRole role) async {
    final identifier = role == UserRole.parent
        ? await _readUsernameUseCase()
        : await _readNisUseCase();
    emit(state.copyWith(savedIdentifier: identifier ?? ''));
  }

  void toggleCheckBox(bool value) {
    emit(state.copyWith(isChecked: value));
  }

  Future<void> onLoginSuccess(UserRole role, String identifier) async {
    final value = state.isChecked ? identifier : '';
    if (role == UserRole.parent) {
      await _saveUsernameUseCase(value);
    } else {
      await _saveNisUseCase(value);
    }
  }
}
