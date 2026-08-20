part of 'forgot_password_bloc.dart';

@freezed
sealed class ForgotPasswordEvent with _$ForgotPasswordEvent {
  const factory ForgotPasswordEvent.otpRequested({required String nis}) =
      _OtpRequested;

  const factory ForgotPasswordEvent.otpVerificationRequested({
    required String nis,
    required String otpCode,
  }) = _OtpVerificationRequested;

  const factory ForgotPasswordEvent.passwordResetRequested({
    required String resetToken,
    required String password,
    required String passwordConfirmation,
  }) = _PasswordResetRequested;
}
