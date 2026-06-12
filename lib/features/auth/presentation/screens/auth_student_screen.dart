// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/di/get_it_constant.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../sessions/presentation/bloc/session_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/remember_me/remember_me_cubit.dart';

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
        body: Stack(children: [_BuildPatternAnimate(), _LoginForm()]),
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

  void _onSignIn(BuildContext context, AppLocalizations l10n) {
    final nis = _nisController.text.trim();
    final password = _passwordController.text.trim();

    if (nis.isEmpty) {
      AppToast.warning(context, l10n.pleaseEnterNis, showProgressBar: false);
      return;
    }

    if (password.isEmpty) {
      AppToast.warning(
        context,
        l10n.pleaseEnterPassword,
        showProgressBar: false,
      );
      return;
    }

    FocusScope.of(context).unfocus();

    context.read<AuthBloc>().add(
      AuthEvent.loginRequested(nis: nis, password: password),
    );
  }

  void getSavedNIS() {
    final savedNIS = context.read<RememberMeCubit>().state.savedNIS;

    if (savedNIS.isNotEmpty) {
      _nisController.text = savedNIS;
    }
  }

  bool get _canSubmit =>
      _nisController.text.trim().isNotEmpty &&
      _passwordController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _nisController.addListener(_onFieldChanged);
    _passwordController.addListener(_onFieldChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<RememberMeCubit>().loadSavedEmail();
      getSavedNIS();
    });
  }

  void _onFieldChanged() => setState(() {});

  @override
  void dispose() {
    _nisController.removeListener(_onFieldChanged);
    _passwordController.removeListener(_onFieldChanged);
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
              SessionEvent.loggedIn(
                accessToken: accessToken,
                expiresAt: expiresAt,
              ),
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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(24, 124, 24, 24),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight > 148
                              ? constraints.maxHeight - 148
                              : 0,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.letsSignIn,
                                style: textTheme.headlineLarge!.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: .bold,
                                ),
                              ),

                              const SizedBox(height: 12),

                              Text(
                                '${l10n.welcomeBack},\n${l10n.youHaveBeenMissed}',
                                style: textTheme.headlineSmall!.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  height: 1.5,
                                ),
                              ),

                              const SizedBox(height: 32),

                              AppTextField(
                                controller: _nisController,
                                decoration: InputDecoration(hintText: l10n.nis),
                                focusedSide: BorderSide(
                                  color: colorScheme.primary,
                                  width: 2,
                                ),
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),

                              const SizedBox(height: 16),

                              AppTextField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  hintText: l10n.password,
                                ),
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                obscureText: true,
                                focusedSide: BorderSide(
                                  color: colorScheme.primary,
                                  width: 2,
                                ),
                              ),

                              const SizedBox(height: 16),

                              _RememberMeRow(),

                              const SizedBox(height: 24),

                              BlocBuilder<AuthBloc, AuthState>(
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

                                  return AppButton(
                                    loading: isLoading,
                                    onPressed: _canSubmit && !isLoading
                                        ? () => _onSignIn(context, l10n)
                                        : null,
                                    progressIndicatorSize: 28,
                                    child: Text(l10n.signIn),
                                  );
                                },
                              ),

                              const SizedBox(height: 32),

                              Center(
                                child: Text(
                                  l10n.loginHelpNotice,
                                  textAlign: TextAlign.center,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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
        _RememberMeCheckbox(
          colorScheme: colorScheme,
          textTheme: textTheme,
          l10n: l10n,
        ),
        _ForgotPasswordButton(
          colorScheme: colorScheme,
          textTheme: textTheme,
          l10n: l10n,
        ),
      ],
    );
  }
}

class _RememberMeCheckbox extends StatelessWidget {
  const _RememberMeCheckbox({
    required this.colorScheme,
    required this.textTheme,
    required this.l10n,
  });

  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RememberMeCubit, RememberMeState>(
      buildWhen: (prev, curr) => prev.isChecked != curr.isChecked,
      builder: (context, state) {
        return InkWell(
          onTap: () =>
              context.read<RememberMeCubit>().toggleCheckBox(!state.isChecked),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Checkbox(
                  value: state.isChecked,
                  activeColor: colorScheme.primary,
                  checkColor: colorScheme.onPrimary,
                  side: BorderSide(color: colorScheme.outline, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  onChanged: (val) => context
                      .read<RememberMeCubit>()
                      .toggleCheckBox(val ?? false),
                ),
                Text(
                  l10n.rememberMyNis,
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ForgotPasswordButton extends StatelessWidget {
  const _ForgotPasswordButton({
    required this.colorScheme,
    required this.textTheme,
    required this.l10n,
  });

  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {},
      child: Text(
        l10n.forgetPassword,
        style: textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: colorScheme.primary,
        ),
      ),
    );
  }
}
