// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/app_container.dart';
import '../../../../l10n/app_localizations.dart';

class AcademicResultLoadingList extends StatelessWidget {
  const AcademicResultLoadingList({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          sliver: SliverToBoxAdapter(child: _LoadingSummaryCard()),
        ),
        SliverToBoxAdapter(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: const [
                _LoadingChip(width: 112),
                SizedBox(width: 10),
                _LoadingChip(width: 112),
              ],
            ),
          ),
        ),
        const _LoadingHeader(width: 148),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          sliver: SliverList.list(
            children: const [
              _LoadingSubjectCard(),
              _LoadingSubjectCard(),
              _LoadingSubjectCard(),
            ],
          ),
        ),
      ],
    );
  }
}

class AcademicResultFailure extends StatelessWidget {
  const AcademicResultFailure({super.key, required this.message});

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
              color: colorScheme.error,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              message.isEmpty ? l10n.dioUnexpectedError : message,
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingSummaryCard extends StatelessWidget {
  const _LoadingSummaryCard();

  @override
  Widget build(BuildContext context) {
    return AppContainer(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(20),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      elevation: 0,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _LoadingBox(width: 140, height: 12),
                SizedBox(height: 10),
                _LoadingBox(width: 112, height: 28),
                SizedBox(height: 12),
                _LoadingBox(width: 132, height: 22),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const _LoadingBox(width: 76, height: 76),
        ],
      ),
    );
  }
}

class _LoadingSubjectCard extends StatelessWidget {
  const _LoadingSubjectCard();

  @override
  Widget build(BuildContext context) {
    return AppContainer(
      margin: const EdgeInsets.only(bottom: 12),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      elevation: 0,
      borderRadius: BorderRadius.circular(8),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _LoadingBox(width: 42, height: 42),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LoadingBox(width: 150, height: 14),
                    SizedBox(height: 8),
                    _LoadingBox(width: 118, height: 11),
                  ],
                ),
              ),
              SizedBox(width: 8),
              _LoadingBox(width: 48, height: 30),
            ],
          ),
          SizedBox(height: 14),
          _LoadingBox(height: 58),
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
      height: 44,
      borderRadius: BorderRadius.circular(999),
    );
  }
}

class _LoadingBox extends StatelessWidget {
  const _LoadingBox({this.width, required this.height});

  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return const Text('').toShimmer(
      context,
      width: width ?? double.infinity,
      height: height,
      borderRadius: BorderRadius.circular(12),
    );
  }
}
