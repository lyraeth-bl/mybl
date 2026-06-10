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
      context.read<ExtracurricularBloc>().add(
        const ExtracurricularEvent.fetchExtracurricular(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: _ExtracurricularAppBar(),
      body: _ExtracurricularBody(),
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

    return AppTopBar(
      toolbarHeight: 72,
      title: Text(l10n.extracurricular),
      centerTitle: true,
      actions: const <Widget>[_ExtracurricularProfileAction()],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(80);
}

class _ExtracurricularProfileAction extends StatelessWidget {
  const _ExtracurricularProfileAction();

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
            event: const ExtracurricularEvent.fetchExtracurricular(true),
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
                loading: () => const ExtracurricularLoadingContent(),
                success: (extracurricular) =>
                    ExtracurricularContent(extracurricular: extracurricular),
                failure: (failure) => SliverFillRemaining(
                  hasScrollBody: false,
                  child: ExtracurricularFailure(
                    message: failure.localizedMessage(
                      AppLocalizations.of(context)!,
                    ),
                  ),
                ),
                orElse: () => const ExtracurricularLoadingContent(),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}
