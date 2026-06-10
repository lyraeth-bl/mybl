part of 'demerit_bloc.dart';

@freezed
sealed class DemeritState with _$DemeritState {
  const factory DemeritState.initial() = _Initial;

  const factory DemeritState.loading() = _Loading;

  const factory DemeritState.success({
    required List<DemeritEntity> listDemerit,
  }) = _Success;

  const factory DemeritState.emptyData() = _EmptyData;

  const factory DemeritState.failure(Failure failure) = _Failure;
}
