part of 'detail_sarpras_cubit.dart';

@freezed
sealed class DetailSarprasState with _$DetailSarprasState {
  const factory DetailSarprasState.initial() = _Initial;
  const factory DetailSarprasState.loading() = _Loading;
  const factory DetailSarprasState.success({required Sarpras sarpras}) =
      _Success;
  const factory DetailSarprasState.failure(Failure failure) = _Failure;
}
