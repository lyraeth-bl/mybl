// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:my_bl/core/widgets/app_icon_container.dart';

import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/app_container.dart';

class ExtracurricularLoadingContent extends StatelessWidget {
  const ExtracurricularLoadingContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverPadding(
          padding: const .fromLTRB(16, 24, 16, 16),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Text("").toShimmer(
                  context,
                  width: 140,
                  height: 16,
                  borderRadius: .circular(24),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                Text('').toShimmer(
                  context,
                  width: 120,
                  height: 48,
                  borderRadius: .circular(24),
                ),
                SizedBox(width: 16),
                Text('').toShimmer(
                  context,
                  width: 120,
                  height: 48,
                  borderRadius: .circular(24),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: .symmetric(horizontal: 16, vertical: 16),
          sliver: SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                Text("").toShimmer(
                  context,
                  width: 140,
                  height: 16,
                  borderRadius: .circular(24),
                ),
                Text("").toShimmer(
                  context,
                  width: 48,
                  height: 16,
                  borderRadius: .circular(24),
                ),
              ],
            ),
          ),
        ),
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

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return AppContainer(
      margin: const EdgeInsets.only(bottom: 12),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      elevation: 0,
      borderRadius: BorderRadius.circular(8),
      child: ListTile(
        contentPadding: .zero,
        leading: AppIconContainer(icon: Icons.abc).toShimmer(
          context,
          width: 40,
          height: 40,
          borderRadius: .circular(24),
        ),
        title: Text("").toShimmer(
          context,
          width: 48,
          height: 16,
          borderRadius: .circular(24),
        ),
        trailing: Text(
          "",
        ).toShimmer(context, width: 32, height: 32, borderRadius: .circular(8)),
      ),
    );
  }
}
