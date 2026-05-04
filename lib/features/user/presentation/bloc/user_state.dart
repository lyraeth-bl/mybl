part of 'user_bloc.dart';

/// [UserState] itu cara [UserBloc] ngomong ke UI, "Eh, kondisi sekarang lagi begini nih".
/// UI tinggal nungguin dan bereaksi sesuai status yang dikirim dari sini.
@freezed
sealed class UserState with _$UserState {
  /// Status pas awal banget, belum ada apa-apa.
  const factory UserState.initial() = _Initial;

  /// Status pas lagi nungguin data dateng (misal: lagi nembak API).
  /// Biasanya di UI lo nampilin loading spinner.
  const factory UserState.loading() = _Loading;

  /// Status pas data [student] udah berhasil didapet.
  /// Saatnya nampilin info profil siswa yang cakep di layar!
  const factory UserState.success({required StudentEntity student}) = _Success;

  /// Status pas ada yang salah (misal: internet mati).
  /// Kita kirim [failure]-nya biar UI tau harus nampilin pesan error apa.
  const factory UserState.failure(Failure failure) = _Failure;
}
