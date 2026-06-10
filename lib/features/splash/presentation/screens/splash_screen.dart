// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_router/app_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../sessions/presentation/bloc/session_bloc.dart';

/// [SplashScreen] itu pintu gerbang utama pas aplikasi baru pertama kali dibuka.
/// Isinya simpel banget, cuma jembatan buat nampilin [_SplashScreenView] biar
/// struktur kodenya tetep rapi dan enak dibaca.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SplashScreenView();
  }
}

/// [_SplashScreenView] ini si paling sibuk pas awal-awal.
/// Dia yang tanggung jawab buat nampilin visual logo yang estetik pake animasi,
/// sekaligus jadi tempat buat ngecek apakah lo udah login atau belum.
class _SplashScreenView extends StatefulWidget {
  const _SplashScreenView();

  @override
  State<_SplashScreenView> createState() => _SplashScreenViewState();
}

/// [_SplashScreenViewState] adalah otak di balik layar splash.
/// Di sini kita mainin delay dikit biar user sempet liat logo keren kita,
/// sebelum akhirnya kita tanya ke [SessionBloc] soal status autentikasi lo.
class _SplashScreenViewState extends State<_SplashScreenView> {
  /// [_sessionsChecker] itu tukang colek [SessionBloc].
  /// Fungsinya buat ngasih tau BLoC kalo aplikasi udah siap dan butuh info
  /// soal status session user sekarang.
  void _sessionsChecker() {
    context.read<SessionBloc>().add(const SessionEvent.started());
  }

  @override
  void initState() {
    super.initState();

    // Kita kasih waktu 3 detik buat branding moment.
    // Setelah itu baru deh kita panggil [_sessionsChecker].
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) _sessionsChecker();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<SessionBloc, SessionState>(
      listener: (context, state) {
        state.whenOrNull(
          // Kalo ternyata lo belum login (unauthenticated), langsung kita
          // oper ke halaman login biar gak nyasar.
          unauthenticated: () => context.go(RouteNames.authStudent),

          // Kalo udah login, langsung di lempar ke dashboard, biar ga cape
          // login lagi.
          authenticated: (_) => context.go(RouteNames.dashboard),
        );
      },
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
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

            const SizedBox(height: 48),

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

            const SizedBox(height: 24),

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

            const SizedBox(height: 64),

            CircularProgressIndicator(
              strokeWidth: 2.5,
              color: colorScheme.primary,
              backgroundColor: colorScheme.surfaceContainer,
            ).animate().fadeIn(delay: 1000.ms, duration: 600.ms),
          ],
        ),
      ),
    );
  }
}
