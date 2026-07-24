// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_bl/core/failure/failure.dart';
import 'package:my_bl/features/sarpras/domain/entities/sarpras/sarpras.dart';
import 'package:my_bl/features/sarpras/domain/repositories/sarpras_repository.dart';
import 'package:my_bl/features/sarpras/domain/usecases/fetch_detail_sarpras_use_case.dart';
import 'package:my_bl/features/sarpras/presentation/cubit/detail_sarpras_cubit.dart';

class _MockSarprasRepository extends Mock implements SarprasRepository {}

final Sarpras _sarpras = Sarpras(
  id: 4,
  unit: 'SMAKT',
  nis: '24251026',
  tanggalKegiatan: DateTime(2026, 7, 23),
  namaKegiatan: 'Meeting IT',
  jumlahSiswaDalamKegiatan: '5',
  nipGuruPembimbing: '20250602',
  waktuKegiatan: '12.00 - 15.00',
  status: 'Menunggu',
);

void main() {
  test('emits loading then success', () async {
    final repository = _MockSarprasRepository();
    when(
      () => repository.fetchDetailSarpras(sarprasId: 4),
    ).thenAnswer((_) async => right(_sarpras));

    final cubit = DetailSarprasCubit(FetchDetailSarprasUseCase(repository));
    addTearDown(cubit.close);

    final states = <DetailSarprasState>[];
    final subscription = cubit.stream.listen(states.add);

    await cubit.fetchDetail(sarprasId: 4);
    await Future<void>.delayed(Duration.zero);
    await subscription.cancel();

    expect(states, [
      const DetailSarprasState.loading(),
      DetailSarprasState.success(sarpras: _sarpras),
    ]);
  });

  test('emits loading then failure', () async {
    final repository = _MockSarprasRepository();
    const failure = Failure.unexpected(errorMessage: 'boom');
    when(
      () => repository.fetchDetailSarpras(sarprasId: 9),
    ).thenAnswer((_) async => left(failure));

    final cubit = DetailSarprasCubit(FetchDetailSarprasUseCase(repository));
    addTearDown(cubit.close);

    final states = <DetailSarprasState>[];
    final subscription = cubit.stream.listen(states.add);

    await cubit.fetchDetail(sarprasId: 9);
    await Future<void>.delayed(Duration.zero);
    await subscription.cancel();

    expect(states, [
      const DetailSarprasState.loading(),
      const DetailSarprasState.failure(failure),
    ]);
  });
}
