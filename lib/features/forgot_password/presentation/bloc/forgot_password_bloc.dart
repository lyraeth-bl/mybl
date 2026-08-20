// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/failure/failure.dart';
import '../../domain/usecases/reset_password_use_case.dart';
import '../../domain/usecases/send_reset_otp_use_case.dart';
import '../../domain/usecases/verify_reset_otp_use_case.dart';

part 'forgot_password_bloc.freezed.dart';
part 'forgot_password_event.dart';
part 'forgot_password_state.dart';

class ForgotPasswordBloc
    extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  ForgotPasswordBloc(
    this._sendResetOtpUseCase,
    this._verifyResetOtpUseCase,
    this._resetPasswordUseCase,
  ) : super(const ForgotPasswordState.initial()) {
    on<_OtpRequested>(_onOtpRequested);
    on<_OtpVerificationRequested>(_onOtpVerificationRequested);
    on<_PasswordResetRequested>(_onPasswordResetRequested);
  }

  final SendResetOtpUseCase _sendResetOtpUseCase;
  final VerifyResetOtpUseCase _verifyResetOtpUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;

  Future<void> _onOtpRequested(
    _OtpRequested event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(const ForgotPasswordState.loading());

    final result = await _sendResetOtpUseCase(nis: event.nis);

    return result.match(
      (failure) => emit(ForgotPasswordState.failure(failure)),
      (_) => emit(ForgotPasswordState.otpSent(nis: event.nis)),
    );
  }

  Future<void> _onOtpVerificationRequested(
    _OtpVerificationRequested event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(const ForgotPasswordState.loading());

    final result = await _verifyResetOtpUseCase(
      nis: event.nis,
      otpCode: event.otpCode,
    );

    return result.match(
      (failure) => emit(ForgotPasswordState.failure(failure)),
      (resetToken) =>
          emit(ForgotPasswordState.otpVerified(resetToken: resetToken)),
    );
  }

  Future<void> _onPasswordResetRequested(
    _PasswordResetRequested event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(const ForgotPasswordState.loading());

    final result = await _resetPasswordUseCase(
      resetToken: event.resetToken,
      password: event.password,
      passwordConfirmation: event.passwordConfirmation,
    );

    return result.match(
      (failure) => emit(ForgotPasswordState.failure(failure)),
      (_) => emit(const ForgotPasswordState.successReset()),
    );
  }
}
