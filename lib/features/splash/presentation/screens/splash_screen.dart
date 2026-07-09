// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_router/app_router.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../sessions/presentation/bloc/session_bloc.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SplashScreenView();
  }
}

class _SplashScreenView extends StatefulWidget {
  const _SplashScreenView();

  @override
  State<_SplashScreenView> createState() => _SplashScreenViewState();
}

class _SplashScreenViewState extends State<_SplashScreenView> {
  void _sessionsChecker() {
    context.read<SessionBloc>().add(const SessionEvent.started());
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) _sessionsChecker();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return BlocListener<SessionBloc, SessionState>(
      listener: (context, state) {
        state.whenOrNull(
          unauthenticated: () => context.go(RouteNames.welcome),
          authenticated: (_, role) => context.go(
            role == UserRole.parent
                ? RouteNames.parentChildSelector
                : RouteNames.dashboard,
          ),
        );
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: .center,
            mainAxisAlignment: .center,
            children: [
              Center(
                child:
                    SizedBox(
                          height: 200,
                          width: 200,
                          child: Image.asset('assets/images/bl_logo.png'),
                        )
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .scale(
                          begin: const Offset(0.7, 0.7),
                          end: const Offset(1.0, 1.0),
                          duration: 700.ms,
                          curve: Curves.easeOutBack,
                        ),
              ),

              48.h,

              Text(
                    l10n.schoolName,
                    style: textTheme.headlineMedium!.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 500.ms)
                  .slideY(
                    begin: 0.3,
                    end: 0.0,
                    delay: 500.ms,
                    duration: 500.ms,
                    curve: Curves.easeOut,
                  ),

              24.h,

              Text(
                    l10n.schoolSlogan,
                    style: textTheme.titleMedium!.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 700.ms, duration: 500.ms)
                  .slideY(
                    begin: 0.3,
                    end: 0.0,
                    delay: 700.ms,
                    duration: 500.ms,
                    curve: Curves.easeOut,
                  ),

              64.h,

              CircularProgressIndicator(
                strokeWidth: 2.5,
                color: colorScheme.primary,
                backgroundColor: colorScheme.surfaceContainer,
              ).animate().fadeIn(delay: 1000.ms, duration: 600.ms),
            ],
          ),
        ),
      ),
    );
  }
}
