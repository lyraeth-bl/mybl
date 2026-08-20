// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_router/app_router.dart';
import '../../../../core/di/get_it_constant.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../sessions/presentation/bloc/session_bloc.dart';
import '../bloc/forgot_password_bloc.dart';
import '../widgets/forgot_password_error_listener.dart';
import '../widgets/forgot_password_scaffold.dart';
import '../widgets/forgot_password_text_field.dart';

/// Final reset step: exchange the verified [resetToken] for a new password.
class ForgotPasswordResetScreen extends StatelessWidget {
  const ForgotPasswordResetScreen({super.key, required this.resetToken});

  final String resetToken;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ForgotPasswordBloc>(
      create: (context) => di<ForgotPasswordBloc>(),
      child: _ForgotPasswordResetView(resetToken: resetToken),
    );
  }
}

class _ForgotPasswordResetView extends StatefulWidget {
  const _ForgotPasswordResetView({required this.resetToken});

  final String resetToken;

  @override
  State<_ForgotPasswordResetView> createState() =>
      _ForgotPasswordResetViewState();
}

class _ForgotPasswordResetViewState extends State<_ForgotPasswordResetView> {
  static const int _minPasswordLength = 8;

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmationController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmation = true;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onFieldChanged);
    _confirmationController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_onFieldChanged);
    _confirmationController.removeListener(_onFieldChanged);
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  void _onFieldChanged() => setState(() {});

  bool get _canSubmit =>
      _passwordController.text.trim().isNotEmpty &&
      _confirmationController.text.trim().isNotEmpty;

  void _onSave(BuildContext context, AppLocalizations l10n) {
    final password = _passwordController.text.trim();
    final confirmation = _confirmationController.text.trim();

    if (password.isEmpty) {
      AppToast.warning(
        context,
        l10n.pleaseEnterNewPassword,
        showProgressBar: false,
      );
      return;
    }

    if (password.length < _minPasswordLength) {
      AppToast.warning(context, l10n.passwordTooShort, showProgressBar: false);
      return;
    }

    if (confirmation.isEmpty) {
      AppToast.warning(
        context,
        l10n.pleaseConfirmPassword,
        showProgressBar: false,
      );
      return;
    }

    if (password != confirmation) {
      AppToast.warning(
        context,
        l10n.passwordDoesNotMatch,
        showProgressBar: false,
      );
      return;
    }

    FocusScope.of(context).unfocus();

    context.read<ForgotPasswordBloc>().add(
      ForgotPasswordEvent.passwordResetRequested(
        resetToken: widget.resetToken,
        password: password,
        passwordConfirmation: confirmation,
      ),
    );
  }

  /// Sends the student back to a signed-out sign-in screen.
  ///
  /// The backend invalidates the old credentials, so an active session started
  /// from the settings entry point is dropped instead of silently kept.
  void _onResetSucceeded(BuildContext context, AppLocalizations l10n) {
    AppToast.success(
      context,
      l10n.passwordResetSuccess,
      showProgressBar: false,
    );

    final isAuthenticated = context.read<SessionBloc>().state.maybeWhen(
      authenticated: (_, _) => true,
      orElse: () => false,
    );

    if (isAuthenticated) {
      context.read<SessionBloc>().add(const SessionEvent.loggedOut());
      return;
    }

    context.go(RouteNames.authStudent);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return ForgotPasswordErrorListener(
      child: BlocListener<ForgotPasswordBloc, ForgotPasswordState>(
        listenWhen: (previous, current) =>
            current.maybeWhen(successReset: () => true, orElse: () => false),
        listener: (context, state) {
          state.whenOrNull(
            successReset: () => _onResetSucceeded(context, l10n),
          );
        },
        child: ForgotPasswordScaffold(
          appBarTitle: l10n.forgotPasswordTitle,
          title: l10n.forgotPasswordNewPasswordTitle,
          subtitle: l10n.forgotPasswordNewPasswordSubtitle,
          fields: [
            ForgotPasswordTextField(
              label: l10n.newPassword,
              hintText: l10n.newPasswordHint,
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: colorScheme.onSurfaceVariant,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            ForgotPasswordTextField(
              label: l10n.confirmPassword,
              hintText: l10n.confirmPasswordHint,
              controller: _confirmationController,
              obscureText: _obscureConfirmation,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _onSave(context, l10n),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmation
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: colorScheme.onSurfaceVariant,
                ),
                onPressed: () => setState(
                  () => _obscureConfirmation = !_obscureConfirmation,
                ),
              ),
            ),
          ],
          action: BlocBuilder<ForgotPasswordBloc, ForgotPasswordState>(
            buildWhen: (previous, current) =>
                _isLoading(previous) != _isLoading(current),
            builder: (context, state) {
              final isLoading = _isLoading(state);

              return AppButton(
                loading: isLoading,
                progressIndicatorSize: 28,
                onPressed: _canSubmit && !isLoading
                    ? () => _onSave(context, l10n)
                    : null,
                child: Text(l10n.savePassword),
              );
            },
          ),
        ),
      ),
    );
  }

  static bool _isLoading(ForgotPasswordState state) =>
      state.maybeWhen(loading: () => true, orElse: () => false);
}
