// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../user/domain/entities/student_entity/student_entity.dart';
import '../../../user/presentation/bloc/user_bloc.dart';
import '../widgets/profile_card_menu.dart';

/// Screen buat liat "jeroan" alias info lengkap data diri user.
///
/// Isinya detail banget, mulai dari NIS, NISN, tanggal lahir, sampe nama orang tua.
/// Biar nggak bosen bacanya, list-nya kita kasih animasi biar munculnya satu-satu.
class ProfileDetailScreen extends StatefulWidget {
  const ProfileDetailScreen({super.key});

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  /// Tempat nyimpen list widget yang udah dikasih animasi.
  /// Disimpen biar nggak nge-rebuild animasi terus pas scroll.
  List<Widget>? _animatedChildren;

  /// Fungsi buat nyusun list detail profil.
  ///
  /// Di sini kita nge-map data dari [StudentEntity] jadi deretan [ProfileCardMenu].
  /// Kita juga pake extension [makeVerticalGoogleShape] biar bentuk kartunya
  /// makin kece ala-ala Google.
  void _buildAnimatedChildren(StudentEntity student, AppLocalizations l10n) {
    if (_animatedChildren != null) return;

    final details = [
      _ProfileDetailEntity(
        title: l10n.unit,
        subtitle: student.unit ?? "-",
        icon: Icons.school,
      ),
      _ProfileDetailEntity(
        title: l10n.nis,
        subtitle: student.nis,
        icon: Icons.badge_outlined,
      ),
      _ProfileDetailEntity(
        title: "NISN",
        subtitle: student.nisn ?? '-',
        icon: Icons.numbers_outlined,
      ),
      _ProfileDetailEntity(
        title: l10n.dateOfBirth,
        subtitle: student.tanggalLahir?.toDayDateMonthYearFormat ?? "-",
        icon: Icons.date_range,
      ),
      _ProfileDetailEntity(
        title: l10n.gender,
        subtitle: student.jenisKelamin?.capitalize ?? "-",
        icon: (student.jenisKelamin?.toLowerCase() == "perempuan")
            ? Icons.female
            : Icons.male,
      ),
      _ProfileDetailEntity(
        title: l10n.religion,
        subtitle: student.agama?.capitalize ?? "-",
        icon: Icons.auto_stories,
      ),
      _ProfileDetailEntity(
        title: l10n.classRoom,
        subtitle: student.kelasSaatIni ?? "-",
        icon: Icons.school,
      ),
      _ProfileDetailEntity(
        title: l10n.classNumber,
        subtitle: student.noKelasSaatIni ?? "-",
        icon: Icons.meeting_room,
      ),
      _ProfileDetailEntity(
        title: l10n.semester,
        subtitle: student.semester ?? "-",
        icon: Icons.menu_book,
      ),
      _ProfileDetailEntity(
        title: l10n.address,
        subtitle: student.alamat ?? "-",
        icon: Icons.home,
      ),
      _ProfileDetailEntity(
        title: l10n.phoneNumber,
        subtitle: student.noTelepon ?? "-",
        icon: Icons.phone,
      ),
      _ProfileDetailEntity(
        title: "Email",
        subtitle: student.email ?? "-",
        icon: Icons.email,
      ),
      _ProfileDetailEntity(
        title: l10n.fatherName,
        subtitle: student.namaAyah ?? "-",
        icon: Icons.supervised_user_circle,
      ),
      _ProfileDetailEntity(
        title: l10n.motherName,
        subtitle: student.namaIbu ?? "-",
        icon: Icons.supervised_user_circle,
      ),
      _ProfileDetailEntity(
        title: l10n.admissionDate,
        subtitle: student.tanggalDiTerima.toDayDateMonthYearFormat,
        icon: Icons.calendar_today,
      ),
      _ProfileDetailEntity(
        title: l10n.status,
        subtitle: student.aktif ?? "-",
        icon: Icons.info,
      ),
    ];

    final widgets = details
        .asMap()
        .entries
        .map((entry) {
          final customShape = entry.key.makeVerticalGoogleShape(
            details.length - 1,
          );
          final detail = entry.value;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ProfileCardMenu(
              title: detail.title,
              subtitle: detail.subtitle,
              icon: detail.icon,
              shape: customShape,
            ),
          );
        })
        .toList()
        .makeListAnimate();

    setState(() => _animatedChildren = widgets);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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

          // Kita build widget animasinya setelah frame pertama beres digambar.
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _buildAnimatedChildren(student, l10n),
          );

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                title: Text(l10n.personalInfo),
                pinned: true,
                backgroundColor: colorScheme.primaryContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                elevation: 0,
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              SliverList.list(children: _animatedChildren ?? []),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 32,
                    horizontal: 16,
                  ),
                  child: Text(
                    l10n.detailProfileNotes,
                    style: textTheme.labelMedium!.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Helper class internal buat nyimpen data detail profil sebelum di-map jadi widget.
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
