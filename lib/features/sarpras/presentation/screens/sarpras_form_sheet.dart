// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/get_it_constant.dart';
import '../../../../core/failure/failure.dart';
import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/sarpras/sarpras.dart';
import '../../domain/entities/sarpras_params/sarpras_params.dart';
import '../../domain/entities/sarpras_teacher_candidate/sarpras_teacher_candidate.dart';
import '../../domain/sarpras_rules.dart';
import '../cubit/detail_sarpras_cubit.dart';
import '../cubit/sarpras_teacher_candidate_cubit.dart';
import '../cubit/store_sarpras_cubit.dart';
import '../cubit/update_sarpras_cubit.dart';

/// Modal create/edit form for a facility-use request.
///
/// A null [sarprasId] means create; a non-null id means edit, and the form
/// re-fetches the request to guard against editing an already-processed one.
class SarprasFormSheet extends StatelessWidget {
  const SarprasFormSheet({super.key, this.sarprasId});

  final int? sarprasId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SarprasTeacherCandidateCubit>(
          create: (_) => di<SarprasTeacherCandidateCubit>(),
        ),
        BlocProvider<StoreSarprasCubit>(create: (_) => di<StoreSarprasCubit>()),
        BlocProvider<UpdateSarprasCubit>(
          create: (_) => di<UpdateSarprasCubit>(),
        ),
        BlocProvider<DetailSarprasCubit>(
          create: (_) => di<DetailSarprasCubit>(),
        ),
      ],
      child: _SarprasFormBody(sarprasId: sarprasId),
    );
  }
}

class _SarprasFormBody extends StatefulWidget {
  const _SarprasFormBody({this.sarprasId});

  final int? sarprasId;

  @override
  State<_SarprasFormBody> createState() => _SarprasFormBodyState();
}

