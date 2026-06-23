// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_bl/core/enums/user_role.dart';

import '../../../../core/di/get_it_constant.dart';
import '../../../../core/widgets/app_responsive_container.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/remember_me/remember_me_cubit.dart';
import '../widgets/auth_login_form.dart';
import '../widgets/auth_pattern_animate.dart';

class AuthStudentScreen extends StatelessWidget {
  const AuthStudentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (context) => di<AuthBloc>()),
        BlocProvider<RememberMeCubit>(
          create: (context) => di<RememberMeCubit>(),
        ),
      ],
      child: const _AuthStudentView(),
    );
  }
}

class _AuthStudentView extends StatelessWidget {
  const _AuthStudentView();

  @override
  Widget build(BuildContext context) {
    return _ErrorHandlingListener(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: AppResponsiveContainer(
          child: Stack(
            children: [
              const AuthPatternAnimate(),
              AuthLoginForm(role: UserRole.student),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorHandlingListener extends StatelessWidget {
  const _ErrorHandlingListener({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        state.whenOrNull(
          failure: (failure) {
            AppToast.error(
              context,
              failure.errorMessage ?? failure.localizedMessage(l10n),
              showProgressBar: false,
            );
          },
        );
      },
      child: child,
    );
  }
}
