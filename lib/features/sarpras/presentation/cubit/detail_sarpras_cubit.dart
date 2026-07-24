// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/failure/failure.dart';
import '../../domain/entities/sarpras/sarpras.dart';
import '../../domain/usecases/fetch_detail_sarpras_use_case.dart';

part 'detail_sarpras_state.dart';
part 'detail_sarpras_cubit.freezed.dart';

class DetailSarprasCubit extends Cubit<DetailSarprasState> {
  DetailSarprasCubit(this._fetchDetailSarprasUseCase) : super(const .initial());

  final FetchDetailSarprasUseCase _fetchDetailSarprasUseCase;

  Future<void> fetchDetail({required int sarprasId}) async {
    emit(const .loading());

    final result = await _fetchDetailSarprasUseCase(sarprasId: sarprasId);

    return result.match(
      (f) => emit(.failure(f)),
      (r) => emit(.success(sarpras: r)),
    );
  }
}
