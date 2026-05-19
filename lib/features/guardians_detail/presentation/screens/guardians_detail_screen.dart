// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainer,
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          final student = state.maybeWhen(
            success: (student) => student,
            orElse: () => null,
          );

          if (student == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final l10n = AppLocalizations.of(context)!;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar.medium(
                title: Text(l10n.guardianDetails),
                pinned: true,
                backgroundColor: colorScheme.primaryContainer,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(32),
                  ),
                ),
                elevation: 0,
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                sliver: SliverList.list(
                  children: [
                    _GuardianCard(
                      title: l10n.father,
                      nameLabel: l10n.fatherName,
                      name: student.namaAyah,
                      occupation: student.pekerjaanAyah,
                      lastEducation: student.pendidikanTerakhirAyah,
                    ),
                    const SizedBox(height: 12),
                    _GuardianCard(
                      title: l10n.mother,
                      nameLabel: l10n.motherName,
                      name: student.namaIbu,
                      occupation: student.pekerjaanIbu,
                      lastEducation: student.pendidikanTerakhirIbu,
                    ),
                    const SizedBox(height: 12),
                    _GuardianCard(
                      title: l10n.guardian,
                      nameLabel: l10n.guardianName,
                      name: student.namaWali,
                      occupation: student.pekerjaanWali,
                      lastEducation: student.pendidikanTerakhirWali,
                    ),
                    const SizedBox(height: 16),
                    _ContactDetailCard(student: student),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GuardianCard extends StatelessWidget {
  const _GuardianCard({
    required this.title,
    required this.nameLabel,
    required this.name,
    required this.occupation,
    required this.lastEducation,
  });

  final String title;
  final String nameLabel;
  final String? name;
  final String? occupation;
  final String? lastEducation;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Card.filled(
      color: colorScheme.surfaceContainerLowest,
      elevation: 0,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.family_restroom_rounded, color: colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _DetailRow(label: nameLabel, value: name),
            const SizedBox(height: 12),
            _DetailRow(label: l10n.occupation, value: occupation),
            const SizedBox(height: 12),
            _DetailRow(label: l10n.lastEducation, value: lastEducation),
          ],
        ),
      ),
    );
  }
}

class _ContactDetailCard extends StatelessWidget {
  const _ContactDetailCard({required this.student});

  final StudentEntity student;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Card.filled(
      color: colorScheme.surfaceContainerLowest,
      elevation: 0,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.contactAndAddress,
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
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
            _DetailRow(
              label: l10n.parentAddress,
              value: student.alamatOrangTua,
            ),
            const SizedBox(height: 12),
            _DetailRow(label: l10n.guardianAddress, value: student.alamatWali),
          ],
        ),
      ),
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
