// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_bl/core/enums/user_role.dart';

import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../sessions/presentation/bloc/session_bloc.dart';
import '../../../user/domain/entities/parent_entity/parent_entity.dart';
import '../../../user/presentation/bloc/parent_bloc/parent_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/remember_me/remember_me_cubit.dart';

class AuthLoginForm extends StatefulWidget {
  const AuthLoginForm({super.key, required this.role, this.accentColor});

  final UserRole role;
  final Color? accentColor;

  @override
  State<AuthLoginForm> createState() => _AuthLoginFormState();
}

class _AuthLoginFormState extends State<AuthLoginForm>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );

  late final Animation<double> _fadeInAnimation = CurvedAnimation(
    parent: _animationController,
    curve: Curves.easeOut,
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

    if (widget.role == UserRole.parent) {
      context.read<AuthBloc>().add(
        AuthEvent.loginParentRequested(nis: nis, password: password),
      );
    } else {
      context.read<AuthBloc>().add(
        AuthEvent.loginRequested(nis: nis, password: password),
      );
    }
  }

  void _getSavedNIS() {
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
      if (MediaQuery.of(context).disableAnimations) {
        _animationController.value = 1.0;
      } else {
        _animationController.forward();
      }
      await context.read<RememberMeCubit>().loadSavedEmail();
      _getSavedNIS();
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
    final accentColor = widget.accentColor ?? colorScheme.primary;

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => current.maybeWhen(
        successLogin: (_, _) => true,
        successParentLogin: (_, _, _, _) => true,
        orElse: () => false,
      ),
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
                role: UserRole.student,
              ),
            );
          },
          successParentLogin: (accessToken, expiresAt, nama, children) {
            context.read<RememberMeCubit>().onLoginSuccess(
              _nisController.text.trim(),
            );

            context.read<ParentBloc>().add(
              ParentEvent.initialized(
                ParentEntity(
                  nama: nama,
                  children: children,
                  selectedChild: children.first,
                ),
              ),
            );

            context.read<SessionBloc>().add(
              SessionEvent.loggedIn(
                accessToken: accessToken,
                expiresAt: expiresAt,
                role: UserRole.parent,
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
                      padding: const EdgeInsets.fromLTRB(24, 120, 24, 24),
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
                                ),
                              ),

                              8.h,

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
                                  color: accentColor,
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
                                  color: accentColor,
                                  width: 2,
                                ),
                              ),

                              const SizedBox(height: 16),

                              _RememberMeRow(accentColor: accentColor),

                              const Spacer(),

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
  const _RememberMeRow({required this.accentColor});

  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _RememberMeCheckbox(
          accentColor: accentColor,
          colorScheme: colorScheme,
          textTheme: textTheme,
          l10n: l10n,
        ),
        _ForgotPasswordButton(l10n: l10n),
      ],
    );
  }
}

class _RememberMeCheckbox extends StatelessWidget {
  const _RememberMeCheckbox({
    required this.accentColor,
    required this.colorScheme,
    required this.textTheme,
    required this.l10n,
  });

  final Color accentColor;
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
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Checkbox(
                  value: state.isChecked,
                  activeColor: accentColor,
                  checkColor: colorScheme.surface,
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
  const _ForgotPasswordButton({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return TextButton(onPressed: null, child: Text(l10n.forgetPassword));
  }
}
