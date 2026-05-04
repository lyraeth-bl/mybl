part of 'user_bloc.dart';

/// [UserEvent] itu daftar "Keinginan" lo ke [UserBloc].
/// Kalo lo mau sesuatu kejadian di fitur user, lo harus kirim salah satu
/// event dari sini.
@freezed
sealed class UserEvent with _$UserEvent {
  /// Pake [fetchStudentRequested] pas lo pengen ambil data profil siswa.
  /// Kalo pengen maksa ambil dari server (skip cache), set `forceRefresh` jadi `true`.
  const factory UserEvent.fetchStudentRequested([
    @Default(false) bool forceRefresh,
  ]) = _FetchStudentRequested;
}
