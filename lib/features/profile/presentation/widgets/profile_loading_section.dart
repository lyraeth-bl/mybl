// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/app_container.dart';

/// Shimmer placeholder mirroring [ProfileOverviewSection] while the
/// student profile is loading.
class ProfileLoadingSection extends StatelessWidget {
  const ProfileLoadingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          16.h,
          AppFramedContainer(
            gap: .zero,
            elevation: 0,
            child: Column(
              children: [
                const Text('').toShimmer(
                  context,
                  width: 96,
                  height: 96,
                  borderRadius: .circular(48),
                ),
                24.h,
                const Text('').toShimmer(context, width: 160, height: 16),
                8.h,
                const Text('').toShimmer(context, width: 120, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
