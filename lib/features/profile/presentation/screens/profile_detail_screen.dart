// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/refresh_wrapper.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../user/presentation/bloc/user_bloc.dart';
import '../widgets/profile_detail_notes_section.dart';
import '../widgets/profile_detail_section.dart';
import '../widgets/profile_loading_section.dart';
import '../widgets/profile_overview_section.dart';

class ProfileDetailScreen extends StatelessWidget {
  const ProfileDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      appBar: AppTopBar(toolbarHeight: 72, title: Text(l10n.personalInfo)),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          final isLoading = state.maybeWhen(
            loading: () => true,
            orElse: () => false,
          );
          final student = state.maybeWhen(
            success: (student) => student,
            orElse: () => null,
          );

          if (isLoading) {
            return const CustomScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              slivers: [ProfileLoadingSection()],
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

          return RefreshWrapper(
            onRefresh: () => blocRefresh<UserBloc, UserEvent, UserState>(
              context: context,
              event: const UserEvent.fetchStudentRequested(true),
              isDone: (state) => state.maybeWhen(
                success: (_) => true,
                failure: (_) => true,
                orElse: () => false,
              ),
            ),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                ProfileOverviewSection(student: student),
                ProfileDetailSection(student: student),
                const ProfileDetailNotesSection(),
              ],
            ),
          );
        },
      ),
    );
  }
}
