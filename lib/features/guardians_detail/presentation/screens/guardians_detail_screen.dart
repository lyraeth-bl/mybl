// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_router/app_router.dart';
import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/app_container.dart';
import '../../../../core/widgets/app_profile_picture.dart';
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

    return AppTopBar(
      toolbarHeight: 72,
      title: Text(l10n.guardianDetails),
      centerTitle: true,
      actions: const <Widget>[_GuardianDetailProfileAction()],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(80);
}

class _GuardianDetailProfileAction extends StatelessWidget {
  const _GuardianDetailProfileAction();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return BlocSelector<
      UserBloc,
      UserState,
      ({String? imageUrl, String? name})
    >(
      selector: (state) => state.maybeWhen(
        success: (student) => (
          imageUrl: student.profileImageUrl,
          name: student.nama ?? student.namaPanggilan,
        ),
        orElse: () => (imageUrl: null, name: null),
      ),
      builder: (context, profile) {
        return Tooltip(
          message: l10n.profile,
          child: InkResponse(
            onTap: () => context.go(RouteNames.profile),
            customBorder: const CircleBorder(),
            radius: 24,
            child: SizedBox.square(
              dimension: kMinInteractiveDimension,
              child: Center(
                child: AppProfilePicture(
                  imageUrl: profile.imageUrl,
                  initials: AppProfilePicture.initialFrom(profile.name),
                  radius: 20,
                  side: BorderSide(color: colorScheme.outlineVariant, width: 2),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
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

        if (isLoading || student == null) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                sliver: SliverList.list(
                  children: const [
                    _GuardianLoadingCard(),
                    SizedBox(height: 16),
                    _GuardianLoadingCard(),
                    SizedBox(height: 16),
                    _GuardianLoadingCard(),
                    SizedBox(height: 16),
                    _GuardianLoadingCard(rowCount: 4),
                  ],
                ),
              ),
            ],
          );
        }

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
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
                  const SizedBox(height: 24),
                  _GuardianCard(
                    title: l10n.mother,
                    icon: Icons.woman_rounded,
                    nameLabel: l10n.motherName,
                    name: student.namaIbu,
                    occupation: student.pekerjaanIbu,
                    lastEducation: student.pendidikanTerakhirIbu,
                  ),
                  const SizedBox(height: 24),
                  _GuardianCard(
                    title: l10n.guardian,
                    icon: Icons.family_restroom_rounded,
                    nameLabel: l10n.guardianName,
                    name: student.namaWali,
                    occupation: student.pekerjaanWali,
                    lastEducation: student.pendidikanTerakhirWali,
                  ),
                  const SizedBox(height: 24),
                  _ContactDetailCard(student: student),
                ],
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
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return AppContainer(
      title: _SectionTitle(icon: icon, title: title),
      margin: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      backgroundColor: colorScheme.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DetailRow(label: nameLabel, value: name),
          const SizedBox(height: 12),
          _DetailRow(label: l10n.occupation, value: occupation),
          const SizedBox(height: 12),
          _DetailRow(label: l10n.lastEducation, value: lastEducation),
        ],
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

    return AppContainer(
      title: _SectionTitle(
        icon: Icons.contact_phone_rounded,
        title: l10n.contactAndAddress,
      ),
      margin: EdgeInsets.zero,
      backgroundColor: colorScheme.surfaceContainerLow,
      elevation: 0,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DetailRow(
            label: l10n.parentPhoneNumber,
            value: student.noTeleponOrangTua,
          ),
          const SizedBox(height: 12),
          _DetailRow(
            label: l10n.guardianPhoneNumber,
            value: student.noTeleponWali,
          ),
          const SizedBox(height: 12),
          _DetailRow(label: l10n.parentAddress, value: student.alamatOrangTua),
          const SizedBox(height: 12),
          _DetailRow(label: l10n.guardianAddress, value: student.alamatWali),
        ],
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
    return Row(
      children: [
        Icon(icon, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          resolvedValue,
          style: textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
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
            width: 22,
            height: 22,
            borderRadius: BorderRadius.circular(999),
          ),
          const SizedBox(width: 12),
          const Text('').toShimmer(context, width: 96, height: 14),
        ],
      ),
      margin: EdgeInsets.zero,
      elevation: 0,
      backgroundColor: colorScheme.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(rowCount, (index) {
          return Padding(
            padding: EdgeInsets.only(top: index == 0 ? 0 : 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('').toShimmer(context, width: 88, height: 11),
                const SizedBox(height: 6),
                const Text('').toShimmer(context, width: 160, height: 14),
              ],
            ),
          );
        }),
      ),
    );
  }
}
