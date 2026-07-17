// Copyright (c) 2026 Mahsa Nurfarhan Hidayat / Yayasan Pakarti Luhur. All rights reserved.
// Use of this source code is governed by a MIT License
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../../../core/internal/src/extensions/extensions.dart';
import '../../../../core/widgets/app_icon_container.dart';

class SettingsMenuTile extends StatelessWidget {
  const SettingsMenuTile({
    super.key,
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconForegroundColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.padding = const .symmetric(horizontal: 16, vertical: 12),
    this.onTap,
  });

  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconForegroundColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: padding,
          child: Row(
            children: [
              AppIconContainer(
                icon: icon,
                iconSize: 20,
                padding: const .all(8),
                backgroundColor: iconBackgroundColor,
                foregroundColor: iconForegroundColor,
              ),
              16.w,
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: .ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: .w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      2.h,
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: .ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              12.w,
              trailing ??
                  Icon(
                    Icons.chevron_right_rounded,
                    color: colorScheme.onSurfaceVariant,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
