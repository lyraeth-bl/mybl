// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/usecases/clear_access_token_use_case.dart';
import '../../domain/usecases/read_access_token_use_case.dart';
import '../../domain/usecases/save_access_token_use_case.dart';

part 'session_bloc.freezed.dart';
part 'session_event.dart';
part 'session_state.dart';

/// Si paling sibuk buat ngurusin status login user di seluruh aplikasi.
///
/// [SessionBloc] ini adalah otak di balik status autentikasi. Dia yang nentuin
/// apakah user lagi login, lagi proses loading, atau malah belum login sama sekali.
/// Dia bakal kerja bareng beberapa Use Case buat baca, simpen, atau hapus token.
class SessionBloc extends Bloc<SessionEvent, SessionState> {
  SessionBloc(
    this._saveAccessTokenUseCase,
    this._readAccessTokenUseCase,
    this._clearAccessTokenUseCase,
  ) : super(const SessionState.initial()) {
    on<_Started>(_onStarted);
    on<_LoggedIn>(_onLoggedIn);
    on<_LoggedOut>(_onLoggedOut);
  }

  final SaveAccessTokenUseCase _saveAccessTokenUseCase;
  final ReadAccessTokenUseCase _readAccessTokenUseCase;
  final ClearAccessTokenUseCase _clearAccessTokenUseCase;

  /// Proses pengecekan awal pas app baru dibuka.
  ///
  /// Di sini kita bakal minta [ReadAccessTokenUseCase] buat ngintip apakah
  /// ada token yang nyangkut di storage. Kalau ada, user langsung dianggap
  /// [SessionState.authenticated], kalau nggak ya [SessionState.unauthenticated].
  Future<void> _onStarted(_Started event, Emitter<SessionState> emit) async {
    emit(const SessionState.loading());

    final storedAccessToken = await _readAccessTokenUseCase();

    if (storedAccessToken == null) {
      emit(const SessionState.unauthenticated());

      return;
    }

    emit(SessionState.authenticated(accessToken: storedAccessToken));
  }

  /// Penjaga gerbang pas user berhasil login.
  ///
  /// Begitu dapet [event.accessToken], kita bakal suruh [SaveAccessTokenUseCase]
  /// buat nitipin token itu ke storage biar aman, terus update status jadi login.
  Future<void> _onLoggedIn(_LoggedIn event, Emitter<SessionState> emit) async {
    emit(const SessionState.loading());

    await _saveAccessTokenUseCase(event.accessToken);

    // TODO : Tambah save token ke TokenProvider kalau sudah ada.

    emit(SessionState.authenticated(accessToken: event.accessToken));
  }

  /// Bagian beres-beres pas user milih buat cabut.
  ///
  /// Kita bakal panggil [ClearAccessTokenUseCase] buat bakar token yang ada
  /// biar nggak disalahgunakan, terus balikin status jadi nggak login.
  Future<void> _onLoggedOut(
    _LoggedOut event,
    Emitter<SessionState> emit,
  ) async {
    emit(const SessionState.loading());

    await _clearAccessTokenUseCase();

    // TODO : Tambah clear token di TokenProvider kalau sudah ada.

    emit(const SessionState.unauthenticated());
  }
}
