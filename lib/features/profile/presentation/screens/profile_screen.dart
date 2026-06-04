// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_router/app_router.dart';
import '../../../../core/di/get_it_constant.dart';
import '../../../../core/widgets/logout_button.dart';
import '../../../../core/widgets/profile_picture.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../sessions/presentation/bloc/session_bloc.dart';
import '../../../user/domain/entities/student_entity/student_entity.dart';
import '../../../user/presentation/bloc/user_bloc.dart';
import '../widgets/profile_card_menu.dart';

/// Layar utama buat pamer profil user.
///
/// Di sini user bisa liat info singkat mereka kayak nama, NIS, sampe foto profil.
/// Screen ini juga jadi gerbang buat masuk ke detail profil atau buat logout.
/// Kita ngebungkus ini pake [AuthBloc] biar urusan logout-nya lancar jaya.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (context) => di<AuthBloc>(),
      child: const _ProfileScreenView(),
    );
  }
}

/// Tampilan utama dari [ProfileScreen].
///
/// Widget ini pake [CustomScrollView] biar ada efek scroll yang asik (pake [BouncingScrollPhysics]).
/// Dia dengerin [UserBloc] buat mastiin data [StudentEntity] selalu yang paling update.
class _ProfileScreenView extends StatelessWidget {
  const _ProfileScreenView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      appBar: const _ProfileAppBar(),
      body: const _ProfileBody(),
    );
  }
}

class _ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ProfileAppBar();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return AppBar(
      backgroundColor: colorScheme.primaryContainer,
      surfaceTintColor: colorScheme.primaryContainer,
      toolbarHeight: 72,
      title: Text(
        l10n.profile,
        style: const TextStyle(fontWeight: .bold, letterSpacing: 2),
      ),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(80);
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          final student = state.maybeWhen(
            success: (student) => student,
            orElse: () => null,
          );

          // Kalo data student-nya belum ada (mungkin lagi loading atau error),
          // kita kasih space kosong dulu biar nggak crash.
          if (student == null) return const SizedBox.shrink();

          return CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              _ProfileInfo(student: student),
              const _ProfileMenu(),
            ],
          );
        },
      ),
    );
  }
}

/// Bagian yang khusus nampilin foto profil.
///
/// Dibikin terpisah biar rapi dan gampang kalo mau di-style macem-macem.
class _ProfileInfo extends StatelessWidget {
  const _ProfileInfo({required this.student});

  final StudentEntity student;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return SliverToBoxAdapter(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 40, 16, 32),
          child: Column(
            children: [
              ProfilePicture(
                backgroundColor: colorScheme.surfaceContainerLow,
                foregroundColor: colorScheme.onSurfaceVariant,
                profileImageUrl: student.profileImageUrl ?? "",
                radius: 48,
              ),
              const SizedBox(height: 16),
              Text(
                student.nama ?? l10n.emptyName,
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${student.nis} / ${student.nisn ?? '-'}",
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Daftar menu yang ada di profil.
///
/// Isinya ada link ke detail personal info sama tombol logout.
/// Dia dengerin [AuthBloc] buat handle pindah screen pas user sukses logout.
class _ProfileMenu extends StatelessWidget {
  const _ProfileMenu();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        state.whenOrNull(
          successLogout: () =>
              context.read<SessionBloc>().add(const SessionEvent.loggedOut()),
        );
      },
      child: SliverList.list(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                ProfileCardMenu(
                  title: l10n.personalInfo,
                  subtitle: l10n.personalInfoDesc,
                  icon: Icons.medical_information_outlined,
                  onTap: () => context.push(RouteNames.profileDetail),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: BlocBuilder<AuthBloc, AuthState>(
              buildWhen: (prev, curr) {
                final prevLoading = prev.maybeWhen(
                  loading: () => true,
                  orElse: () => false,
                );
                final currLoading = curr.maybeWhen(
                  loading: () => true,
                  orElse: () => false,
                );
                return prevLoading != currLoading;
              },
              builder: (context, state) {
                final isLoading = state.maybeWhen(
                  loading: () => true,
                  orElse: () => false,
                );

                return LogoutButton(
                  onPressed: () => context.read<AuthBloc>().add(
                    const AuthEvent.logoutRequested(),
                  ),
                  isLoading: isLoading,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
