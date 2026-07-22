part of 'update_sarpras_cubit.dart';

@freezed
sealed class UpdateSarprasState with _$UpdateSarprasState {
  const factory UpdateSarprasState.initial() = _Initial;
  const factory UpdateSarprasState.loading() = _Loading;
  const factory UpdateSarprasState.success({required Sarpras sarpras}) =
      _Success;
  const factory UpdateSarprasState.failure(Failure failure) = _Failure;
}
