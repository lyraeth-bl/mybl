// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../core/failure/failure.dart';
import '../../../domain/entities/child_entity/child_entity.dart';
import '../../../domain/entities/parent_entity/parent_entity.dart';
import '../../../domain/usecases/fetch_parent_use_case.dart';
import '../../../domain/usecases/read_children_use_case.dart';
import '../../../domain/usecases/read_selected_child_use_case.dart';
import '../../../domain/usecases/save_children_use_case.dart';
import '../../../domain/usecases/save_selected_child_use_case.dart';

part 'parent_bloc.freezed.dart';
part 'parent_event.dart';
part 'parent_state.dart';

/// [ParentBloc] mengelola konteks orang tua: profil parent (dari `/parent/me`),
/// daftar anak, dan anak yang sedang dipilih. Pola fetch profilnya mengikuti
/// [UserBloc] milik student.
class ParentBloc extends Bloc<ParentEvent, ParentState> {
  ParentBloc(
    this._fetchParentUseCase,
    this._saveChildrenUseCase,
    this._readChildrenUseCase,
    this._saveSelectedChildUseCase,
    this._readSelectedChildUseCase,
  ) : super(const ParentState.initial()) {
    on<_Started>(_onStarted);
    on<_LoginSucceeded>(_onLoginSucceeded);
    on<_ChildSelected>(_onChildSelected);
  }

  final FetchParentUseCase _fetchParentUseCase;
  final SaveChildrenUseCase _saveChildrenUseCase;
  final ReadChildrenUseCase _readChildrenUseCase;
  final SaveSelectedChildUseCase _saveSelectedChildUseCase;
  final ReadSelectedChildUseCase _readSelectedChildUseCase;

  /// Cache anak terpilih di level bloc (bukan cuma di state `_Ready`), supaya
  /// [activeNis] tetap kepakai pas bloc lagi `loading()` refresh (mis. pull
  /// to refresh), bukan cuma pas state `_Ready`.
  ChildEntity? _cachedSelectedChild;

  /// Hidrasi saat restart: baca anak + anak terpilih dari storage, fetch
  /// profil parent (cache-first), lalu auto-select kalau anaknya cuma satu.
  Future<void> _onStarted(_Started event, Emitter<ParentState> emit) async {
    emit(const ParentState.loading());

    final childrenResult = await _readChildrenUseCase();
    final selectedResult = await _readSelectedChildUseCase();
    final profileResult = await _fetchParentUseCase(
      forceRefresh: event.forceRefresh,
    );

    final children = childrenResult.match(
      (_) => <ChildEntity>[],
      (list) => list,
    );

    var selectedChild = selectedResult.match((_) => null, (child) => child);

    selectedChild = await _autoSelectIfSingle(selectedChild, children);

    return profileResult.match(
      (failure) => emit(ParentState.failure(failure)),
      (parent) {
        _cachedSelectedChild = selectedChild;
        emit(
          ParentState.ready(
            parent: parent,
            children: children,
            selectedChild: selectedChild,
          ),
        );
      },
    );
  }

  /// Setelah login: simpan daftar anak, auto-select kalau cuma satu, lalu
  /// tampilkan selector. Profil lengkap baru di-fetch lewat [_onStarted].
  Future<void> _onLoginSucceeded(
    _LoginSucceeded event,
    Emitter<ParentState> emit,
  ) async {
    emit(const ParentState.loading());

    await _saveChildrenUseCase(event.children);

    final selectedChild = await _autoSelectIfSingle(null, event.children);

    _cachedSelectedChild = selectedChild;
    emit(
      ParentState.ready(
        parent: ParentEntity(id: 0, nama: event.nama, username: '', telpon: ''),
        children: event.children,
        selectedChild: selectedChild,
      ),
    );
  }

  Future<void> _onChildSelected(
    _ChildSelected event,
    Emitter<ParentState> emit,
  ) async {
    final current = state;
    if (current is! _Ready) return;

    await _saveSelectedChildUseCase(event.child);

    _cachedSelectedChild = event.child;
    emit(current.copyWith(selectedChild: event.child));
  }

  /// Kalau belum ada anak terpilih dan anaknya tepat satu, pilih otomatis
  /// dan simpan supaya restart berikutnya langsung ke dashboard.
  Future<ChildEntity?> _autoSelectIfSingle(
    ChildEntity? selectedChild,
    List<ChildEntity> children,
  ) async {
    if (selectedChild == null && children.length == 1) {
      final single = children.first;
      await _saveSelectedChildUseCase(single);
      return single;
    }
    return selectedChild;
  }

  /// NIS anak aktif yang dipakai interceptor untuk header `X-Student-NIS`.
  String? get activeNis {
    final current = state;
    return current is _Ready
        ? current.selectedChild?.nis
        : _cachedSelectedChild?.nis;
  }
}
