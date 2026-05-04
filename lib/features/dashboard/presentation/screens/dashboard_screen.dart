// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../sessions/presentation/bloc/session_bloc.dart';
import '../../../user/presentation/bloc/user_bloc.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            BlocBuilder<SessionBloc, SessionState>(
              builder: (context, state) {
                return state.maybeWhen(
                  authenticated: (accessToken) => Text(accessToken),
                  orElse: () => Text("Tidak ada sessions"),
                );
              },
            ),

            BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                return state.maybeWhen(
                  success: (student) => Text("Nama : ${student.nama}"),
                  orElse: () => Text("Tidak ada data user"),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
