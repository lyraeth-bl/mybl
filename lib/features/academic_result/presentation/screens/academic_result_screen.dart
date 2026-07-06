// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_router/app_router.dart';
import '../../../../core/di/get_it_constant.dart';
import '../../../../core/internal/src/extensions/extensions.dart';
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
      context.read<AcademicResultBloc>().add(const .fetchAcademicResult());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
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

    return AppTopBar(toolbarHeight: 72, title: Text(l10n.academicResult));
  }

  @override
  Size get preferredSize => Size.fromHeight(72);
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
                loading: () => const AcademicResultContent.loading(),
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
                orElse: () => const AcademicResultContent.loading(),
              );
            },
          ),
          SliverToBoxAdapter(child: 24.h),
        ],
      ),
    );
  }
}
