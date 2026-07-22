part of 'sarpras_teacher_candidate_cubit.dart';

@freezed
sealed class SarprasTeacherCandidateState with _$SarprasTeacherCandidateState {
  const factory SarprasTeacherCandidateState.initial() = _Initial;
  const factory SarprasTeacherCandidateState.loading() = _Loading;
  const factory SarprasTeacherCandidateState.success({
    required List<SarprasTeacherCandidate> candidates,
  }) = _Success;
  const factory SarprasTeacherCandidateState.empty() = _Empty;
  const factory SarprasTeacherCandidateState.failure(Failure failure) =
      _Failure;
}
