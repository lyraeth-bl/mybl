part of 'merit_bloc.dart';

@freezed
sealed class MeritState with _$MeritState {
  const factory MeritState.initial() = _Initial;

  const factory MeritState.loading() = _Loading;

  const factory MeritState.success({required List<MeritEntity> listMerit}) =
      _Success;

  const factory MeritState.emptyData() = _EmptyData;

  const factory MeritState.failure(Failure failure) = _Failure;
}
