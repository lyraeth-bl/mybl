// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_top_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../user/presentation/bloc/user_bloc.dart';
import '../widgets/profile_detail_section.dart';
import '../widgets/profile_overview_section.dart';

class ProfileDetailScreen extends StatelessWidget {
  const ProfileDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppTopBar(
        toolbarHeight: 72,
        title: Text(l10n.personalInfo),
        centerTitle: true,
      ),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          final student = state.maybeWhen(
            success: (student) => student,
            orElse: () => null,
          );

          if (student == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              ProfileOverviewSection(student: student),
              ProfileDetailSection(student: student),
              const ProfileDetailNotesSection(),
            ],
          );
        },
      ),
    );
  }
}
