// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_toast.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/forgot_password_bloc.dart';

/// Surfaces every [ForgotPasswordBloc] failure as an error toast.
///
/// The reset endpoints answer with human-readable messages (wrong OTP,
/// unknown NIS, expired token), so the API message is preferred over the
/// generic localized one whenever it is available.
class ForgotPasswordErrorListener extends StatelessWidget {
  const ForgotPasswordErrorListener({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<ForgotPasswordBloc, ForgotPasswordState>(
      listenWhen: (previous, current) =>
          current.maybeWhen(failure: (_) => true, orElse: () => false),
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
