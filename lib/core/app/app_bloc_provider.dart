// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/sessions/presentation/bloc/session_bloc.dart';
import '../../features/user/presentation/bloc/parent_bloc/parent_bloc.dart';
import '../../features/user/presentation/bloc/user_bloc.dart';
import '../di/get_it_constant.dart';
import 'bloc/app_bloc.dart';

class AppBlocProvider extends StatelessWidget {
  const AppBlocProvider({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AppBloc>.value(value: di<AppBloc>()),
        BlocProvider<SessionBloc>.value(value: di<SessionBloc>()),
        BlocProvider<UserBloc>.value(value: di<UserBloc>()),
        BlocProvider<ParentBloc>.value(value: di<ParentBloc>()),
      ],
      child: child,
    );
  }
}
