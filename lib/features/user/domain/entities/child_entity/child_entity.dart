import 'package:freezed_annotation/freezed_annotation.dart';

part 'child_entity.freezed.dart';

/// Representasi ringkas data anak, dipakai khusus untuk fitur orang tua.
/// Berbeda dengan [StudentEntity] yang lengkap, ini hanya berisi
/// informasi yang dibutuhkan untuk Child Selector UI.
@freezed
abstract class ChildEntity with _$ChildEntity {
  const factory ChildEntity({
    required String nis,
    required String nama,
    required String kelas,
    String? profileImageUrl,
  }) = _ChildEntity;
}
