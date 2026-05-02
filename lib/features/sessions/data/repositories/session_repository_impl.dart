import 'package:fpdart/fpdart.dart';

import '../../domain/repositories/session_repository.dart';
import '../datasources/session_local_data_source.dart';

/// Implementasi nyata dari [SessionRepository].
///
/// [SessionRepositoryImpl] ini sebenernya cuma makelar. Dia nggak kerja sendirian,
/// tapi minta tolong ke [SessionLocalDataSource] buat urusan teknis nyimpen
/// atau ambil data di storage lokal. Jadi kalau mau ganti cara simpen data,
/// tinggal oprek datasource-nya aja tanpa ngerusak logika di repository ini.
class SessionRepositoryImpl implements SessionRepository {
  SessionRepositoryImpl(this._localDataSource);

  final SessionLocalDataSource _localDataSource;

  /// Nyuruh datasource buat ngehapus token yang ada.
  @override
  Future<Unit> clearAccessToken() async =>
      await _localDataSource.clearAccessToken();

  /// Minta datasource buat ngintip token yang lagi disimpen.
  @override
  Future<String?> readAccessToken() async =>
      await _localDataSource.readAccessToken();

  /// Nitipin token ke datasource buat disimpan baik-baik.
  @override
  Future<Unit> saveAccessToken(String accessToken) async =>
      await _localDataSource.saveAccessToken(accessToken);
}
