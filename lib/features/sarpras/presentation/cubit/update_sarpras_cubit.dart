// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/failure/failure.dart';
import '../../domain/entities/sarpras/sarpras.dart';
import '../../domain/entities/sarpras_params/sarpras_params.dart';
import '../../domain/usecases/update_sarpras_use_case.dart';

part 'update_sarpras_state.dart';
part 'update_sarpras_cubit.freezed.dart';

class UpdateSarprasCubit extends Cubit<UpdateSarprasState> {
  UpdateSarprasCubit(this._updateSarprasUseCase) : super(const .initial());

  final UpdateSarprasUseCase _updateSarprasUseCase;

  Future<void> updateSarpras({
    required int sarprasId,
    required SarprasParams params,
  }) async {
    emit(const .loading());

    final result = await _updateSarprasUseCase(
      sarprasId: sarprasId,
      params: params,
    );

    return result.match(
      (f) => emit(.failure(f)),
      (r) => emit(.success(sarpras: r)),
    );
  }
}
