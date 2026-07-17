// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/get_it_constant.dart';
import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/refresh_wrapper.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/extracurricular_bloc.dart';
import '../widgets/extracurricular_content.dart';
import '../widgets/extracurricular_state_widgets.dart';

class ExtracurricularScreen extends StatelessWidget {
  const ExtracurricularScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ExtracurricularBloc>(
      create: (context) => di<ExtracurricularBloc>(),
      child: const _ExtracurricularView(),
    );
  }
}

class _ExtracurricularView extends StatefulWidget {
  const _ExtracurricularView();

  @override
  State<_ExtracurricularView> createState() => _ExtracurricularViewState();
}

class _ExtracurricularViewState extends State<_ExtracurricularView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExtracurricularBloc>().add(const .fetchExtracurricular());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      appBar: const _ExtracurricularAppBar(),
      body: const _ExtracurricularBody(),
    );
  }
}

@immutable
class _ExtracurricularAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _ExtracurricularAppBar();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppTopBar(toolbarHeight: 72, title: Text(l10n.extracurricular));
  }

  @override
  Size get preferredSize => const Size.fromHeight(72);
}

class _ExtracurricularBody extends StatelessWidget {
  const _ExtracurricularBody();

  @override
  Widget build(BuildContext context) {
    return RefreshWrapper(
      onRefresh: () =>
          blocRefresh<
            ExtracurricularBloc,
            ExtracurricularEvent,
            ExtracurricularState
          >(
            context: context,
            event: const .fetchExtracurricular(true),
            isDone: (state) => state.maybeWhen(
              success: (_) => true,
              failure: (_) => true,
              orElse: () => false,
            ),
          ),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          BlocBuilder<ExtracurricularBloc, ExtracurricularState>(
            builder: (context, state) {
              return state.maybeWhen(
                success: (extracurricular) =>
                    ExtracurricularContent(extracurricular: extracurricular),
                failure: (failure) => AppEmptyStateSliver(
                  icon: Icons.error_outline_rounded,
                  message: failure.localizedMessage(
                    AppLocalizations.of(context)!,
                  ),
                  retryLabel: AppLocalizations.of(context)!.tryAgain,
                  onRetry: () => context.read<ExtracurricularBloc>().add(
                    const .fetchExtracurricular(true),
                  ),
                ),
                orElse: () => const ExtracurricularLoadingContent(),
              );
            },
          ),
          SliverToBoxAdapter(child: 24.h),
        ],
      ),
    );
  }
}
