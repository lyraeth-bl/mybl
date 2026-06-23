// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';

import '../../../../core/failure/failure.dart';
import '../../../../core/internal/src/types.dart';
import '../../domain/entities/child_entity/child_entity.dart';
import '../../domain/entities/parent_entity/parent_entity.dart';
import '../../domain/repositories/parent_repository.dart';
import '../datasources/parent_local_data_source.dart';
import '../datasources/parent_remote_data_source.dart';
import '../models/child_model/child_model.dart';
import '../models/parent_model/parent_model.dart';

/// Mengatur alur data profil parent: cek cache lokal dulu, baru tembak
/// `/parent/me` kalau kosong atau dipaksa refresh. Pola ini sama persis
/// dengan [UserRepositoryImpl] milik student.
class ParentRepositoryImpl implements ParentRepository {
  ParentRepositoryImpl(this._localDataSource, this._remoteDataSource);

  final ParentLocalDataSource _localDataSource;
  final ParentRemoteDataSource _remoteDataSource;

  @override
  Future<Result<ParentEntity>> fetch({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final storedData = _localDataSource.readParentProfile();

      if (storedData != null) return right(storedData.toEntity());
    }

    try {
      final response = await _remoteDataSource.fetch();

      await _localDataSource.saveParentProfile(response.parent);

      return right(response.parent.toEntity());
    } catch (e, st) {
      return left(Failure.fromError(e, st));
    }
  }

  @override
  Future<Result<Unit>> saveChildren(List<ChildEntity> children) async {
    final models = children
        .map(
          (e) => ChildModel(
            nis: e.nis,
            nama: e.nama,
            kelas: e.kelas,
            profileImageUrl: e.profileImageUrl,
          ),
        )
        .toList();

    return right(await _localDataSource.saveChildren(models));
  }

  @override
  Future<Result<List<ChildEntity>>> readChildren() async {
    final stored = _localDataSource.readChildren();

    return right(stored?.map((e) => e.toEntity()).toList() ?? []);
  }

  @override
  Future<Result<Unit>> saveSelectedChild(ChildEntity child) async {
    final model = ChildModel(
      nis: child.nis,
      nama: child.nama,
      kelas: child.kelas,
      profileImageUrl: child.profileImageUrl,
    );

    return right(await _localDataSource.saveSelectedChild(model));
  }

  @override
  Future<Result<ChildEntity?>> readSelectedChild() async {
    final stored = _localDataSource.readSelectedChild();

    return right(stored?.toEntity());
  }
}