class _SarprasFormBodyState extends State<_SarprasFormBody> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _countController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime? _date;
  TimeOfDay? _start;
  TimeOfDay? _end;
  String? _nip;
  String? _timeError;
  String? _dateError;
  String? _startError;
  String? _endError;
  bool _prefilled = false;

  bool get _isEditing => widget.sarprasId != null;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<SarprasTeacherCandidateCubit>().fetchCandidates();

      if (widget.sarprasId != null) {
        _fetchDetail();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _countController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _fetchDetail() {
    context.read<DetailSarprasCubit>().fetchDetail(
      sarprasId: widget.sarprasId!,
    );
  }

  /// Prefills the fields backed by structured [Sarpras] data.
  ///
  /// `waktuKegiatan` is a preformatted display string (e.g. "12.00 - 15.00")
  /// with no reliable machine-readable start/end split, so start and end
  /// time are deliberately left for the user to re-pick rather than parsed.
  void _populateFromDetail(Sarpras sarpras) {
    if (_prefilled) return;

    final nip = sarpras.nipGuruPembimbing;
    final candidateState = context.read<SarprasTeacherCandidateCubit>().state;
    final knownCandidates = candidateState.maybeWhen(
      success: (candidates) => candidates,
      orElse: () => null,
    );
    final isNipStale =
        knownCandidates != null &&
        !knownCandidates.any((candidate) => candidate.nip == nip);

    setState(() {
      _prefilled = true;
      _nameController.text = sarpras.namaKegiatan;
      _countController.text = sarpras.jumlahSiswaDalamKegiatan;
      _noteController.text = sarpras.metadata?.keterangan ?? '';
      _date = DateUtils.dateOnly(sarpras.tanggalKegiatan.toLocal());
      _nip = isNipStale ? null : nip;
    });
  }

  /// Clears a selected/prefilled teacher once it is no longer a candidate.
  ///
  /// A [DropdownButtonFormField] asserts that its value matches exactly one
  /// item, so a NIP that fell out of the candidate list (e.g. the teacher
  /// left) must be cleared before the dropdown rebuilds with the new list.
  void _clearStaleNip(List<SarprasTeacherCandidate> candidates) {
    if (_nip == null) return;
    if (candidates.any((candidate) => candidate.nip == _nip)) return;
    setState(() => _nip = null);
  }

  Future<void> _pickDate() async {
    final firstDate = DateUtils.dateOnly(DateTime.now());
    final initialDate = _date == null || _date!.isBefore(firstDate)
        ? firstDate
        : _date!;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(firstDate.year + 2),
    );

    if (!mounted || picked == null) return;
    setState(() {
      _date = picked;
      _dateError = null;
    });
  }

  Future<void> _pickStart() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _start ?? TimeOfDay.now(),
    );

    if (!mounted || picked == null) return;
    setState(() {
      _start = picked;
      _startError = null;
    });
  }

  Future<void> _pickEnd() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _end ?? TimeOfDay.now(),
    );

    if (!mounted || picked == null) return;
    setState(() {
      _end = picked;
      _endError = null;
    });
  }

  void _submit() {
    final l10n = AppLocalizations.of(context)!;

    final isFormValid = _formKey.currentState?.validate() ?? false;

    final today = DateUtils.dateOnly(DateTime.now());
    final dateError = _date == null
        ? l10n.sarprasValidationRequired
        : _date!.isBefore(today)
        ? l10n.sarprasValidationPastDate
        : null;
    final startError = _start == null ? l10n.sarprasValidationRequired : null;
    final endError = _end == null ? l10n.sarprasValidationRequired : null;

    if (dateError != null || startError != null || endError != null) {
      setState(() {
        _dateError = dateError;
        _startError = startError;
        _endError = endError;
      });
      return;
    }

    if (!isFormValid || _nip == null) return;

    final valid = isSarprasTimeRangeValid(
      startMinutes: _start!.hour * 60 + _start!.minute,
      endMinutes: _end!.hour * 60 + _end!.minute,
    );

    if (!valid) {
      setState(() => _timeError = l10n.sarprasValidationEndBeforeStart);
      return;
    }

    setState(() => _timeError = null);

    final params = SarprasParams(
      tanggalKegiatan: _date!,
      namaKegiatan: _nameController.text,
      jumlahSiswaDalamKegiatan: _countController.text,
      nipGuruPembimbing: _nip!,
      jamMulaiKegiatan: DateTime(
        _date!.year,
        _date!.month,
        _date!.day,
        _start!.hour,
        _start!.minute,
      ),
      jamSelesaiKegiatan: DateTime(
        _date!.year,
        _date!.month,
        _date!.day,
        _end!.hour,
        _end!.minute,
      ),
      keterangan: _noteController.text.isEmpty ? null : _noteController.text,
    );

    if (_isEditing) {
      context.read<UpdateSarprasCubit>().updateSarpras(
        sarprasId: widget.sarprasId!,
        params: params,
      );
    } else {
      context.read<StoreSarprasCubit>().storeSarpras(params);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return MultiBlocListener(
      listeners: [
        if (_isEditing)
          BlocListener<DetailSarprasCubit, DetailSarprasState>(
            listener: (context, state) =>
                state.whenOrNull(success: _populateFromDetail),
          ),
        BlocListener<
          SarprasTeacherCandidateCubit,
          SarprasTeacherCandidateState
        >(
          listener: (context, state) =>
              state.whenOrNull(success: _clearStaleNip),
        ),
        BlocListener<StoreSarprasCubit, StoreSarprasState>(
          listener: (context, state) => state.whenOrNull(
            success: (_) => _handleSuccess(l10n.sarprasCreateSuccess),
            failure: _handleFailure,
          ),
        ),
        BlocListener<UpdateSarprasCubit, UpdateSarprasState>(
          listener: (context, state) => state.whenOrNull(
            success: (_) => _handleSuccess(l10n.sarprasUpdateSuccess),
            failure: _handleFailure,
          ),
        ),
      ],
      child: Scaffold(
        appBar: AppTopBar(
          title: Text(
            _isEditing ? l10n.sarprasEditTitle : l10n.sarprasCreateTitle,
          ),
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: _isEditing ? _buildEditingBody(l10n) : _buildForm(l10n),
      ),
    );
  }

  void _handleSuccess(String message) {
    AppToast.success(context, message);
    context.pop(true);
  }

  void _handleFailure(Failure failure) {
    final l10n = AppLocalizations.of(context)!;
    AppToast.error(context, failure.localizedMessage(l10n));
  }

  Widget _buildEditingBody(AppLocalizations l10n) {
    return BlocBuilder<DetailSarprasCubit, DetailSarprasState>(
      builder: (context, state) => state.maybeWhen(
        success: (sarpras) => sarpras.isCancelable
            ? _buildForm(l10n)
            : Center(
                child: AppEmptyState(
                  icon: Icons.lock_clock_rounded,
                  title: l10n.sarprasProcessedTitle,
                  message: l10n.sarprasProcessedMessage,
                ),
              ),
        failure: (failure) => Center(
          child: AppEmptyState(
            icon: Icons.error_outline_rounded,
            title: l10n.sarprasLoadFailedTitle,
            message: l10n.sarprasLoadFailedMessage,
            retryLabel: l10n.sarprasRetry,
            onRetry: _fetchDetail,
          ),
        ),
        orElse: () => const Center(child: CircularProgressIndicator.adaptive()),
      ),
    );
  }

  Widget _buildForm(AppLocalizations l10n) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const .symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PickerField(
              label: l10n.sarprasFieldDate,
              value: _date?.toDayDateMonthYearFormat(context),
              icon: Icons.calendar_today_rounded,
              onTap: _pickDate,
            ),
            if (_dateError != null) ...[8.h, _FieldError(_dateError!)],
            16.h,
            AppTextField(
              controller: _nameController,
              maxLength: 150,
              decoration: InputDecoration(labelText: l10n.sarprasFieldName),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? l10n.sarprasValidationRequired
                  : null,
            ),
            16.h,
            AppTextField(
              controller: _countController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: l10n.sarprasFieldStudentCount,
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? l10n.sarprasValidationRequired
                  : null,
            ),
            16.h,
            _TeacherDropdownField(
              selectedNip: _nip,
              onChanged: (value) => setState(() => _nip = value),
            ),
            16.h,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PickerField(
                        label: l10n.sarprasFieldStartTime,
                        value: _start?.format(context),
                        icon: Icons.access_time_rounded,
                        onTap: _pickStart,
                      ),
                      if (_startError != null) ...[
                        8.h,
                        _FieldError(_startError!),
                      ],
                    ],
                  ),
                ),
                12.w,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PickerField(
                        label: l10n.sarprasFieldEndTime,
                        value: _end?.format(context),
                        icon: Icons.access_time_rounded,
                        onTap: _pickEnd,
                      ),
                      if (_endError != null) ...[8.h, _FieldError(_endError!)],
                    ],
                  ),
                ),
              ],
            ),
            if (_timeError != null) ...[8.h, _FieldError(_timeError!)],
            16.h,
            AppTextField(
              controller: _noteController,
              maxLines: 4,
              maxLength: 500,
              decoration: InputDecoration(labelText: l10n.sarprasFieldNote),
            ),
            24.h,
            _SubmitButton(isEditing: _isEditing, onSubmit: _submit),
          ],
        ),
      ),
    );
  }
}

