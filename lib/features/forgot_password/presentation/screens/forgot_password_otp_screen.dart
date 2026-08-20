// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_router/app_router.dart';
import '../../../../core/di/get_it_constant.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/forgot_password_bloc.dart';
import '../widgets/forgot_password_error_listener.dart';
import '../widgets/forgot_password_scaffold.dart';
import '../widgets/forgot_password_text_field.dart';

/// Second reset step: verify the OTP mailed to the school address of [nis].
class ForgotPasswordOtpScreen extends StatelessWidget {
  const ForgotPasswordOtpScreen({super.key, required this.nis});

  final String nis;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ForgotPasswordBloc>(
      create: (context) => di<ForgotPasswordBloc>(),
      child: _ForgotPasswordOtpView(nis: nis),
    );
  }
}

class _ForgotPasswordOtpView extends StatefulWidget {
  const _ForgotPasswordOtpView({required this.nis});

  final String nis;

  @override
  State<_ForgotPasswordOtpView> createState() => _ForgotPasswordOtpViewState();
}

class _ForgotPasswordOtpViewState extends State<_ForgotPasswordOtpView> {
  static const int _otpLength = 6;

  final TextEditingController _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _otpController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _otpController.removeListener(_onFieldChanged);
    _otpController.dispose();
    super.dispose();
  }

  void _onFieldChanged() => setState(() {});

  bool get _canSubmit => _otpController.text.trim().length == _otpLength;

  void _onVerify(BuildContext context, AppLocalizations l10n) {
    final otpCode = _otpController.text.trim();

    if (otpCode.isEmpty) {
      AppToast.warning(
        context,
        l10n.pleaseEnterOtpCode,
        showProgressBar: false,
      );
      return;
    }

    if (otpCode.length != _otpLength) {
      AppToast.warning(
        context,
        l10n.otpCodeMustBeSixDigits,
        showProgressBar: false,
      );
      return;
    }

    FocusScope.of(context).unfocus();

    context.read<ForgotPasswordBloc>().add(
      ForgotPasswordEvent.otpVerificationRequested(
        nis: widget.nis,
        otpCode: otpCode,
      ),
    );
  }

  void _onResend(BuildContext context) {
    FocusScope.of(context).unfocus();

    context.read<ForgotPasswordBloc>().add(
      ForgotPasswordEvent.otpRequested(nis: widget.nis),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ForgotPasswordErrorListener(
      child: BlocListener<ForgotPasswordBloc, ForgotPasswordState>(
        listenWhen: (previous, current) => current.maybeWhen(
          otpSent: (_) => true,
          otpVerified: (_) => true,
          orElse: () => false,
        ),
        listener: (context, state) {
          state.whenOrNull(
            otpSent: (_) => AppToast.success(
              context,
              l10n.otpCodeResent,
              showProgressBar: false,
            ),
            otpVerified: (resetToken) =>
                context.push(RouteNames.forgotPasswordReset, extra: resetToken),
          );
        },
        child: ForgotPasswordScaffold(
          appBarTitle: l10n.forgotPasswordTitle,
          title: l10n.forgotPasswordOtpTitle,
          subtitle: l10n.forgotPasswordOtpSubtitle,
          fields: [
            ForgotPasswordTextField(
              label: l10n.otpCode,
              hintText: l10n.otpCodeHint,
              controller: _otpController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: _otpLength,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _onVerify(context, l10n),
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
                    ? () => _onVerify(context, l10n)
                    : null,
                child: Text(l10n.verifyOtpCode),
              );
            },
          ),
          footer: BlocBuilder<ForgotPasswordBloc, ForgotPasswordState>(
            buildWhen: (previous, current) =>
                _isLoading(previous) != _isLoading(current),
            builder: (context, state) {
              return Center(
                child: AppButton.text(
                  onPressed: _isLoading(state)
                      ? null
                      : () => _onResend(context),
                  child: Text(l10n.resendOtpCode),
                ),
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
