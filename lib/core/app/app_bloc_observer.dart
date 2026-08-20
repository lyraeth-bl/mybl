// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  /// Blocs whose events and states carry credentials or personal data —
  /// passwords, OTP codes, access tokens, reset tokens, student records.
  ///
  /// Their payloads are reduced to type names so secrets never reach logcat.
  /// The `kDebugMode` guard alone is not enough: a debug logcat is still read
  /// by whoever runs the app, and screen recordings capture it.
  static const Set<String> _redactedBlocs = {
    'AuthBloc',
    'ForgotPasswordBloc',
    'SessionBloc',
    'UserBloc',
  };

  static bool _isRedacted(BlocBase<dynamic> bloc) =>
      _redactedBlocs.contains(bloc.runtimeType.toString());

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    if (!kDebugMode) return;

    final description = _isRedacted(bloc)
        ? '${change.currentState.runtimeType} -> ${change.nextState.runtimeType}'
        : '$change';

    debugPrint("BlocObserver : ${bloc.runtimeType} $description");
  }

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    if (!kDebugMode) return;

    final description = _isRedacted(bloc) ? '${event.runtimeType}' : '$event';

    debugPrint("BlocEvent : ${bloc.runtimeType} $description");
  }
}
