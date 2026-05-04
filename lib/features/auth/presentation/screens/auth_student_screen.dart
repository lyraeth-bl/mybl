// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/di/get_it_constant.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../sessions/presentation/bloc/session_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/remember_me/remember_me_cubit.dart';
import '../widgets/auth_text_field.dart';

/// [AuthStudentScreen] itu pintu masuk utama buat halaman login siswa.
///
/// Di sini kita nge-inject [AuthBloc] pake [BlocProvider] biar semua widget
/// di bawahnya bisa akses logic auth tanpa ribet.
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

/// [_AuthStudentView] adalah wadah utama buat semua komponen UI di screen ini.
///
/// Dia yang nyusun [Scaffold], background animasi, sama form login biar tampilannya estetik.
class _AuthStudentView extends StatelessWidget {
  const _AuthStudentView();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _ErrorHandlingListener(
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        resizeToAvoidBottomInset: false,
        body: Stack(children: [_BuildPatternAnimate(), _LoginForm()]),
      ),
    );
  }
}

/// [_ErrorHandlingListener] itu si "satpam" yang jagain [AuthBloc].
///
/// Tugasnya simpel: dengerin state. Kalo login berhasil atau malah error,
/// dia yang bakal munculin [SnackBar] buat ngasih tau user apa yang terjadi.
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(failure.localizedMessage(l10n))),
            );
          },
        );
      },
      child: child,
    );
  }
}

/// [_BuildPatternAnimate] itu si tukang dekor yang bikin screen jadi lebih idup.
///
/// Dia nampilin pola-pola SVG di pojok atas sama bawah dengan animasi [FadeTransition]
/// dan [SlideTransition] pas screen baru dibuka.
class _BuildPatternAnimate extends StatefulWidget {
  const _BuildPatternAnimate();

  @override
  State<_BuildPatternAnimate> createState() => _BuildPatternAnimateState();
}

class _BuildPatternAnimateState extends State<_BuildPatternAnimate>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  )..forward();

  late final Animation<double> _opacity = CurvedAnimation(
    parent: _animationController,
    curve: Curves.easeIn,
  );

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Upper pattern
        Align(
          alignment: AlignmentDirectional.topEnd,
          child: FadeTransition(
            opacity: _opacity,
            child: SlideTransition(
              position: _opacity.drive(
                Tween<Offset>(begin: const Offset(0.0, -1.0), end: Offset.zero),
              ),
              child: SvgPicture.asset('assets/images/upper_pattern.svg'),
            ),
          ),
        ),

        // Lower pattern
        Align(
          alignment: AlignmentDirectional.bottomStart,
          child: FadeTransition(
            opacity: _opacity,
            child: SlideTransition(
              position: _opacity.drive(
                Tween<Offset>(begin: const Offset(0.0, 1.0), end: Offset.zero),
              ),
              child: SvgPicture.asset('assets/images/lower_pattern.svg'),
            ),
          ),
        ),
      ],
    );
  }
}

