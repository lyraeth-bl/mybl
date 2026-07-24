// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/get_it_constant.dart';
import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_container.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/sarpras/sarpras.dart';
import '../cubit/destroy_sarpras_cubit.dart';
import '../cubit/detail_sarpras_cubit.dart';

/// Modal detail view for a single facility-use request.
class SarprasDetailSheet extends StatelessWidget {
  const SarprasDetailSheet({super.key, required this.sarprasId});

  final int sarprasId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DetailSarprasCubit>(
          create: (_) => di<DetailSarprasCubit>(),
        ),
        BlocProvider<DestroySarprasCubit>(
          create: (_) => di<DestroySarprasCubit>(),
        ),
      ],
      child: _SarprasDetailBody(sarprasId: sarprasId),
    );
  }
}

class _SarprasDetailBody extends StatefulWidget {
  const _SarprasDetailBody({required this.sarprasId});

  final int sarprasId;

  @override
  State<_SarprasDetailBody> createState() => _SarprasDetailBodyState();
}

class _SarprasDetailBodyState extends State<_SarprasDetailBody> {
  bool _hasChanged = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchDetail());
  }

  void _fetchDetail() {
    context.read<DetailSarprasCubit>().fetchDetail(sarprasId: widget.sarprasId);
  }

  Future<void> _openEdit(int id) async {
    final changed = await context.push<bool>('/sarpras/$id/edit');
    if (!mounted) return;
    if (changed == true) {
      _hasChanged = true;
      _fetchDetail();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<DestroySarprasCubit, DestroySarprasState>(
      listener: (context, state) {
        state.whenOrNull(
          success: () {
            AppToast.success(context, l10n.sarprasCancelSuccess);
            context.pop(true);
          },
          failure: (failure) {
            AppToast.error(context, failure.localizedMessage(l10n));
          },
        );
      },
      child: Scaffold(
        appBar: AppTopBar(
          title: Text(l10n.sarprasDetailTitle),
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => context.pop(_hasChanged),
          ),
          toolbarHeight: 72,
        ),
        body: BlocBuilder<DetailSarprasCubit, DetailSarprasState>(
          builder: (context, state) => state.maybeWhen(
            failure: (failure) => Center(
              child: AppEmptyState(
                icon: Icons.error_outline_rounded,
                title: l10n.sarprasLoadFailedTitle,
                message: l10n.sarprasLoadFailedMessage,
                retryLabel: l10n.sarprasRetry,
                onRetry: _fetchDetail,
              ),
            ),
            success: (sarpras) => _SarprasDetailContent(sarpras: sarpras),
            orElse: () =>
                const Center(child: CircularProgressIndicator.adaptive()),
          ),
        ),
        bottomNavigationBar:
            BlocBuilder<DetailSarprasCubit, DetailSarprasState>(
              builder: (context, state) => state.maybeWhen(
                success: (sarpras) => sarpras.isCancelable
                    ? SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                          child: _DetailActions(
                            sarpras: sarpras,
                            onEdit: () => _openEdit(sarpras.id),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
                orElse: () => const SizedBox.shrink(),
              ),
            ),
      ),
    );
  }
}

class _SarprasDetailContent extends StatelessWidget {
  const _SarprasDetailContent({required this.sarpras});

  final Sarpras sarpras;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final metadata = sarpras.metadata;
    final fieldRows = <Widget>[
      _DetailRow(
        label: l10n.sarprasFieldDate,
        value: sarpras.tanggalKegiatan.toDayDateMonthYearFormat(context),
      ),
      _DetailRow(label: l10n.sarprasFieldName, value: sarpras.namaKegiatan),
      _DetailRow(
        label: l10n.sarprasFieldStudentCount,
        value: sarpras.jumlahSiswaDalamKegiatan,
      ),
      _DetailRow(
        label: l10n.sarprasFieldTeacher,
        value: sarpras.namaGuruPembimbing ?? sarpras.nipGuruPembimbing,
      ),
      _DetailRow(label: l10n.sarprasFieldTime, value: sarpras.waktuKegiatan),
      if ((metadata?.keterangan ?? '').trim().isNotEmpty)
        _DetailRow(label: l10n.sarprasFieldNote, value: metadata!.keterangan!),
    ];
    final resolvedRows = <Widget>[
      if (metadata?.nameResolver != null)
        _DetailRow(
          label: l10n.sarprasResolvedBy,
          value: metadata!.nameResolver!,
        ),
      if (metadata?.resolvedAt != null)
        _DetailRow(
          label: l10n.sarprasResolvedAt,
          value: metadata!.resolvedAt!.toDayDateMonthYearFormat(context),
        ),
    ];

    return SingleChildScrollView(
      padding: const .all(16),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          AppFramedContainer(
            margin: .zero,
            gap: .all(4),
            child: Column(
              crossAxisAlignment: .start,
              children: fieldRows.separatedBy(16.h),
            ),
          ),
          if (metadata?.alasanTolak != null) ...[
            16.h,
            _RejectionReasonBox(reason: metadata!.alasanTolak!),
          ],
          if (resolvedRows.isNotEmpty) ...[
            16.h,
            AppFramedContainer(
              margin: .zero,
              gap: .all(4),
              child: Column(
                crossAxisAlignment: .start,
                children: resolvedRows.separatedBy(16.h),
              ),
            ),
          ],
        ],
      ),
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

/// The rejection reason, given prominence via the error color scheme.
class _RejectionReasonBox extends StatelessWidget {
  const _RejectionReasonBox({required this.reason});

  final String reason;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text(
            l10n.sarprasRejectionReason,
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.onErrorContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
          8.h,
          Text(
            reason,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onErrorContainer,
            ),
          ),
        ],
      ),
    );
  }
}

/// Edit/withdraw actions, shown only while [sarpras] is still cancelable.
class _DetailActions extends StatelessWidget {
  const _DetailActions({required this.sarpras, required this.onEdit});

  final Sarpras sarpras;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: AppButton(
            onPressed: onEdit,
            child: Text(l10n.sarprasEditAction),
          ),
        ),
        Expanded(
          child: AppButton(
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
            foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
            onPressed: () => _confirmCancel(context, sarpras.id),
            child: Text(l10n.sarprasCancelAction),
          ),
        ),
      ].separatedBy(16.w),
    );
  }

  void _confirmCancel(BuildContext context, int id) {
    final l10n = AppLocalizations.of(context)!;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.sarprasCancelConfirmTitle),
        content: Text(l10n.sarprasCancelConfirmMessage),
        actions: [
          AppButton.text(
            backgroundColor: Theme.of(dialogContext).colorScheme.errorContainer,
            foregroundColor: Theme.of(
              dialogContext,
            ).colorScheme.onErrorContainer,
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          AppButton.text(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<DestroySarprasCubit>().destroySarpras(sarprasId: id);
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }
}
