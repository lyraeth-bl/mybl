// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/di/get_it_constant.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/storage/domain/usecases/clear_all_boxes_use_case.dart';
import '../../../../core/token_provider/parent_token_provider.dart';
import '../../../../core/token_provider/token_provider.dart';
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
    this._clearAllBoxesUseCase,
  ) : super(const SessionState.initial()) {
    on<_Started>(_onStarted);
    on<_LoggedIn>(_onLoggedIn);
    on<_LoggedOut>(_onLoggedOut);
  }

  final SaveAccessTokenUseCase _saveAccessTokenUseCase;
  final ReadAccessTokenUseCase _readAccessTokenUseCase;
  final ClearAccessTokenUseCase _clearAccessTokenUseCase;
  final ClearAllBoxesUseCase _clearAllBoxesUseCase;

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

    final expiresAt = await di<TokenProvider>().readTokenExpiresAt();
    if (expiresAt != null && DateTime.now().isAfter(expiresAt)) {
      await _clearAllBoxesUseCase();
      await _clearAccessTokenUseCase();
      di<TokenProvider>().clearAccessToken();
      await di<TokenProvider>().clearRole();
      await di<ParentTokenProvider>().clearParentAccessToken();
      await di<ParentTokenProvider>().clearParentTokenExpiresAt();
      emit(const SessionState.unauthenticated());

      return;
    }

    final role = await di<TokenProvider>().readRole() ?? UserRole.student;

    emit(
      SessionState.authenticated(accessToken: storedAccessToken, role: role),
    );
  }

  /// Penjaga gerbang pas user berhasil login.
  ///
  /// Begitu dapet [event.accessToken], kita bakal suruh [SaveAccessTokenUseCase]
  /// buat nitipin token itu ke storage biar aman, terus update status jadi login.
  Future<void> _onLoggedIn(_LoggedIn event, Emitter<SessionState> emit) async {
    emit(const SessionState.loading());

    await _saveAccessTokenUseCase(event.accessToken);

    // Token tanpa masa berlaku (expires_at null) berarti sesi tidak kedaluwarsa.
    // Expiry lama harus dihapus, bukan sekadar dilewat: nilai sisa dari sesi
    // sebelumnya bakal bikin user ter-logout di pengecekan awal.
    final expiresAt = event.expiresAt;
    if (expiresAt != null) {
      await di<TokenProvider>().saveTokenExpiresAt(expiresAt);
    } else {
      await di<TokenProvider>().clearTokenExpiresAt();
    }

    await di<TokenProvider>().saveRole(event.role);
    di<TokenProvider>().saveAccessToken(event.accessToken);

    // Untuk parent, token juga disimpan di [ParentTokenProvider] karena
    // interceptor membaca token parent dari sana saat menembak API.
    if (event.role == UserRole.parent) {
      await di<ParentTokenProvider>().saveParentAccessToken(event.accessToken);

      if (expiresAt != null) {
        await di<ParentTokenProvider>().saveParentTokenExpiresAt(expiresAt);
      } else {
        await di<ParentTokenProvider>().clearParentTokenExpiresAt();
      }
    }

    emit(
      SessionState.authenticated(
        accessToken: event.accessToken,
        role: event.role,
      ),
    );
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

    await _clearAllBoxesUseCase();

    await _clearAccessTokenUseCase();

    await di<TokenProvider>().clearTokenExpiresAt();

    await di<TokenProvider>().clearRole();

    di<TokenProvider>().clearAccessToken();

    await di<ParentTokenProvider>().clearParentAccessToken();
    await di<ParentTokenProvider>().clearParentTokenExpiresAt();

    emit(const SessionState.unauthenticated());
  }
}
