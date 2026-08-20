part of 'forgot_password_bloc.dart';

@freezed
sealed class ForgotPasswordState with _$ForgotPasswordState {
  const factory ForgotPasswordState.initial() = _Initial;

  const factory ForgotPasswordState.loading() = _Loading;

  const factory ForgotPasswordState.otpSent({required String nis}) = _OtpSent;

  const factory ForgotPasswordState.otpVerified({required String resetToken}) =
      _OtpVerified;

  const factory ForgotPasswordState.successReset() = _SuccessReset;

  const factory ForgotPasswordState.failure(Failure failure) = _Failure;
}