/// [_LoginForm] adalah tempat user beraksi buat masuk ke akun mereka.
///
/// Di sini ada field buat NIS sama password, plus validasi receh biar user nggak
/// lupa ngisi datanya sebelum mencet tombol login.
class _LoginForm extends StatefulWidget {
  const _LoginForm();

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  )..forward();

  late final Animation<double> _fadeInAnimation = CurvedAnimation(
    parent: _animationController,
    curve: Curves.easeIn,
  );

  final TextEditingController _nisController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  /// [hidePassword] ini state buat nentuin passwordnya lagi ngumpet (pake bintang-bintang) atau keliatan.
  bool hidePassword = true;

  /// [_onSignIn] itu fungsi buat eksekusi login pas tombol dipencet.
  ///
  /// Dia bakal ngecek dulu inputan user, kalo oke baru deh kirim event
  /// [AuthEvent.loginRequested] ke [AuthBloc].
  void _onSignIn(BuildContext context, AppLocalizations l10n) {
    final nis = _nisController.text.trim();
    final password = _passwordController.text.trim();

    if (nis.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.pleaseEnterNis)));
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.pleaseEnterPassword)));
      return;
    }

    FocusScope.of(context).unfocus();

    context.read<AuthBloc>().add(
      AuthEvent.loginRequested(nis: nis, password: password),
    );
  }

  /// [getSavedNIS] itu fungsinya buat narik NIS yang udah pernah disimpen di lokal.
  ///
  /// Kalo datanya ada di [RememberMeCubit], dia langsung otomatis ngisi field NIS pas screen dibuka.
  void getSavedNIS() {
    final savedNIS = context.read<RememberMeCubit>().state.savedNIS;

    if (savedNIS.isNotEmpty) {
      _nisController.text = savedNIS;
    }
  }

  @override
  void initState() {
    super.initState();

    // Pas screen baru nongol, kita langsung gercep nyari NIS yang kesimpen di memori.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<RememberMeCubit>().loadSavedEmail();
      getSavedNIS();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nisController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenSize = MediaQuery.sizeOf(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          current.maybeWhen(successLogin: (_, _) => true, orElse: () => false),
      listener: (context, state) {
        state.whenOrNull(
          successLogin: (accessToken, expiresAt) {
            context.read<RememberMeCubit>().onLoginSuccess(
              _nisController.text.trim(),
            );

            context.read<SessionBloc>().add(
              SessionEvent.loggedIn(accessToken: accessToken),
            );
          },
        );
      },
      child: Align(
        alignment: Alignment.topCenter,
        child: FadeTransition(
          opacity: _fadeInAnimation,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: SizedBox(
              height: screenSize.height,
              child: NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (notification) {
                  notification.disallowIndicator();
                  return true;
                },
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.only(
                    left: screenSize.width * 0.075,
                    right: screenSize.width * 0.075,
                    top: screenSize.height * 0.17,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.letsSignIn,
                        style: textTheme.headlineLarge!.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        '${l10n.welcomeBack},\n${l10n.youHaveBeenMissed}',
                        style: textTheme.headlineSmall!.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 24),

                      AuthTextField(
                        textEditingController: _nisController,
                        hintText: l10n.nis,
                      ),

                      const SizedBox(height: 24),

                      AuthTextField(
                        textEditingController: _passwordController,
                        hintText: l10n.password,
                        isPassword: hidePassword,
                      ),

                      const SizedBox(height: 24),

                      _RememberMeRow(),

                      const SizedBox(height: 48),

                      _SignInButton(onPressed: () => _onSignIn(context, l10n)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// [_SignInButton] itu tombol eksekusi buat login.
///
/// Dia pinter banget, bisa tau kapan harus nampilin teks "Sign In" atau
/// spinner loading pas lagi nunggu respon dari server lewat [AuthBloc].
class _SignInButton extends StatelessWidget {
  const _SignInButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<AuthBloc, AuthState>(
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

        return FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          onPressed: isLoading ? null : onPressed,
          child: isLoading
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.signIn),
        );
      },
    );
  }
}

/// [_RememberMeRow] itu barisan buat checkbox "Remember Me" sama tombol "Lupa Password".
///
/// Di sini user bisa milih mau disimpen atau nggak NIS-nya buat login selanjutnya.
class _RememberMeRow extends StatelessWidget {
  const _RememberMeRow();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => context.read<RememberMeCubit>().toggleCheckBox(
            !context.read<RememberMeCubit>().state.isChecked,
          ),
          child: Row(
            children: [
              BlocBuilder<RememberMeCubit, RememberMeState>(
                buildWhen: (prev, curr) => prev.isChecked != curr.isChecked,
                builder: (context, state) {
                  return Checkbox(
                    value: state.isChecked,
                    // Null karena udah di handle di GestureDetector.
                    onChanged: null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(16),
                    ),
                  );
                },
              ),
              Text(
                l10n.rememberMyNis,
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            l10n.forgetPassword,
            style: textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}
