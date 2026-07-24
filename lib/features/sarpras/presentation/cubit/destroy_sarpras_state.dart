part of 'destroy_sarpras_cubit.dart';

@freezed
sealed class DestroySarprasState with _$DestroySarprasState {
  const factory DestroySarprasState.initial() = _Initial;
  const factory DestroySarprasState.loading() = _Loading;
  const factory DestroySarprasState.success() = _Success;
  const factory DestroySarprasState.failure(Failure failure) = _Failure;
}
