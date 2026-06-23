// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:fpdart/fpdart.dart';
import 'package:hive_ce/hive_ce.dart';

import '../../../../core/internal/src/interfaces/data_interfaces.dart';
import '../../../../core/storage/storage_keys/hive_storage_names.dart';
import '../models/child_model/child_model.dart';
import '../models/parent_model/parent_model.dart';

abstract class ParentLocalDataSource
    implements ParentLocalManager<ParentModel, ChildModel> {}

class ParentLocalDataSourceImpl implements ParentLocalDataSource {
  ParentLocalDataSourceImpl(this._hiveInterface);

  final HiveInterface _hiveInterface;

  Box get _box => _hiveInterface.box(HiveStorageBoxNames.userBoxKey);

  @override
  ParentModel? readParentProfile() {
    final rawData = _box.get(HiveStorageNames.parentDetailKey);

    if (rawData == null) return null;

    return ParentModel.fromJson(Map<String, dynamic>.from(rawData));
  }

  @override
  Future<Unit> saveParentProfile(ParentModel data) async {
    await _box.put(HiveStorageNames.parentDetailKey, data.toJson());

    return unit;
  }

  @override
  List<ChildModel>? readChildren() {
    final rawData = _box.get(HiveStorageNames.parentChildrenKey);

    if (rawData == null) return null;

    return (rawData as List<dynamic>)
        .map((e) => ChildModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  Future<Unit> saveChildren(List<ChildModel> children) async {
    final rawList = children.map((e) => e.toJson()).toList();

    await _box.put(HiveStorageNames.parentChildrenKey, rawList);

    return unit;
  }

  @override
  ChildModel? readSelectedChild() {
    final rawData = _box.get(HiveStorageNames.parentSelectedChildKey);

    if (rawData == null) return null;

    return ChildModel.fromJson(Map<String, dynamic>.from(rawData));
  }

  @override
  Future<Unit> saveSelectedChild(ChildModel child) async {
    await _box.put(HiveStorageNames.parentSelectedChildKey, child.toJson());

    return unit;
  }
}
