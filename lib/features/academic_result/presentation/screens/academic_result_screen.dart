// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_router/app_router.dart';
import '../../../../core/di/get_it_constant.dart';
import '../../../../core/widgets/app_profile_picture.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/refresh_wrapper.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../user/presentation/bloc/user_bloc.dart';
import '../bloc/academic_result_bloc.dart';
import '../widgets/academic_result_content.dart';
import '../widgets/academic_result_state_widgets.dart';

class AcademicResultScreen extends StatelessWidget {
  const AcademicResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AcademicResultBloc>(
      create: (context) => di<AcademicResultBloc>(),
      child: const _AcademicResultView(),
    );
  }
}

class _AcademicResultView extends StatefulWidget {
  const _AcademicResultView();

  @override
  State<_AcademicResultView> createState() => _AcademicResultViewState();
}

class _AcademicResultViewState extends State<_AcademicResultView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AcademicResultBloc>().add(
        const AcademicResultEvent.fetchAcademicResult(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const _AcademicResultAppBar(),
      body: const _AcademicResultBody(),
    );
  }
}

@immutable
class _AcademicResultAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _AcademicResultAppBar();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppTopBar(
      toolbarHeight: 72,
      title: Text(l10n.academicResult),
      centerTitle: true,
      actions: const <Widget>[_AcademicResultProfileAction()],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(80);
}

class _AcademicResultProfileAction extends StatelessWidget {
  const _AcademicResultProfileAction();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return BlocSelector<
      UserBloc,
      UserState,
      ({String? imageUrl, String? name})
    >(
      selector: (state) => state.maybeWhen(
        success: (student) => (
          imageUrl: student.profileImageUrl,
          name: student.nama ?? student.namaPanggilan,
        ),
        orElse: () => (imageUrl: null, name: null),
      ),
      builder: (context, profile) {
        return Tooltip(
          message: l10n.profile,
          child: InkResponse(
            onTap: () => context.go(RouteNames.profile),
            customBorder: const CircleBorder(),
            radius: 24,
            child: SizedBox.square(
              dimension: kMinInteractiveDimension,
              child: Center(
                child: AppProfilePicture(
                  imageUrl: profile.imageUrl,
                  initials: AppProfilePicture.initialFrom(profile.name),
                  radius: 20,
                  side: BorderSide(color: colorScheme.outlineVariant, width: 2),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AcademicResultBody extends StatelessWidget {
  const _AcademicResultBody();

  @override
  Widget build(BuildContext context) {
    return RefreshWrapper(
      onRefresh: () =>
          blocRefresh<
            AcademicResultBloc,
            AcademicResultEvent,
            AcademicResultState
          >(
            context: context,
            event: const AcademicResultEvent.fetchAcademicResult(),
            isDone: (state) => state.maybeWhen(
              success: (_) => true,
              failure: (_) => true,
              orElse: () => false,
            ),
          ),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          BlocBuilder<AcademicResultBloc, AcademicResultState>(
            builder: (context, state) {
              return state.maybeWhen(
                loading: () => const AcademicResultLoadingList(),
                success: (academicResult) =>
                    AcademicResultContent(academicResult: academicResult),
                failure: (failure) => SliverFillRemaining(
                  hasScrollBody: false,
                  child: AcademicResultFailure(
                    message: failure.localizedMessage(
                      AppLocalizations.of(context)!,
                    ),
                  ),
                ),
                orElse: () => const AcademicResultLoadingList(),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}
