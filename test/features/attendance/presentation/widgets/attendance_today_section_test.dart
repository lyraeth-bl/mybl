// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_bl/core/failure/failure.dart';
import 'package:my_bl/core/widgets/app_button.dart';
import 'package:my_bl/core/widgets/app_container.dart';
import 'package:my_bl/features/attendance/domain/entities/attendance_entity/attendance_entity.dart';
import 'package:my_bl/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:my_bl/features/attendance/domain/usecases/fetch_daily_attendance_use_case.dart';
import 'package:my_bl/features/attendance/presentation/bloc/daily_attendance_bloc/daily_attendance_bloc.dart';
import 'package:my_bl/features/attendance/presentation/widgets/attendance_today_section.dart';
import 'package:my_bl/l10n/app_localizations.dart';
import 'package:my_bl/l10n/app_localizations_en.dart';

class _MockAttendanceRepository extends Mock implements AttendanceRepository {}

final AppLocalizationsEn _l10n = AppLocalizationsEn();

final DateTime _beforeCutoff = DateTime(2026, 7, 6, 8);
final DateTime _afterCutoff = DateTime(2026, 7, 6, 14);

AttendanceEntity _entity({DateTime? checkIn, DateTime? checkOut}) {
  final day = DateTime(2026, 7, 6);

  return AttendanceEntity(
    id: 1,
    nis: '123',
    tajaran: '2025/2026',
    semester: '1',
    tanggal: day,
    jamCheckIn: checkIn,
    jamCheckOut: checkOut,
    status: 'Hadir',
    unit: 'SMA',
    createdAt: day,
    updatedAt: day,
  );
}

DailyAttendanceBloc _buildBloc(_MockAttendanceRepository repository) {
  return DailyAttendanceBloc(FetchDailyAttendanceUseCase(repository));
}

Widget _wrap(DailyAttendanceBloc bloc, {DateTime Function() now = DateTime.now}) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en')],
    home: Scaffold(
      body: BlocProvider<DailyAttendanceBloc>.value(
        value: bloc,
        child: AttendanceTodaySection(now: now),
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(false);
  });

  testWidgets('shows AppNoData on failure', (tester) async {
    final repository = _MockAttendanceRepository();
    when(
      () => repository.fetchDailyAttendance(any()),
    ).thenAnswer((_) async => left(const Failure.network()));

    final bloc = _buildBloc(repository);
    addTearDown(bloc.close);

    await tester.pumpWidget(_wrap(bloc));
    bloc.add(const DailyAttendanceEvent.dailyAttendanceRequested());
    await tester.pumpAndSettle();

    expect(find.byType(AppNoData), findsOneWidget);
    expect(find.text(_l10n.attendanceTodayLoadFailedTitle), findsOneWidget);
  });

  testWidgets('shows AppNoData when there is no schedule today', (tester) async {
    final repository = _MockAttendanceRepository();
    when(
      () => repository.fetchDailyAttendance(any()),
    ).thenAnswer((_) async => right(null));

    final bloc = _buildBloc(repository);
    addTearDown(bloc.close);

    await tester.pumpWidget(_wrap(bloc));
    bloc.add(const DailyAttendanceEvent.dailyAttendanceRequested());
    await tester.pumpAndSettle();

    expect(find.byType(AppNoData), findsOneWidget);
    expect(find.text(_l10n.attendanceNoScheduleTitle), findsOneWidget);
  });

  testWidgets('shows enabled "Check In" button when no record exists yet', (
    tester,
  ) async {
    final repository = _MockAttendanceRepository();
    when(
      () => repository.fetchDailyAttendance(any()),
    ).thenAnswer((_) async => right(_entity()));

    final bloc = _buildBloc(repository);
    addTearDown(bloc.close);

    await tester.pumpWidget(_wrap(bloc, now: () => _beforeCutoff));
    bloc.add(const DailyAttendanceEvent.dailyAttendanceRequested());
    await tester.pumpAndSettle();

    final button = tester.widget<AppButton>(find.byType(AppButton));
    expect(find.text(_l10n.attendanceCheckInAction), findsOneWidget);
    expect(button.onPressed, isNotNull);
  });

  testWidgets('shows disabled "Checked In" button before cutoff', (
    tester,
  ) async {
    final repository = _MockAttendanceRepository();
    when(() => repository.fetchDailyAttendance(any())).thenAnswer(
      (_) async => right(_entity(checkIn: DateTime(2026, 7, 6, 6, 30))),
    );

    final bloc = _buildBloc(repository);
    addTearDown(bloc.close);

    await tester.pumpWidget(_wrap(bloc, now: () => _beforeCutoff));
    bloc.add(const DailyAttendanceEvent.dailyAttendanceRequested());
    await tester.pumpAndSettle();

    final button = tester.widget<AppButton>(find.byType(AppButton));
    expect(find.text(_l10n.attendanceAlreadyCheckedIn), findsOneWidget);
    expect(button.onPressed, isNull);
  });

  testWidgets('shows enabled "Check Out" button after cutoff', (tester) async {
    final repository = _MockAttendanceRepository();
    when(() => repository.fetchDailyAttendance(any())).thenAnswer(
      (_) async => right(_entity(checkIn: DateTime(2026, 7, 6, 6, 30))),
    );

    final bloc = _buildBloc(repository);
    addTearDown(bloc.close);

    await tester.pumpWidget(_wrap(bloc, now: () => _afterCutoff));
    bloc.add(const DailyAttendanceEvent.dailyAttendanceRequested());
    await tester.pumpAndSettle();

    final button = tester.widget<AppButton>(find.byType(AppButton));
    expect(find.text(_l10n.attendanceCheckOutAction), findsOneWidget);
    expect(button.onPressed, isNotNull);
  });

  testWidgets('shows disabled "Done" button once checked out', (tester) async {
    final repository = _MockAttendanceRepository();
    when(() => repository.fetchDailyAttendance(any())).thenAnswer(
      (_) async => right(
        _entity(
          checkIn: DateTime(2026, 7, 6, 6, 30),
          checkOut: DateTime(2026, 7, 6, 11),
        ),
      ),
    );

    final bloc = _buildBloc(repository);
    addTearDown(bloc.close);

    await tester.pumpWidget(_wrap(bloc, now: () => _afterCutoff));
    bloc.add(const DailyAttendanceEvent.dailyAttendanceRequested());
    await tester.pumpAndSettle();

    final button = tester.widget<AppButton>(find.byType(AppButton));
    expect(find.text(_l10n.attendanceDone), findsOneWidget);
    expect(button.onPressed, isNull);
  });
}
