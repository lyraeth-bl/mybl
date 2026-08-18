// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/get_it_constant.dart';
import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/app_chip_container.dart';
import '../../../../core/widgets/app_container.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/extracurricular_attendance/extracurricular_attendance.dart';
import '../cubit/detail_extracurricular_attendance_cubit.dart';
import '../widgets/extracurricular_attendance_status.dart';

/// Modal detail view for a single extracurricular session.
class ExtracurricularAttendanceDetailSheet extends StatelessWidget {
  const ExtracurricularAttendanceDetailSheet({
    super.key,
    required this.extraSessionId,
  });

  final int extraSessionId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DetailExtracurricularAttendanceCubit>(
      create: (_) => di<DetailExtracurricularAttendanceCubit>(),
      child: _ExtracurricularAttendanceDetailBody(
        extraSessionId: extraSessionId,
      ),
    );
  }
}

class _ExtracurricularAttendanceDetailBody extends StatefulWidget {
  const _ExtracurricularAttendanceDetailBody({required this.extraSessionId});

  final int extraSessionId;

  @override
  State<_ExtracurricularAttendanceDetailBody> createState() =>
      _ExtracurricularAttendanceDetailBodyState();
}

class _ExtracurricularAttendanceDetailBodyState
    extends State<_ExtracurricularAttendanceDetailBody> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchDetail());
  }

  void _fetchDetail() {
    context.read<DetailExtracurricularAttendanceCubit>().fetchDetail(
      extraSessionId: widget.extraSessionId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppTopBar(
        title: Text(l10n.extracurricularSessionDetail),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        toolbarHeight: 72,
      ),
      body:
          BlocBuilder<
            DetailExtracurricularAttendanceCubit,
            DetailExtracurricularAttendanceState
          >(
            builder: (context, state) => state.maybeWhen(
              failure: (failure) => Center(
                child: AppEmptyState(
                  icon: Icons.error_outline_rounded,
                  title: l10n.extracurricularAttendanceLoadFailed,
                  message: failure.localizedMessage(l10n),
                  retryLabel: l10n.tryAgain,
                  onRetry: _fetchDetail,
                ),
              ),
              success: (attendance) =>
                  _AttendanceDetailContent(attendance: attendance),
              orElse: () =>
                  const Center(child: CircularProgressIndicator.adaptive()),
            ),
          ),
    );
  }
}

class _AttendanceDetailContent extends StatelessWidget {
  const _AttendanceDetailContent({required this.attendance});

  final ExtracurricularAttendanceDetail attendance;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final incidentNote = attendance.catatanKejadian?.trim() ?? '';
    final fieldRows = <Widget>[
      _DetailRow(
        label: l10n.date,
        value: attendance.tanggal.toDayDateMonthYearFormat(context),
      ),
      _DetailRow(label: l10n.activity, value: attendance.namaKegiatan),
      _DetailRow(label: l10n.unit, value: attendance.unit),
      _DetailRow(label: l10n.material, value: attendance.materi),
      _DetailRow(
        label: l10n.teacher,
        value: attendance.namaGuru ?? l10n.noData,
      ),
    ];

    return SingleChildScrollView(
      padding: const .all(16),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          _StatusHeader(status: attendance.status),
          16.h,
          AppFramedContainer(
            margin: .zero,
            gap: .all(4),
            child: Column(
              crossAxisAlignment: .start,
              children: fieldRows.separatedBy(16.h),
            ),
          ),
          if (incidentNote.isNotEmpty) ...[
            16.h,
            _IncidentNoteBox(note: incidentNote),
          ],
        ],
      ),
    );
  }
}

/// The session status, given prominence at the top of the sheet.
class _StatusHeader extends StatelessWidget {
  const _StatusHeader({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final resolvedStatus = extracurricularAttendanceStatusFromRaw(status);
    final (Color backgroundColor, Color foregroundColor) =
        extracurricularAttendanceStatusColors(context, resolvedStatus);

    return Row(
      children: [
        Text(
          l10n.status,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        AppChipContainer(
          value: extracurricularAttendanceStatusLabel(
            l10n,
            resolvedStatus,
            status,
          ),
          padding: const .symmetric(horizontal: 16, vertical: 8),
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
        ),
      ].separatedBy(12.w),
    );
  }
}

/// A label/value pair used for every field shown in the detail sheet.
class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        12.w,
        Expanded(
          child: Text(
            value,
            textAlign: .end,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// The teacher's note about the session, shown only when one exists.
class _IncidentNoteBox extends StatelessWidget {
  const _IncidentNoteBox({required this.note});

  final String note;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text(
            l10n.incidentNote,
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
          8.h,
          Text(
            note,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
