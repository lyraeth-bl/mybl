// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/usecases/read_nis_use_case.dart';
import '../../../domain/usecases/save_nis_use_case.dart';

part 'remember_me_cubit.freezed.dart';
part 'remember_me_state.dart';

/// [RememberMeCubit] itu jembatan andalan buat ngurusin fitur "Remember Me" pas login.
///
/// Si cubit ini tugasnya simpel tapi penting: inget-inget NIS user biar mereka nggak
/// capek ngetik ulang tiap kali mau masuk. Dia nge-manage [RememberMeState] yang
/// isinya status checkbox (centang apa nggak) sama data NIS yang udah kesimpen.
class RememberMeCubit extends Cubit<RememberMeState> {
  /// Constructor buat inisialisasi [RememberMeCubit].
  ///
  /// Di sini kita butuh [_readNisUseCase] buat ambil data lama dan [_saveNisUseCase]
  /// buat nyimpen data baru.
  RememberMeCubit(this._readNisUseCase, this._saveNisUseCase)
    : super(const RememberMeState());

  final ReadNisUseCase _readNisUseCase;
  final SaveNisUseCase _saveNisUseCase;

  /// Panggil [loadSavedEmail] pas screen login baru dibuka.
  ///
  /// Method ini bakal nanya ke [_readNisUseCase] apakah ada NIS yang pernah
  /// disimpen sebelumnya. Kalo ada, langsung di-update ke [RememberMeState.savedNIS].
  Future<void> loadSavedEmail() async {
    final email = await _readNisUseCase();
    emit(state.copyWith(savedNIS: email ?? ''));
  }

  /// [toggleCheckBox] dipake tiap kali user nge-tap checkbox "Ingat Saya".
  ///
  /// Tinggal masukin [value] barunya (true/false), terus status [RememberMeState.isChecked]
  /// bakal otomatis berubah.
  void toggleCheckBox(bool value) {
    emit(state.copyWith(isChecked: value));
  }

  /// [onLoginSuccess] ini "si paling sibuk" pas proses login kelar dan berhasil.
  ///
  /// Dia bakal ngecek: kalo [RememberMeState.isChecked] itu true, NIS user bakal
  /// disimpen pake [_saveNisUseCase]. Tapi kalo nggak dicentang, dia bakal
  /// ngebersihin data NIS yang lama biar nggak kesimpen lagi.
  Future<void> onLoginSuccess(String nis) async {
    if (state.isChecked) {
      await _saveNisUseCase(nis);
    } else {
      await _saveNisUseCase('');
    }
  }
}
