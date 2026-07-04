// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_bl/core/failure/failure.dart';
import 'package:my_bl/core/internal/src/types.dart';
import 'package:my_bl/core/widgets/app_container.dart';
import 'package:my_bl/features/dashboard/presentation/widgets/dashboard_time_table_section.dart';
import 'package:my_bl/features/time_table/domain/entities/time_table/time_table.dart';
import 'package:my_bl/features/time_table/domain/repositories/repository.dart';
import 'package:my_bl/features/time_table/domain/usecases/fetch_time_table_use_case.dart';
import 'package:my_bl/features/time_table/presentation/bloc/time_table_bloc.dart';
import 'package:my_bl/features/user/domain/repositories/user_repository.dart';
import 'package:my_bl/features/user/domain/usecases/fetch_student_use_case.dart';
import 'package:my_bl/features/user/presentation/bloc/user_bloc.dart';
import 'package:my_bl/l10n/app_localizations.dart';
import 'package:my_bl/l10n/app_localizations_en.dart';

class _MockTimeTableRepository extends Mock implements TimeTableRepository {}

class _MockUserRepository extends Mock implements UserRepository {}

final AppLocalizationsEn _l10n = AppLocalizationsEn();

// Monday, fixed so schedule-day-matching tests are deterministic regardless
// of the real calendar date.
final DateTime _monday = DateTime(2026, 7, 6, 8);
final DateTime _saturday = DateTime(2026, 7, 4, 8);

TimeTableBloc _buildBloc(_MockTimeTableRepository repository) {
  final userBloc = UserBloc(FetchStudentUseCase(_MockUserRepository()));
  addTearDown(userBloc.close);

  return TimeTableBloc(FetchTimeTableUseCase(repository), userBloc);
}

Widget _wrap(TimeTableBloc bloc, {DateTime Function() now = DateTime.now}) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en')],
    home: BlocProvider<TimeTableBloc>.value(
      value: bloc,
      child: Scaffold(
        body: CustomScrollView(slivers: [DashboardTimeTableSection(now: now)]),
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(const TimeTableEvent.fetchTimeTable());
  });

  testWidgets('shows shimmer placeholders while loading', (tester) async {
    final repository = _MockTimeTableRepository();
    final completer = Completer<Result<List<TimeTable>>>();
    when(
      () => repository.fetchAll(any(), any()),
    ).thenAnswer((_) => completer.future);

    final bloc = _buildBloc(repository);
    addTearDown(bloc.close);

    await tester.pumpWidget(_wrap(bloc));
    bloc.add(const TimeTableEvent.fetchTimeTable(false, 'XI A'));
    await tester.pump();

    expect(
      find.byWidgetPredicate(
        (widget) => widget.runtimeType.toString() == '_TimeTableContainer',
      ),
      findsNWidgets(3),
    );

    completer.complete(right(const <TimeTable>[]));
    await tester.pumpAndSettle();
  });

  testWidgets('shows AppNoData on failure', (tester) async {
    final repository = _MockTimeTableRepository();
    when(
      () => repository.fetchAll(any(), any()),
    ).thenAnswer((_) async => left(const Failure.network()));

    final bloc = _buildBloc(repository);
    addTearDown(bloc.close);

    await tester.pumpWidget(_wrap(bloc));
    bloc.add(const TimeTableEvent.fetchTimeTable(false, 'XI A'));
    await tester.pumpAndSettle();

    expect(find.byType(AppNoData), findsOneWidget);
    expect(find.text(_l10n.timeTableLoadFailedTitle), findsOneWidget);
  });

  testWidgets('shows AppNoData before any fetch (initial state)', (
    tester,
  ) async {
    final repository = _MockTimeTableRepository();
    final bloc = _buildBloc(repository);
    addTearDown(bloc.close);

    await tester.pumpWidget(_wrap(bloc));
    await tester.pumpAndSettle();

    expect(find.byType(AppNoData), findsOneWidget);
    expect(find.text(_l10n.noData), findsOneWidget);
  });

  testWidgets('shows AppNoData when there is no schedule for today', (
    tester,
  ) async {
    final repository = _MockTimeTableRepository();
    when(
      () => repository.fetchAll(any(), any()),
    ).thenAnswer((_) async => right(const <TimeTable>[]));

    final bloc = _buildBloc(repository);
    addTearDown(bloc.close);

    await tester.pumpWidget(_wrap(bloc, now: () => _monday));
    bloc.add(const TimeTableEvent.fetchTimeTable(false, 'XI A'));
    await tester.pumpAndSettle();

    expect(find.byType(AppNoData), findsOneWidget);
    expect(find.text(_l10n.noScheduleToday), findsOneWidget);
  });

  testWidgets('shows holiday copy on a weekend', (tester) async {
    final repository = _MockTimeTableRepository();
    when(
      () => repository.fetchAll(any(), any()),
    ).thenAnswer((_) async => right(const <TimeTable>[]));

    final bloc = _buildBloc(repository);
    addTearDown(bloc.close);

    await tester.pumpWidget(_wrap(bloc, now: () => _saturday));
    bloc.add(const TimeTableEvent.fetchTimeTable(false, 'XI A'));
    await tester.pumpAndSettle();

    expect(find.byType(AppNoData), findsOneWidget);
    expect(find.text(_l10n.enjoyYourHoliday), findsOneWidget);
  });

  testWidgets('shows today\'s schedule list on success', (tester) async {
    final repository = _MockTimeTableRepository();
    final todaySchedule = TimeTable(
      id: '1',
      kelas: 'XI A',
      jamKe: '1',
      jamMulai: '00:00',
      jamSelesai: '23:59',
      hari: 'Senin',
      namaGuru: 'Pak Budi',
      namaMataPelajaran: 'Matematika',
      kodeMataPelajaran: 'MTK',
    );
    when(
      () => repository.fetchAll(any(), any()),
    ).thenAnswer((_) async => right(<TimeTable>[todaySchedule]));

    final bloc = _buildBloc(repository);
    addTearDown(bloc.close);

    await tester.pumpWidget(_wrap(bloc, now: () => _monday));
    bloc.add(const TimeTableEvent.fetchTimeTable(false, 'XI A'));
    await tester.pumpAndSettle();

    expect(find.text('Matematika'), findsOneWidget);
    expect(find.text('Pak Budi'), findsOneWidget);
  });
}
