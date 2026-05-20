// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/get_it_constant.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../attendance/presentation/bloc/daily_attendance_bloc/daily_attendance_bloc.dart';
import '../../../attendance/presentation/widgets/attendance_qr_bottom_sheet.dart';
import '../../../user/presentation/bloc/user_bloc.dart';
import '../widgets/dashboard_header.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DailyAttendanceBloc>(
      create: (context) => di<DailyAttendanceBloc>(),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatefulWidget {
  const _DashboardView();

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserBloc>().add(const UserEvent.fetchStudentRequested());
      context.read<DailyAttendanceBloc>().add(
        const DailyAttendanceEvent.dailyAttendanceRequested(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAttendanceQrSheet(context),
        tooltip: AppLocalizations.of(context)!.attendanceQrCode,
        child: const Icon(Icons.qr_code_2),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [SliverToBoxAdapter(child: const DashboardHeader())],
      ),
    );
  }
}
