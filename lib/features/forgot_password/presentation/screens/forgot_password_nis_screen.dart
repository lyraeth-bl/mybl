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
import '../../../user/presentation/bloc/user_bloc.dart';
import '../bloc/forgot_password_bloc.dart';
import '../widgets/forgot_password_error_listener.dart';
import '../widgets/forgot_password_scaffold.dart';
import '../widgets/forgot_password_text_field.dart';

/// First reset step: collect the NIS the OTP should be sent for.
class ForgotPasswordNisScreen extends StatelessWidget {
  const ForgotPasswordNisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ForgotPasswordBloc>(
      create: (context) => di<ForgotPasswordBloc>(),
      child: const _ForgotPasswordNisView(),
    );
  }
}

class _ForgotPasswordNisView extends StatefulWidget {
  const _ForgotPasswordNisView();

  @override
  State<_ForgotPasswordNisView> createState() => _ForgotPasswordNisViewState();
}

class _ForgotPasswordNisViewState extends State<_ForgotPasswordNisView> {
  final TextEditingController _nisController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nisController.addListener(_onFieldChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _prefillNis());
  }

  @override
  void dispose() {
    _nisController.removeListener(_onFieldChanged);
    _nisController.dispose();
    super.dispose();
  }

  void _onFieldChanged() => setState(() {});

  /// Prefills the NIS when the flow is opened by an already signed-in student.
  void _prefillNis() {
    if (!mounted) return;

    final nis = context.read<UserBloc>().state.maybeWhen(
      success: (student) => student.nis,
      orElse: () => null,
    );

    if (nis == null || nis.isEmpty) return;

    _nisController.text = nis;
  }

  bool get _canSubmit => _nisController.text.trim().isNotEmpty;

  void _onSendCode(BuildContext context, AppLocalizations l10n) {
    final nis = _nisController.text.trim();

    if (nis.isEmpty) {
      AppToast.warning(context, l10n.pleaseEnterNis, showProgressBar: false);
      return;
    }

    FocusScope.of(context).unfocus();

    context.read<ForgotPasswordBloc>().add(
      ForgotPasswordEvent.otpRequested(nis: nis),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ForgotPasswordErrorListener(
      child: BlocListener<ForgotPasswordBloc, ForgotPasswordState>(
        listenWhen: (previous, current) =>
            current.maybeWhen(otpSent: (_) => true, orElse: () => false),
        listener: (context, state) {
          state.whenOrNull(
            otpSent: (nis) =>
                context.push(RouteNames.forgotPasswordOtp, extra: nis),
          );
        },
        child: ForgotPasswordScaffold(
          appBarTitle: l10n.forgotPasswordTitle,
          title: l10n.forgotPasswordTitle,
          subtitle: l10n.forgotPasswordNisSubtitle,
          fields: [
            ForgotPasswordTextField(
              label: l10n.nis,
              hintText: l10n.nisHint,
              controller: _nisController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _onSendCode(context, l10n),
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
                    ? () => _onSendCode(context, l10n)
                    : null,
                child: Text(l10n.sendOtpCode),
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