/// A tap target styled like a text field that opens a date or time picker.
///
/// Reused for the activity date and both the start and end time fields.
class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String? value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: .circular(16),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, suffixIcon: Icon(icon)),
        isEmpty: value == null,
        child: Text(value ?? ''),
      ),
    );
  }
}

/// Inline error text rendered beneath a field, matching the app's error
/// style used across this form.
class _FieldError extends StatelessWidget {
  const _FieldError(this.message);

  final String message;

  @override
  Widget build(BuildContext context) => Text(
    message,
    style: Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error),
  );
}

/// The supervising-teacher dropdown, driven by [SarprasTeacherCandidateCubit].
class _TeacherDropdownField extends StatelessWidget {
  const _TeacherDropdownField({
    required this.selectedNip,
    required this.onChanged,
  });

  final String? selectedNip;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<
      SarprasTeacherCandidateCubit,
      SarprasTeacherCandidateState
    >(
      builder: (context, state) => state.maybeWhen(
        loading: () => InputDecorator(
          decoration: InputDecoration(
            labelText: l10n.sarprasFieldTeacher,
            suffixIcon: const Padding(
              padding: .all(12),
              child: SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          child: const SizedBox(height: 20),
        ),
        failure: (_) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.sarprasTeacherLoadFailed,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            AppButton.text(
              onPressed: () => context
                  .read<SarprasTeacherCandidateCubit>()
                  .fetchCandidates(),
              child: Text(l10n.sarprasRetry),
            ),
          ],
        ),
        empty: () => Text(l10n.sarprasTeacherEmpty),
        success: (candidates) => DropdownButtonFormField<String>(
          initialValue: selectedNip,
          isExpanded: true,
          decoration: InputDecoration(labelText: l10n.sarprasFieldTeacher),
          items: candidates
              .map(
                (candidate) => DropdownMenuItem(
                  value: candidate.nip,
                  child: Text(candidate.name, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: onChanged,
          validator: (value) =>
              value == null ? l10n.sarprasValidationRequired : null,
        ),
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }
}

/// The submit action, disabled while teachers are unavailable or a write is
/// in flight.
class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.isEditing, required this.onSubmit});

  final bool isEditing;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<
      SarprasTeacherCandidateCubit,
      SarprasTeacherCandidateState
    >(
      builder: (context, candidateState) {
        final isCandidateReady = candidateState.maybeWhen(
          success: (_) => true,
          orElse: () => false,
        );

        return isEditing
            ? BlocBuilder<UpdateSarprasCubit, UpdateSarprasState>(
                builder: (context, state) => _build(
                  context,
                  enabled: isCandidateReady,
                  loading: state.maybeWhen(
                    loading: () => true,
                    orElse: () => false,
                  ),
                ),
              )
            : BlocBuilder<StoreSarprasCubit, StoreSarprasState>(
                builder: (context, state) => _build(
                  context,
                  enabled: isCandidateReady,
                  loading: state.maybeWhen(
                    loading: () => true,
                    orElse: () => false,
                  ),
                ),
              );
      },
    );
  }

  Widget _build(
    BuildContext context, {
    required bool enabled,
    required bool loading,
  }) {
    final l10n = AppLocalizations.of(context)!;

    return AppButton(
      loading: loading,
      onPressed: enabled && !loading ? onSubmit : null,
      child: Text(l10n.sarprasSaveAction),
    );
  }
}
