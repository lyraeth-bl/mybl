// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/app_container.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../user/domain/entities/student_entity/student_entity.dart';
import '../../../user/presentation/bloc/user_bloc.dart';

class GuardiansDetailScreen extends StatelessWidget {
  const GuardiansDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _GuardiansDetailView();
  }
}

class _GuardiansDetailView extends StatelessWidget {
  const _GuardiansDetailView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      appBar: const _GuardianDetailAppBar(),
      body: const _GuardianDetailBody(),
    );
  }
}

class _GuardianDetailAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _GuardianDetailAppBar();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppTopBar(toolbarHeight: 72, title: Text(l10n.guardianDetails));
  }

  @override
  Size get preferredSize => Size.fromHeight(72);
}

class _GuardianDetailBody extends StatelessWidget {
  const _GuardianDetailBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        final isLoading = state.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );
        final student = state.maybeWhen(
          success: (student) => student,
          orElse: () => null,
        );

        final l10n = AppLocalizations.of(context)!;

        if (isLoading) {
          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const .fromLTRB(16, 24, 16, 32),
                sliver: SliverList.list(
                  children: const [
                    _GuardianLoadingCard(),
                    _GuardianLoadingCard(),
                    _GuardianLoadingCard(),
                    _GuardianLoadingCard(rowCount: 4),
                  ].separatedBy(16.h),
                ),
              ),
            ],
          );
        }

        if (student == null) {
          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              AppEmptyStateSliver(
                icon: Icons.face_retouching_off,
                title: l10n.profileLoadFailedTitle,
                message: l10n.profileLoadFailedSubtitle,
                retryLabel: l10n.tryAgain,
                onRetry: () => context.read<UserBloc>().add(
                  const UserEvent.fetchStudentRequested(true),
                ),
              ),
            ],
          );
        }

        return CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const .fromLTRB(16, 24, 16, 32),
              sliver: SliverList.list(
                children: [
                  _GuardianCard(
                    title: l10n.father,
                    icon: Icons.man_rounded,
                    nameLabel: l10n.fatherName,
                    name: student.namaAyah,
                    occupation: student.pekerjaanAyah,
                    lastEducation: student.pendidikanTerakhirAyah,
                  ),
                  _GuardianCard(
                    title: l10n.mother,
                    icon: Icons.woman_rounded,
                    nameLabel: l10n.motherName,
                    name: student.namaIbu,
                    occupation: student.pekerjaanIbu,
                    lastEducation: student.pendidikanTerakhirIbu,
                  ),
                  _GuardianCard(
                    title: l10n.guardian,
                    icon: Icons.family_restroom_rounded,
                    nameLabel: l10n.guardianName,
                    name: student.namaWali,
                    occupation: student.pekerjaanWali,
                    lastEducation: student.pendidikanTerakhirWali,
                  ),
                  _ContactDetailCard(student: student),
                ].separatedBy(24.h),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _GuardianCard extends StatelessWidget {
  const _GuardianCard({
    required this.title,
    required this.icon,
    required this.nameLabel,
    required this.name,
    required this.occupation,
    required this.lastEducation,
  });

  final String title;
  final IconData icon;
  final String nameLabel;
  final String? name;
  final String? occupation;
  final String? lastEducation;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return AppFramedContainer(
      title: _SectionTitle(icon: icon, title: title),
      gap: .all(8),
      backgroundColor: colorScheme.surfaceContainer,
      headerColor: colorScheme.surfaceContainer,
      innerBorderRadius: .circular(12),
      margin: .zero,
      elevation: 0,
      child: Column(
        crossAxisAlignment: .start,
        children: [
          _DetailRow(label: nameLabel, value: name),
          _DetailRow(label: l10n.occupation, value: occupation),
          _DetailRow(label: l10n.lastEducation, value: lastEducation),
        ].separatedBy(16.h),
      ),
    );
  }
}

class _ContactDetailCard extends StatelessWidget {
  const _ContactDetailCard({required this.student});

  final StudentEntity student;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return AppFramedContainer(
      title: _SectionTitle(
        icon: Icons.contact_phone_rounded,
        title: l10n.contactAndAddress,
      ),
      gap: .all(8),
      backgroundColor: colorScheme.surfaceContainer,
      headerColor: colorScheme.surfaceContainer,
      innerBorderRadius: .circular(12),
      margin: .zero,
      elevation: 0,
      child: Column(
        crossAxisAlignment: .start,
        children: [
          _DetailRow(
            label: l10n.parentPhoneNumber,
            value: student.noTeleponOrangTua,
          ),
          _DetailRow(
            label: l10n.guardianPhoneNumber,
            value: student.noTeleponWali,
          ),
          _DetailRow(label: l10n.parentAddress, value: student.alamatOrangTua),
          _DetailRow(label: l10n.guardianAddress, value: student.alamatWali),
        ].separatedBy(16.h),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    return Row(
      children: [
        Icon(icon, size: 24, color: colorScheme.onSurface),
        Expanded(child: Text(title, maxLines: 1, overflow: .ellipsis)),
      ].separatedBy(8.w),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final resolvedValue = value == null || value!.trim().isEmpty ? '-' : value!;

    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          label,
          style: textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          resolvedValue,
          style: textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ].separatedBy(4.h),
    );
  }
}

class _GuardianLoadingCard extends StatelessWidget {
  const _GuardianLoadingCard({this.rowCount = 3});

  final int rowCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppContainer(
      title: Row(
        children: [
          const Text('').toShimmer(
            context,
            width: 24,
            height: 24,
            borderRadius: .circular(8),
          ),
          const Text('').toShimmer(context, width: 96, height: 12),
        ].separatedBy(16.w),
      ),
      margin: .zero,
      elevation: 0,
      backgroundColor: colorScheme.surfaceContainer,
      child: Column(
        crossAxisAlignment: .start,
        children: List.generate(rowCount, (index) {
          return Padding(
            padding: .only(top: index == 0 ? 0 : 16),
            child: Column(
              crossAxisAlignment: .start,
              children: [
                const Text('').toShimmer(context, width: 80, height: 8),
                const Text('').toShimmer(context, width: 160, height: 16),
              ].separatedBy(8.h),
            ),
          );
        }),
      ),
    );
  }
}
