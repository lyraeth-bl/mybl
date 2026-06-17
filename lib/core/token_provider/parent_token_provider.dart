import 'package:fpdart/fpdart.dart';

import '../../features/sessions/data/datasources/session_local_data_source.dart';
import '../internal/src/interfaces/data_interfaces.dart';

abstract class ParentTokenProvider implements ParentTokenStorage {}

class ParentTokenProviderImpl implements ParentTokenProvider {
  ParentTokenProviderImpl(this._sessionLocalDataSource);

  final SessionLocalDataSource _sessionLocalDataSource;
  String? _cachedToken;

  @override
  Future<String?> readParentAccessToken() async =>
      _cachedToken ?? _sessionLocalDataSource.readParentAccessToken();

  @override
  Future<Unit> saveParentAccessToken(String accessToken) async {
    _cachedToken = accessToken;
    return unit;
  }

  @override
  Future<Unit> clearParentAccessToken() async {
    _cachedToken = null;
    await _sessionLocalDataSource.clearParentAccessToken();
    return unit;
  }

  @override
  Future<Unit> clearParentTokenExpiresAt() =>
      _sessionLocalDataSource.clearParentTokenExpiresAt();

  @override
  Future<DateTime?> readParentTokenExpiresAt() =>
      _sessionLocalDataSource.readParentTokenExpiresAt();

  @override
  Future<Unit> saveParentTokenExpiresAt(DateTime expiresAt) =>
      _sessionLocalDataSource.saveParentTokenExpiresAt(expiresAt);
}
