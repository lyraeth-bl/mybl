// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/app_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/extracurricular_bloc.dart';

class ExtracurricularLoadingContent extends StatelessWidget {
  const ExtracurricularLoadingContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        const _LoadingHeader(width: 96),
        SliverToBoxAdapter(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: const [
                _LoadingChip(width: 132),
                SizedBox(width: 10),
                _LoadingChip(width: 112),
              ],
            ),
          ),
        ),
        const _LoadingHeader(width: 128),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          sliver: SliverList.list(
            children: const [_LoadingCard(), _LoadingCard(), _LoadingCard()],
          ),
        ),
      ],
    );
  }
}

class ExtracurricularFailure extends StatelessWidget {
  const ExtracurricularFailure({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              message.isEmpty ? l10n.dioUnexpectedError : message,
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => context.read<ExtracurricularBloc>().add(
                const ExtracurricularEvent.fetchExtracurricular(true),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.tryAgain),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return AppContainer(
      margin: const EdgeInsets.only(bottom: 12),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      elevation: 0,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('').toShimmer(
                context,
                width: 42,
                height: 42,
                borderRadius: BorderRadius.circular(12),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('').toShimmer(context, width: 180, height: 14),
                    const SizedBox(height: 8),
                    const Text('').toShimmer(context, width: 120, height: 11),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Text('').toShimmer(
                context,
                width: 54,
                height: 42,
                borderRadius: BorderRadius.circular(999),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.45,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            children: List.generate(4, (_) => const _LoadingDetailTile()),
          ),
        ],
      ),
    );
  }
}

class _LoadingDetailTile extends StatelessWidget {
  const _LoadingDetailTile();

  @override
  Widget build(BuildContext context) {
    return AppContainer(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      elevation: 0,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          const Text('').toShimmer(
            context,
            width: 18,
            height: 18,
            borderRadius: BorderRadius.circular(999),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('').toShimmer(context, width: 56, height: 10),
                const SizedBox(height: 6),
                const Text('').toShimmer(context, width: 88, height: 13),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingHeader extends StatelessWidget {
  const _LoadingHeader({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 24, 16, 8),
        child: const Text('').toShimmer(context, width: width, height: 14),
      ),
    );
  }
}

class _LoadingChip extends StatelessWidget {
  const _LoadingChip({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return const Text('').toShimmer(
      context,
      width: width,
      height: 40,
      borderRadius: BorderRadius.circular(999),
    );
  }
}
