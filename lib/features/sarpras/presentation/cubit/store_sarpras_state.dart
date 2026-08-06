part of 'store_sarpras_cubit.dart';

@freezed
sealed class StoreSarprasState with _$StoreSarprasState {
  const factory StoreSarprasState.initial() = _Initial;
  const factory StoreSarprasState.loading() = _Loading;
  const factory StoreSarprasState.success({required Sarpras sarpras}) =
      _Success;
  const factory StoreSarprasState.failure(Failure failure) = _Failure;
}
