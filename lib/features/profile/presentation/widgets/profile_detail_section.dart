// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/app_sliver_group.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../user/domain/entities/student_entity/student_entity.dart';
import 'profile_card_menu.dart';

class ProfileDetailSection extends StatelessWidget {
  const ProfileDetailSection({super.key, required this.student});

  final StudentEntity student;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final details = _profileDetails(student, l10n, locale);

    return AppSliverGroup(
      title: l10n.personalInfo,
      pinned: true,
      titleStyle: textTheme.titleMedium?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.bold,
      ),
      headerPadding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 8),
      headerHeight: 48,
      titleOffset: 0,
      collapsedOpacity: 1,
      backgroundColor: colorScheme.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: SliverList.list(
        children: details
            .asMap()
            .entries
            .map((entry) {
              final detail = entry.value;

              return ProfileCardMenu(
                title: detail.title,
                subtitle: detail.subtitle,
                icon: detail.icon,
                shape: entry.key.makeVerticalGoogleShape(details.length - 1),
              );
            })
            .toList()
            .makeListAnimate(),
      ),
    );
  }
}

class ProfileDetailNotesSection extends StatelessWidget {
  const ProfileDetailNotesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
        child: Text(
          l10n.detailProfileNotes,
          style: textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

List<_ProfileDetailEntity> _profileDetails(
  StudentEntity student,
  AppLocalizations l10n,
  String locale,
) {
  final gender = _text(student.jenisKelamin);

  return [
    _ProfileDetailEntity(
      title: l10n.unit,
      subtitle: _text(student.unit),
      icon: Icons.school_outlined,
    ),
    _ProfileDetailEntity(
      title: l10n.nis,
      subtitle: _text(student.nis),
      icon: Icons.badge_outlined,
    ),
    _ProfileDetailEntity(
      title: 'NISN',
      subtitle: _text(student.nisn),
      icon: Icons.numbers_outlined,
    ),
    _ProfileDetailEntity(
      title: l10n.dateOfBirth,
      subtitle: _dateText(student.tanggalLahir, locale),
      icon: Icons.date_range_outlined,
    ),
    _ProfileDetailEntity(
      title: l10n.gender,
      subtitle: gender == '-' ? gender : gender.capitalize,
      icon: student.jenisKelamin?.trim().toLowerCase() == 'perempuan'
          ? Icons.female_rounded
          : Icons.male_rounded,
    ),
    _ProfileDetailEntity(
      title: l10n.religion,
      subtitle: _capitalizedText(student.agama),
      icon: Icons.auto_stories_outlined,
    ),
    _ProfileDetailEntity(
      title: l10n.classRoom,
      subtitle: _text(student.kelasSaatIni),
      icon: Icons.groups_outlined,
    ),
    _ProfileDetailEntity(
      title: l10n.classNumber,
      subtitle: _text(student.noKelasSaatIni),
      icon: Icons.meeting_room_outlined,
    ),
    _ProfileDetailEntity(
      title: l10n.semester,
      subtitle: _text(student.semester),
      icon: Icons.menu_book_outlined,
    ),
    _ProfileDetailEntity(
      title: l10n.address,
      subtitle: _text(student.alamat),
      icon: Icons.home_outlined,
    ),
    _ProfileDetailEntity(
      title: l10n.phoneNumber,
      subtitle: _text(student.noTelepon),
      icon: Icons.phone_outlined,
    ),
    _ProfileDetailEntity(
      title: 'Email',
      subtitle: _text(student.email),
      icon: Icons.email_outlined,
    ),
    _ProfileDetailEntity(
      title: l10n.fatherName,
      subtitle: _text(student.namaAyah),
      icon: Icons.supervised_user_circle_outlined,
    ),
    _ProfileDetailEntity(
      title: l10n.motherName,
      subtitle: _text(student.namaIbu),
      icon: Icons.supervised_user_circle_outlined,
    ),
    _ProfileDetailEntity(
      title: l10n.admissionDate,
      subtitle: _dateText(student.tanggalDiTerima, locale),
      icon: Icons.calendar_today_outlined,
    ),
    _ProfileDetailEntity(
      title: l10n.status,
      subtitle: _text(student.aktif),
      icon: Icons.info_outline_rounded,
    ),
  ];
}

String _text(String? value) {
  final text = value?.trim();

  return text == null || text.isEmpty ? '-' : text;
}

String _capitalizedText(String? value) {
  final text = _text(value);

  return text == '-' ? text : text.capitalize;
}

String _dateText(DateTime? value, String locale) {
  if (value == null) return '-';

  return DateFormat('EEEE, d MMMM yyyy', locale).format(value.toLocal());
}

class _ProfileDetailEntity {
  const _ProfileDetailEntity({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}
