// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_bl/core/failure/failure.dart';
import 'package:my_bl/features/auth/domain/repositories/auth_repository.dart';
import 'package:my_bl/features/auth/domain/repositories/parent_auth_repository.dart';
import 'package:my_bl/features/auth/domain/usecases/login_parent_use_case.dart';
import 'package:my_bl/features/auth/domain/usecases/login_use_case.dart';
import 'package:my_bl/features/auth/domain/usecases/logout_use_case.dart';
import 'package:my_bl/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:my_bl/features/dashboard/presentation/screens/parent_profile_screen.dart';
import 'package:my_bl/features/user/domain/entities/child_entity/child_entity.dart';
import 'package:my_bl/features/user/domain/entities/parent_entity/parent_entity.dart';
import 'package:my_bl/features/user/domain/repositories/parent_repository.dart';
import 'package:my_bl/features/user/domain/usecases/fetch_parent_use_case.dart';
import 'package:my_bl/features/user/domain/usecases/read_children_use_case.dart';
import 'package:my_bl/features/user/domain/usecases/read_selected_child_use_case.dart';
import 'package:my_bl/features/user/domain/usecases/save_children_use_case.dart';
import 'package:my_bl/features/user/domain/usecases/save_selected_child_use_case.dart';
import 'package:my_bl/features/user/presentation/bloc/parent_bloc/parent_bloc.dart';
import 'package:my_bl/l10n/app_localizations.dart';
import 'package:my_bl/l10n/app_localizations_en.dart';

class _MockParentRepository extends Mock implements ParentRepository {}

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockParentAuthRepository extends Mock implements ParentAuthRepository {}

final AppLocalizationsEn _l10n = AppLocalizationsEn();

const _budi = ChildEntity(nis: '111', nama: 'Budi', kelas: 'XI A');
const _parent = ParentEntity(
  id: 1,
  nama: 'siti aminah',
  username: 'siti.aminah',
  telpon: '081234567890',
);

ParentBloc _buildBloc(_MockParentRepository repository) {
  return ParentBloc(
    FetchParentUseCase(repository),
    SaveChildrenUseCase(repository),
    ReadChildrenUseCase(repository),
    SaveSelectedChildUseCase(repository),
    ReadSelectedChildUseCase(repository),
  );
}

Widget _wrap(ParentBloc bloc) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en')],
    home: BlocProvider<ParentBloc>.value(
      value: bloc,
      child: const ParentProfileScreen(),
    ),
  );
}

void main() {
  setUp(() {
    GetIt.instance.registerFactory<AuthBloc>(
      () => AuthBloc(
        LoginUseCase(_MockAuthRepository()),
        LogoutUseCase(_MockAuthRepository()),
        LoginParentUseCase(_MockParentAuthRepository()),
      ),
    );
  });

  tearDown(GetIt.instance.reset);

  testWidgets('shows loading skeleton while fetching', (tester) async {
    final repository = _MockParentRepository();
    when(
      () => repository.readChildren(),
    ).thenAnswer((_) async => right(const <ChildEntity>[]));
    when(
      () => repository.readSelectedChild(),
    ).thenAnswer((_) async => right(null));
    when(
      () => repository.fetchParent(forceRefresh: any(named: 'forceRefresh')),
    ).thenAnswer(
      (_) => Future.delayed(
        const Duration(milliseconds: 50),
        () => right(_parent),
      ),
    );

    final bloc = _buildBloc(repository);
    addTearDown(bloc.close);

    await tester.pumpWidget(_wrap(bloc));
    bloc.add(const ParentEvent.started());
    await tester.pump();

    expect(find.byType(Scaffold), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('shows failure state with retry', (tester) async {
    final repository = _MockParentRepository();
    when(
      () => repository.readChildren(),
    ).thenAnswer((_) async => right(const <ChildEntity>[]));
    when(
      () => repository.readSelectedChild(),
    ).thenAnswer((_) async => right(null));
    when(
      () => repository.fetchParent(forceRefresh: any(named: 'forceRefresh')),
    ).thenAnswer((_) async => left(const Failure.network()));

    final bloc = _buildBloc(repository);
    addTearDown(bloc.close);

    await tester.pumpWidget(_wrap(bloc));
    bloc.add(const ParentEvent.started());
    await tester.pumpAndSettle();

    expect(find.text(_l10n.profileLoadFailedTitle), findsOneWidget);
  });

  testWidgets('shows parent overview and children on success', (tester) async {
    final repository = _MockParentRepository();
    when(
      () => repository.readChildren(),
    ).thenAnswer((_) async => right(const [_budi]));
    when(
      () => repository.readSelectedChild(),
    ).thenAnswer((_) async => right(_budi));
    when(
      () => repository.fetchParent(forceRefresh: any(named: 'forceRefresh')),
    ).thenAnswer((_) async => right(_parent));

    final bloc = _buildBloc(repository);
    addTearDown(bloc.close);

    await tester.pumpWidget(_wrap(bloc));
    bloc.add(const ParentEvent.started());
    await tester.pumpAndSettle();

    expect(find.text('Siti Aminah'), findsOneWidget);
    expect(find.text('Budi'), findsOneWidget);
  });
}
