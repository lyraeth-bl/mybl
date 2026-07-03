// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_bl/core/enums/user_role.dart';

import '../../../../core/di/get_it_constant.dart';
import '../../../../core/widgets/app_responsive_container.dart';
import '../bloc/auth_bloc.dart';
import '../cubit/remember_me/remember_me_cubit.dart';
import '../widgets/auth_error_listener.dart';
import '../widgets/auth_login_form.dart';
import '../widgets/auth_pattern_animate.dart';

class AuthParentScreen extends StatelessWidget {
  const AuthParentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (context) => di<AuthBloc>()),
        BlocProvider<RememberMeCubit>(
          create: (context) => di<RememberMeCubit>(),
        ),
      ],
      child: const _AuthParentView(),
    );
  }
}

class _AuthParentView extends StatelessWidget {
  const _AuthParentView();

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.tertiary;

    return AuthErrorListener(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: AppResponsiveContainer(
          child: Stack(
            children: [
              AuthPatternAnimate(color: accentColor),
              AuthLoginForm(role: UserRole.parent, accentColor: accentColor),
            ],
          ),
        ),
      ),
    );
  }
}
