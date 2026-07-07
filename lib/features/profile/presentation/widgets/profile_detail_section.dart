// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

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
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final List<_ProfileDetailEntity> details = _profileDetails(
      context,
      student,
      l10n,
    );

    return AppSliverGroup(
      title: l10n.personalInfo,
      pinned: true,
      titleStyle: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface),
      headerHeight: 48,
      titleOffset: 0,
      collapsedOpacity: 1,
      backgroundColor: colorScheme.surfaceContainer,
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

List<_ProfileDetailEntity> _profileDetails(
  BuildContext context,
  StudentEntity student,
  AppLocalizations l10n,
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
      subtitle: _dateText(student.tanggalLahir, context),
      icon: Icons.date_range_outlined,
    ),
    _ProfileDetailEntity(
      title: l10n.gender,
      subtitle: gender == '-' ? gender : gender.capitalize,
      icon: _genderIcon(student.jenisKelamin),
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
      subtitle: _dateText(student.tanggalDiTerima, context),
      icon: Icons.calendar_today_outlined,
    ),
    _ProfileDetailEntity(
      title: l10n.status,
      subtitle: _text(student.aktif),
      icon: Icons.info_outline_rounded,
    ),
  ];
}

IconData _genderIcon(String? value) {
  final gender = value?.trim().toLowerCase() ?? '';

  if (gender == 'perempuan') return Icons.female_rounded;
  if (gender.contains('laki')) return Icons.male_rounded;

  return Icons.person_outline;
}

String _text(String? value) {
  final text = value?.trim();

  return text == null || text.isEmpty ? '-' : text;
}

String _capitalizedText(String? value) {
  final text = _text(value);

  return text == '-' ? text : text.capitalize;
}

String _dateText(DateTime? value, BuildContext context) {
  if (value == null) return '-';

  return value.toLocal().toDayDateMonthYearFormat(context);
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
