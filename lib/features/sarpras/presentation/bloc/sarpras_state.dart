part of 'sarpras_bloc.dart';

@freezed
sealed class SarprasState with _$SarprasState {
  const factory SarprasState.initial() = _Initial;
  const factory SarprasState.loading() = _Loading;
  const factory SarprasState.success({
    required SarprasSummary summary,
    required List<Sarpras> listSarpras,
  }) = _Success;
  const factory SarprasState.empty({required SarprasSummary summary}) = _Empty;
  const factory SarprasState.failure(Failure failure) = _Failure;
}
