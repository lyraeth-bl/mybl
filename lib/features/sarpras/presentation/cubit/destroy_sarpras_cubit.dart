// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/failure/failure.dart';
import '../../domain/usecases/destroy_sarpras_use_case.dart';

part 'destroy_sarpras_state.dart';
part 'destroy_sarpras_cubit.freezed.dart';

class DestroySarprasCubit extends Cubit<DestroySarprasState> {
  DestroySarprasCubit(this._destroySarprasUseCase) : super(const .initial());

  final DestroySarprasUseCase _destroySarprasUseCase;

  Future<void> destroySarpras({required int sarprasId}) async {
    emit(const .loading());

    final result = await _destroySarprasUseCase(sarprasId: sarprasId);

    return result.match(
      (f) => emit(.failure(f)),
      (r) => emit(const .success()),
    );
  }
}
