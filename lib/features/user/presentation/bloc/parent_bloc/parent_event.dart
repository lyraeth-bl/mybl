part of 'parent_bloc.dart';

@freezed
sealed class ParentEvent with _$ParentEvent {
  /// Hidrasi konteks parent dari storage + `/parent/me`. Dipakai saat
  /// aplikasi dibuka ulang (restart).
  const factory ParentEvent.started({@Default(false) bool forceRefresh}) =
      _Started;

  /// Dipicu setelah login parent berhasil. Menyimpan daftar anak dan
  /// memilih otomatis jika anaknya cuma satu.
  const factory ParentEvent.loginSucceeded({
    required String nama,
    required List<ChildEntity> children,
  }) = _LoginSucceeded;

  /// Parent memilih/ganti anak dari daftar.
  const factory ParentEvent.childSelected(ChildEntity child) = _ChildSelected;
}
