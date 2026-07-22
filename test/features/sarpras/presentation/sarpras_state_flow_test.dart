// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:my_bl/core/internal/src/types.dart';
import 'package:my_bl/features/sarpras/domain/entities/sarpras/sarpras.dart';
import 'package:my_bl/features/sarpras/domain/entities/sarpras_params/sarpras_params.dart';
import 'package:my_bl/features/sarpras/domain/entities/sarpras_summary/sarpras_summary.dart';
import 'package:my_bl/features/sarpras/domain/entities/sarpras_teacher_candidate/sarpras_teacher_candidate.dart';
import 'package:my_bl/features/sarpras/domain/repositories/sarpras_repository.dart';
import 'package:my_bl/features/sarpras/domain/usecases/fetch_sarpras_use_case.dart';
import 'package:my_bl/features/sarpras/domain/usecases/store_sarpras_use_case.dart';
import 'package:my_bl/features/sarpras/presentation/bloc/sarpras_bloc.dart';
import 'package:my_bl/features/sarpras/presentation/cubit/store_sarpras_cubit.dart';

const SarprasSummary _summary = SarprasSummary(
  waiting: 1,
  accepted: 0,
  rejected: 0,
);

final Sarpras _sarpras = Sarpras(
  id: 12,
  unit: 'SMA',
  nis: '2023001',
  tanggalKegiatan: DateTime.utc(2026, 7, 20),
  namaKegiatan: 'Latihan Paskibra',
  jumlahSiswaDalamKegiatan: '30',
  nipGuruPembimbing: '198701012010011001',
  waktuKegiatan: '07:00 - 09:00',
  status: 'Menunggu',
);

final class _FakeSarprasRepository implements SarprasRepository {
  _FakeSarprasRepository({this.listSarpras = const <Sarpras>[]});

  final List<Sarpras> listSarpras;

  @override
  Future<Result<(SarprasSummary, List<Sarpras>)>> fetchSarpras() async =>
      right((_summary, listSarpras));

  @override
  Future<Result<Sarpras>> storeSarpras(SarprasParams params) async =>
      right(_sarpras);

  @override
  Future<Result<Sarpras>> fetchDetailSarpras({required int sarprasId}) =>
      throw UnimplementedError();

  @override
  Future<Result<Sarpras>> updateSarpras({
    required int sarprasId,
    required SarprasParams params,
  }) => throw UnimplementedError();

  @override
  Future<Result<Unit>> destroySarpras({required int sarprasId}) =>
      throw UnimplementedError();

  @override
  Future<Result<List<SarprasTeacherCandidate>>>
  fetchSarprasTeacherCandidate() => throw UnimplementedError();
}

void main() {
  group('SarprasBloc', () {
    test('emit empty tanpa disusul success saat daftar kosong', () async {
      final bloc = SarprasBloc(FetchSarprasUseCase(_FakeSarprasRepository()));
      addTearDown(bloc.close);

      final states = <SarprasState>[];
      final subscription = bloc.stream.listen(states.add);

      bloc.add(const SarprasEvent.fetchSarpras());
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();

      expect(states, [
        const SarprasState.loading(),
        const SarprasState.empty(summary: _summary),
      ]);
    });

    test('emit success saat daftar terisi', () async {
      final bloc = SarprasBloc(
        FetchSarprasUseCase(_FakeSarprasRepository(listSarpras: [_sarpras])),
      );
      addTearDown(bloc.close);

      final states = <SarprasState>[];
      final subscription = bloc.stream.listen(states.add);

      bloc.add(const SarprasEvent.fetchSarpras());
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();

      expect(states, [
        const SarprasState.loading(),
        SarprasState.success(summary: _summary, listSarpras: [_sarpras]),
      ]);
    });
  });

  group('StoreSarprasCubit', () {
    test('emit loading sebelum success', () async {
      final cubit = StoreSarprasCubit(
        StoreSarprasUseCase(_FakeSarprasRepository()),
      );
      addTearDown(cubit.close);

      final states = <StoreSarprasState>[];
      final subscription = cubit.stream.listen(states.add);

      await cubit.storeSarpras(
        SarprasParams(
          tanggalKegiatan: DateTime.utc(2026, 7, 20),
          namaKegiatan: 'Latihan Paskibra',
          jumlahSiswaDalamKegiatan: '30',
          nipGuruPembimbing: '198701012010011001',
          jamMulaiKegiatan: DateTime.utc(2026, 7, 20, 7),
          jamSelesaiKegiatan: DateTime.utc(2026, 7, 20, 9),
        ),
      );
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();

      expect(states, [
        const StoreSarprasState.loading(),
        StoreSarprasState.success(sarpras: _sarpras),
      ]);
    });
  });
}
