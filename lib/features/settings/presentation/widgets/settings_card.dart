// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../../../core/widgets/app_container.dart';

class SettingsCard extends StatelessWidget {
  const SettingsCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppContainer(
      margin: EdgeInsets.zero,
      padding: padding,
      backgroundColor: colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: child,
    );
  }
}
