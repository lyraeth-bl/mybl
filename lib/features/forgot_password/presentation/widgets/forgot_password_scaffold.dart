// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/app_responsive_container.dart';
import '../../../../core/widgets/app_top_bar.dart';

/// Shared page chrome for the three reset-password steps.
///
/// Each step renders a heading, a short explanation, its own [fields], and a
/// single primary [action] pinned to the bottom of the viewport.
class ForgotPasswordScaffold extends StatelessWidget {
  const ForgotPasswordScaffold({
    super.key,
    required this.appBarTitle,
    required this.title,
    required this.subtitle,
    required this.fields,
    required this.action,
    this.footer,
  });

  final String appBarTitle;
  final String title;
  final String subtitle;
  final List<Widget> fields;
  final Widget action;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppTopBar(toolbarHeight: 72, title: Text(appBarTitle)),
      body: AppResponsiveContainer(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              const verticalPadding = 48.0;

              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const .fromSTEB(24, 24, 24, 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight > verticalPadding
                        ? constraints.maxHeight - verticalPadding
                        : 0,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: .start,
                      children: [
                        Text(
                          title,
                          style: textTheme.headlineSmall!.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),

                        8.h,

                        Text(
                          subtitle,
                          style: textTheme.bodyMedium!.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),

                        32.h,

                        ...fields.separatedBy(16.h),

                        const Spacer(),

                        24.h,

                        action,

                        if (footer != null) ...[8.h, footer!],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
